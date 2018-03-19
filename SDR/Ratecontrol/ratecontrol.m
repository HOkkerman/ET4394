function ratecontrol(bandwidth, delay_profile, distance)

%% Inputs
cfgVHT = wlanVHTConfig;         
%
cfgVHT.ChannelBandwidth = bandwidth; % Channel bandwidth
%
cfgVHT.MCS = 1;                    % QPSK rate-1/2
cfgVHT.APEPLength = 4096;          % APEP length in bytes

% Set random stream for repeatability of results
s = rng(21);


tgacChannel = wlanTGacChannel;
%
tgacChannel.DelayProfile = delay_profile; % Delay profile model
%
tgacChannel.ChannelBandwidth = cfgVHT.ChannelBandwidth;
tgacChannel.NumTransmitAntennas = 1;
tgacChannel.NumReceiveAntennas = 1;
%
tgacChannel.TransmitReceiveDistance = distance; % Distance in meters for NLOS
%
tgacChannel.RandomStream = 'mt19937ar with seed';
tgacChannel.Seed = 10;

% Set the sampling rate for the channel
sr = helperSampleRate(cfgVHT.ChannelBandwidth);
tgacChannel.SampleRate = sr;


%% Rate Control Algorithm Parameters
rcaAttack = 1;  % Control the sensitivity when MCS is increasing
rcaRelease = 0; % Control the sensitivity when MCS is decreasing
threshold = [11 14 19 20 25 28 30 31 35]; 
snrUp = [threshold inf]+rcaAttack;
snrDown = [-inf threshold]-rcaRelease;
snrInd = cfgVHT.MCS; % Store the start MCS value


%% Simulation Parameters
numPackets = 100; % Number of packets transmitted during the simulation 
walkSNR = true; 

% Select SNR for the simulation
if walkSNR
    meanSNR = 22;   % Mean SNR
    amplitude = 14; % Variation in SNR around the average mean SNR value
    % Generate varying SNR values for each transmitted packet
    baseSNR = sin(linspace(1,10,numPackets))*amplitude+meanSNR;
    snrWalk = baseSNR(1); % Set the initial SNR value
    % The maxJump controls the maximum SNR difference between one
    % packet and the next 
    maxJump = 0.5;
else
    % Fixed mean SNR value for each transmitted packet. All the variability
    % in SNR comes from a time varying radio channel
    snrWalk = 22; %#ok<UNRCH>
end

% To plot the equalized constellation for each spatial stream set
% displayConstellation to true
displayConstellation = false;
if displayConstellation
    ConstellationDiagram = comm.ConstellationDiagram; %#ok<UNRCH>
    ConstellationDiagram.ShowGrid = true;
    ConstellationDiagram.Name = 'Equalized data symbols';
end

% Define simulation variables
snrMeasured = zeros(1,numPackets);
MCS = zeros(1,numPackets);
ber = zeros(1,numPackets);
packetLength = zeros(1,numPackets);


%% Algorithm stuff
for numPkt = 1:numPackets 
    if walkSNR
        % Generate SNR value per packet using random walk algorithm biased
        % towards the mean SNR
        snrWalk = 0.9*snrWalk+0.1*baseSNR(numPkt)+rand(1)*maxJump*2-maxJump;
    end
    
    % Generate a single packet waveform
    txPSDU = randi([0,1],8*cfgVHT.PSDULength,1,'int8');
    txWave = wlanWaveformGenerator(txPSDU,cfgVHT,'IdleTime',5e-4);
    
    % Receive processing, including SNR estimation
    y = processPacket(txWave,snrWalk,tgacChannel,cfgVHT);
    
    % Plot equalized symbols of data carrying subcarriers
    if displayConstellation && ~isempty(y.EstimatedSNR)
        ConstellationDiagram.release();
        ConstellationDiagram.ReferenceConstellation = helperReferenceSymbols(cfgVHT);
        ConstellationDiagram.Title = ['Packet ' int2str(numPkt)];
        step(ConstellationDiagram,y.EqDataSym(:));
        drawnow 
    end
    
    % Store estimated SNR value for each packet
    if isempty(y.EstimatedSNR) 
        snrMeasured(1,numPkt) = NaN;
    else
        snrMeasured(1,numPkt) = y.EstimatedSNR;
    end
    
    % Determine the length of the packet in seconds including idle time
    packetLength(numPkt) = y.RxWaveformLength/sr;
    
    % Calculate packet error rate (PER)
    if isempty(y.RxPSDU)
        % Set the PER of an undetected packet to NaN
        ber(numPkt) = NaN;
    else
        [~,ber(numPkt)] = biterr(y.RxPSDU,txPSDU);
    end

    % Compare the estimated SNR to the threshold, and adjust the MCS value
    % used for the next packet
    MCS(numPkt) = cfgVHT.MCS; % Store current MCS value
    increaseMCS = (mean(y.EstimatedSNR) > snrUp((snrInd==0)+snrInd));
    decreaseMCS = (mean(y.EstimatedSNR) <= snrDown((snrInd==0)+snrInd));
    snrInd = snrInd+increaseMCS-decreaseMCS;
    cfgVHT.MCS = snrInd-1;
end


%%



% Display and plot simulation results
disp(['Overall data rate: ' num2str(8*cfgVHT.APEPLength*(numPackets-numel(find(ber)))/sum(packetLength)/1e6) ' Mbps']);
disp(['Overall packet error rate: ' num2str(numel(find(ber))/numPackets)]);

plotResults(ber,packetLength,snrMeasured,MCS,cfgVHT);

% Restore default stream
rng(s);



displayEndOfDemoMessage(mfilename)

function Y = processPacket(txWave,snrWalk,tgacChannel,cfgVHT)
    % Pass the transmitted waveform through the channel, perform
    % receiver processing, and SNR estimation.
    
    chanBW = cfgVHT.ChannelBandwidth; % Channel bandwidth
    % Set the following parameters to empty for an undetected packet
    estimatedSNR = [];
    eqDataSym = [];
    noiseVarVHT = [];
    rxPSDU = [];
    
    % Get the number of occupied subcarriers in VHT fields
    [vhtData,vhtPilots] = helperSubcarrierIndices(cfgVHT,'VHT');
    Nst_vht = numel(vhtData)+numel(vhtPilots);
    Nfft = helperFFTLength(cfgVHT); % FFT length
    
    % Pass the waveform through the fading channel model
    rxWave = tgacChannel(txWave);
    
    % Create an instance of the AWGN channel for each transmitted packet
    awgnChannel = comm.AWGNChannel;
    awgnChannel.NoiseMethod = 'Signal to noise ratio (SNR)';
    % Normalization
    awgnChannel.SignalPower = 1/tgacChannel.NumReceiveAntennas;
    % Account for energy in nulls
    awgnChannel.SNR = snrWalk-10*log10(Nfft/Nst_vht);
    
    % Add noise
    rxWave = awgnChannel(rxWave);
    rxWaveformLength = size(rxWave,1); % Length of the received waveform
    
    % Recover packet
    ind = wlanFieldIndices(cfgVHT); % Get field indices
    pktOffset = wlanPacketDetect(rxWave,chanBW); % Detect packet
    
    if ~isempty(pktOffset) % If packet detected
        % Extract the L-LTF field for fine timing synchronization
        LLTFSearchBuffer = rxWave(pktOffset+(ind.LSTF(1):ind.LSIG(2)),:);
    
        % Start index of L-LTF field
        finePktOffset = wlanSymbolTimingEstimate(LLTFSearchBuffer,chanBW);
     
        % Determine final packet offset
        pktOffset = pktOffset+finePktOffset;
        
        if pktOffset<15 % If synchronization successful
            % Extract VHT-LTF samples from the waveform, demodulate and
            % perform channel estimation
            LLTF = rxWave(pktOffset+(ind.LLTF(1):ind.LLTF(2)),:);
            demodLLTF = wlanLLTFDemodulate(LLTF,chanBW);

            % Estimate noise power in NonHT fields
            noiseVarVHT = helperNoiseEstimate(demodLLTF,chanBW,cfgVHT.NumSpaceTimeStreams,'Per Antenna');

            % Estimate MIMO channel using VHT-LTF
            demodVHTLTF = wlanVHTLTFDemodulate( ...
                rxWave(pktOffset+(ind.VHTLTF(1):ind.VHTLTF(2)),:),cfgVHT);
            chanEstVHTLTF = wlanVHTLTFChannelEstimate(demodVHTLTF,cfgVHT);

            % Recover equalized symbols at data carrying subcarriers using
            % channel estimates from VHT-LTF
            [rxPSDU,~,eqDataSym] = wlanVHTDataRecover( ...
                rxWave(pktOffset + (ind.VHTData(1):ind.VHTData(2)),:), ...
                chanEstVHTLTF,mean(noiseVarVHT),cfgVHT);

            % SNR estimation per receive antenna
            rxvhtltf = rxWave(pktOffset+(ind.VHTLTF(1):ind.VHTLTF(2)),:);
            
            % Signal plus noise power
            powVHTLTF = mean(rxvhtltf.*conj(rxvhtltf));
            estSigPower = powVHTLTF-noiseVarVHT;
            estimatedSNR = 10*log10(mean(estSigPower./noiseVarVHT));
        end
    end
    
    % Set output
    Y = struct( ...
        'RxPSDU',           rxPSDU, ...
        'EqDataSym',        eqDataSym, ...
        'RxWaveformLength', rxWaveformLength, ...
        'NoiseVar',         noiseVarVHT, ...
        'EstimatedSNR',     estimatedSNR);
    
end

function plotResults(ber,packetLength,snrMeasured,MCS,cfgVHT)
    % Visualize simulation results

    figure('Outerposition',[50 50 900 700])
    subplot(4,1,1);
    plot(MCS);
    xlabel('Packet Number')
    ylabel('MCS')
    title('MCS selected for transmission')

    subplot(4,1,2);
    plot(snrMeasured);
    xlabel('Packet Number')
    ylabel('SNR')
    title('Estimated SNR')

    subplot(4,1,3);
    plot(find(ber==0),ber(ber==0),'x') 
    hold on; stem(find(ber>0),ber(ber>0),'or') 
    if any(ber)
        legend('Successful decode','Unsuccessful decode') 
    else
        legend('Successful decode') 
    end
    xlabel('Packet Number')
    ylabel('BER')
    title('Instantaneous bit error rate per packet')

    subplot(4,1,4);
    windowLength = 3; % Length of the averaging window
    movDataRate = movsum(8*cfgVHT.APEPLength.*(ber==0),windowLength)./movsum(packetLength,windowLength)/1e6;
    plot(movDataRate)
    xlabel('Packet Number')
    ylabel('Mbps')
    title(sprintf('Throughput over the duration of %d packets',windowLength))
    
end
end