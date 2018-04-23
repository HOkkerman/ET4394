%This file is used to run ratecontrol_xxxxx.m with specific input settings.
%Ratecontrol_xxxx.m is the same file as TransmitRateControlExample.m,
%except its contents are turned into a large function and the actual rate
%control algorithm varies based on the name. Some settings that control the
%wireless channel can be set as inputs which eases simulating many
%different channel types.
%
%

%Bandwidth of channel. Can be 20, 40, 80 or 160MHz
bandwidth_i=['CBW20 '; 'CBW40 '; 'CBW80 '; 'CBW160'];
bandwidth=cellstr(bandwidth_i);

%Delay profile model. Can be Model-A through Model-F. Higher is more
%reflections and larger delays
delay_profile_i=['Model-A'; 'Model-B'; 'Model-C'; 'Model-D'; 'Model-E'; 'Model-F' ];
delay_profile=cellstr(delay_profile_i);

%Amount of packets to simulate
npackets=500;

%History size for averaging algorithm
historysize=6;

%Weights for weighted averaging algorithm
weights=[1,1,2,2,3,5];

%Breakpoint distances for corresponding delay models
breakpoint_distance = [5; 5; 5; 10; 20; 30];

%Initialize arrays for results just for fancy reasons
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

% supress annoying warnings
warning('off', 'wlan:shared:PSDULengthInvalidMCSCombination');
warning('off', 'wlan:helperSampleRate:Deprecation');

%Log time spent simulating between each result
datetime('now')

%Log total time
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

            %Run all 4 models and store results in arrays. Also print times
            [avg_original(bw, dp, d), PER_original(bw, dp, d)] = ratecontrol_original(npackets, bandwidth_in, delay_profile_in, distance_in);
            datetime('now')
            [avg_average(bw, dp, d), PER_average(bw, dp, d)] = ratecontrol_average(npackets, bandwidth_in, delay_profile_in, distance_in, historysize);
            datetime('now')
            [avg_weighted(bw, dp, d), PER_weighted(bw, dp, d)] = ratecontrol_weighted(npackets, bandwidth_in, delay_profile_in, distance_in, weights);  
            datetime('now')
            [avg_bandit(bw, dp, d), PER_bandit(bw, dp, d)] = ratecontrol_BanditLink(npackets, bandwidth_in, delay_profile_in, distance_in);
            datetime('now')
        end
    end
end
toc
