%This file is used to run ratecontrol.m with specific input settings.
%Ratecontrol.m is the same file as TransmitRateControlExample.m, except its
%contents are turned into a large function. Some settings that control the
%wireless channel can be set as inputs which eases simulating many
%different channel types. 
%
%

%TODO: Put the rate control algorithm in its own separate function to ease
%editing and changing algorithms

%Bandwidth of channel. Can be CBW20, CBW40, CBW80 or CBW160
bandwidth_i=['CBW20 '; 'CBW40 '; 'CBW80 '; 'CBW160'];
bandwidth=cellstr(bandwidth_i);

%Delay profile model. Can be Model-A through Model-F. Higher is more
%reflections and larger delays
delay_profile_i=['Model-A'; 'Model-B'; 'Model-C'; 'Model-D'; 'Model-E'; 'Model-F' ];
delay_profile=cellstr(delay_profile_i);
%Distance is the distance between Tx and Rx. Determines if there is a LOS
%condition based on the chosen delay profile.
distance=8;
npackets=500;

% distance based on bandwidth
breakpoint_distance = [1 2 3 4 5; 1 2 3 4 5; 1 2 3 4 5; 2 4 6 8 10; 4 8 12 16 20; 4 12 18 24 30];

historysize=6;

% weights=ones(1,historysize);
weights=[1,1,2,2,3,5];



% supress warnings
warning('off', 'wlan:shared:PSDULengthInvalidMCSCombination');

avg_datarate=zeros(length(bandwidth), length(delay_profile));
resultsCounter = 1;
results_dataRate = cell(450, 7);
results_per = cell(450, 7);
results_dataRate (1, :) = {'Bandwidth', 'DelayProfile', 'Distance', 'Original', 'MovingAverage', 'WeightedAverage', 'BanditLink'};
results_per (1, :) = {'Bandwidth', 'DelayProfile', 'Distance', 'Original', 'MovingAverage', 'WeightedAverage', 'BanditLink'};
for bw=1:length(bandwidth)
    for dp=1:length(delay_profile)
        for dist = breakpoint_distance(dp, 1:5)
            resultsCounter = resultsCounter + 1
            bandwidth_in=char(bandwidth(bw));
            delay_profile_in=char(delay_profile(dp));
            distance_in=dist;

            [avg1, per1] = ratecontrol_old(npackets, bandwidth_in, delay_profile_in, distance_in);
            [avg2, per2] = ratecontrol(npackets, bandwidth_in, delay_profile_in, distance_in, historysize);
            [avg3, per3] = ratecontrol_weighted(npackets, bandwidth_in, delay_profile_in, distance_in, weights);
            [avg4, per4] = ratecontrol_BanditLink(npackets, bandwidth_in, delay_profile_in, distance_in);
            results_dataRate(resultsCounter, :) = {bandwidth_in, delay_profile_in, distance_in, avg1, avg2, avg3, avg4};
            results_per(resultsCounter, :) = {bandwidth_in, delay_profile_in, distance_in, per1, per2, per3, per4};
        end
    end
end

warning('on', 'wlan:shared:PSDULengthInvalidMCSCombination');

results_dataRate
results_per
% mov = ratecontrol(bandwidth_in, delay_profile_in, distance_in);
% avg_datarate=mean(mov);

