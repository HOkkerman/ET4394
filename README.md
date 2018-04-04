# ET4394
This is group WN_2's github repository for the ET4394 projects  
  
Location of important files in this directory:  
#### Wireshark:   
* Final Report:   
    * Report/et4394-wireshark-assignment/et4394-wireshark-assignment.pdf  
* Report latex sources:  
    * Report/et4394-wireshark-assignment/  
* airodump-ng capture output:   
    * wireshark_airodump_captures/airodump/BUSEindhoven-01.csv  
    * wireshark_airodump_captures/airodump/trainBreada_Eindhoven-01.csv  
* airodump-ng script:  
    * wireshark_scripts/startSniffing.sh  

#### Paper Report:
* Report:
    * Report/et4394-paper-report/paper-report.pdf
* Report latex sources:
    * Report/et4394-paper-report/et4394-wireless-networking.zip

#### Rate Control Algorithm (SDR):
* Final Report:
    * Report/et4394-rate-control/et4394-rate-control.pdf
* Report latex sources:
    * Report/et4394-rate-control/et4394-rate-control.zip
* Matlab files:
    * Algorithm Sources:
        SDR/Ratecontrol/
    * Simulation Results:
        SDR/Ratecontrol/results/

#### Usage: MATLAB sources for the Rate Control Assignment:
* Source files are located in:
    * SDR/Ratecontrol/
* To simulate all agorithms for specific combinations of input parameters, run: runratecontrol.m
* To simulate individual algorithms, run:
    * Original version: 
        function [overalDataRate, PER]=ratecontrol_original(npackets, bandwidth, delay_profile, distance)
    * Moving Average version:
        function [overalDataRate, PER]=ratecontrol_average(npackets, bandwidth, delay_profile, distance, histsize)
    * Weighted Average version
        function [overalDataRate, PER]=ratecontrol_weighted(npackets, bandwidth, delay_profile, distance, weights)
    * BanditLink version
        function [overalDataRate, PER]=ratecontrol_BanditLink(npackets, bandwidth, delay_profile, distance)
    
    where:
    * npackets: Number of packets in simulated signal
    * bandwidth: Channel Bandwidth ['CBW20', 'CBW40', 'CBW80', 'CBW160']
    * delay_profile: Delay Profile model ['Model-A', 'Model-B', 'Model-C', 'Model-D', 'Model-E', 'Model-F']
    * distance: Distance between receiver and transmitter in meters.
    * histsize: Moving average window size.
    * weights: Array of weights to be used with moving average window.
