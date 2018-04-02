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

historysize=6;
% weights=ones(1,historysize);
weights=[1,1,2,2,3,5];




avg_datarate=zeros(length(bandwidth), length(delay_profile));

for bw=2:2%length(bandwidth)
    for dp=4:4%length(delay_profile)
        bandwidth_in=char(bandwidth(bw));
        delay_profile_in=char(delay_profile(dp));
        distance_in=distance;
       
%         [avg1, mov1] = ratecontrol_old(npackets, bandwidth_in, delay_profile_in, distance_in);
%         [avg2, mov2] = ratecontrol(npackets, bandwidth_in, delay_profile_in, distance_in, historysize);
        [avg3, mov3] = ratecontrol_weighted(npackets, bandwidth_in, delay_profile_in, distance_in, weights);    
    end


end
        

% mov = ratecontrol(bandwidth_in, delay_profile_in, distance_in);
% avg_datarate=mean(mov);

