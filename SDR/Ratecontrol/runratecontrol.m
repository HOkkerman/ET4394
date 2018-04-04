%This file is used to run ratecontrol.m with specific input settings.
%Ratecontrol.m is the same file as TransmitRateControlExample.m, except its
%contents are turned into a large function. Some settings that control the
%wireless channel can be set as inputs which eases simulating many
%different channel types. 
%
%

%Bandwidth of channel. Can be CBW20, CBW40, CBW80 or CBW160
bandwidth_i=['CBW20 '; 'CBW40 '; 'CBW80 '; 'CBW160'];
bandwidth=cellstr(bandwidth_i);

%Delay profile model. Can be Model-A through Model-F. Higher is more
%reflections and larger delays
delay_profile_i=['Model-A'; 'Model-B'; 'Model-C'; 'Model-D'; 'Model-E'; 'Model-F' ];
delay_profile=cellstr(delay_profile_i);
%Distance is the distance between Tx and Rx. Determines if there is a LOS
%condition based on the chosen delay profile.
%distance=10;

npackets=50;
historysize=6;
% weights=ones(1,historysize);
weights=[1,1,2,2,3,5];

breakpoint_distance = [5; 5; 5; 10; 20; 30];

%Initialize arrays for results
%Average throughput
avg_original=zeros(length(bandwidth), length(delay_profile), 3);
avg_average=zeros(length(bandwidth), length(delay_profile), 3);
avg_weighted=zeros(length(bandwidth), length(delay_profile), 3);
avg_bandit=zeros(length(bandwidth), length(delay_profile), 3);
%Bit error rate
PER_original=zeros(length(bandwidth), length(delay_profile), 3);
PER_average=zeros(length(bandwidth), length(delay_profile), 3);
PER_weighted=zeros(length(bandwidth), length(delay_profile), 3);
PER_bandit=zeros(length(bandwidth), length(delay_profile), 3);

% supress warnings
warning('off', 'wlan:shared:PSDULengthInvalidMCSCombination');
warning('off', 'wlan:helperSampleRate:Deprecation');

datetime('now')

tic
for bw=1:4
    for dp=1:6
        for d=1:3
            %Display these values to know what iteration the program is in
            %Current bandwidth
            bandwidth_in=char(bandwidth(bw))
            %Current delay profile
            delay_profile_in=char(delay_profile(dp))
            %Current distance. Program goes through breakpoint distance
            %times 0.5, 1 and 1.5
            distance_in=d*0.5*breakpoint_distance(dp)

            %Run all 4 models and store results in fuckhueg arrays
            [avg_original(bw, dp, d), PER_original(bw, dp, d)] = ratecontrol_old(npackets, bandwidth_in, delay_profile_in, distance_in);
            datetime('now')
            [avg_average(bw, dp, d), PER_average(bw, dp, d)] = ratecontrol(npackets, bandwidth_in, delay_profile_in, distance_in, historysize);
            datetime('now')
            [avg_weighted(bw, dp, d), PER_weighted(bw, dp, d)] = ratecontrol_weighted(npackets, bandwidth_in, delay_profile_in, distance_in, weights);  
            datetime('now')
            [avg_bandit(bw, dp, d), PER_bandit(bw, dp, d)] = ratecontrol_BanditLink(npackets, bandwidth_in, delay_profile_in, distance_in);
            datetime('now')
        end
    end
end
toc
