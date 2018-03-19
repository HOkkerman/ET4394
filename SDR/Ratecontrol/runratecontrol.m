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
bandwidth='CBW20';
%Delay profile model. Can be Model-A through Model-F. Higher is more
%reflections and larger delays
delay_profile='Model-A';
%Distance is the distance between Tx and Rx. Determines if there is a LOS
%condition based on the chosen delay profile.
distance=3;

ratecontrol(bandwidth, delay_profile, distance);

