function [] = beaconFrameGeneration()
% SDR setup
useSDR = false;
saveToFile = true;
bbFileName = 'nonHTBeaconPacket.bb';

% Create beacon frame
SSID = 'TEST_BEACON'; % Network SSID
beaconInterval = 100; % In Time units (TU)
band = 5;             % Band, 5 or 2.4 GHz
chNum = 52;           % Channel number, corresponds to 5260MHz

% Generate Beacon frame
[mpduBits,fc] = helperGenerateBeaconFrame(chNum, band, beaconInterval, SSID);

% Create Beacon packet
cfgNonHT = wlanNonHTConfig;              % Create a wlanNonHTConfig object
cfgNonHT.PSDULength = numel(mpduBits)/8; % Set the PSDU length in bits

% The idle time is the length in seconds of an idle period after each
% generated packet. The idle time is set to the beacon interval.
txWaveform = wlanWaveformGenerator(mpduBits, cfgNonHT, 'IdleTime', beaconInterval*1024e-6);
Rs = wlanSampleRate(cfgNonHT);           % Get the input sampling rate

% Save waveform to file
if saveToFile
    % The waveform is stored in a baseband file
    BBW = comm.BasebandFileWriter(bbFileName, Rs, fc); %#ok<UNRCH>
    BBW(txWaveform);
    release(BBW);
end

% Display waveform data from file
if saveToFile
    bbr = comm.BasebandFileReader(bbFileName);
    sampleRate = bbr.SampleRate
    centerFrequency = bbr.CenterFrequency
    numChannels = bbr.NumChannels
    metadata = bbr.Metadata
    samplesPerFrame = bbr.SamplesPerFrame
    cyclicRepetition = bbr.CyclicRepetition
    release(bbr);
end

% Configure transmission
if useSDR
    tx = sdrtx('ZedBoard and FMCOMMS2/3/4'); %#ok<UNRCH>
    tx.ShowAdvancedProperties = true;
    tx.BypassUserLogic = true;
    osf = 2; % OverSampling factor
    tx.BasebandSampleRate = Rs*osf;
    % The center frequency is set to the corresponding channel number
    tx.CenterFrequency = fc;
end

% Transmission with an SDR device
if useSDR
    % Set transmit gain
    tx.Gain = 0;  %#ok<UNRCH>
    % Resample transmit waveform
    txWaveform = resample(txWaveform, osf, 1);
    % Transmit over-the-air
    transmitRepeat(tx, txWaveform);
end