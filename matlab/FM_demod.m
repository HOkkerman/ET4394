function [z_out, z_B2, z_N2, z_dis, y_N1, y_B1]=FM_demod(x, B1, N1, B2, N2, fs)
%Simple FM demodulator for pre-recorded rf data centered at station of
%interest.
%Outputs:
%z_out is final demodulated audio
%z_B2  is signal after second LPF
%z_N2  is signal after second decimation
%z_dis is signal after discriminator
%y_N1  is signal after first decimation
%y_B1  is signal after first LPF
%Inputs:
%x     is prerecorded data
%B1    is cutoff frequency for first LPF
%N1    is factor for first decimator
%B2    is cutoff frequency for second LPF
%N2    is factor for second decimator
%fs    is sample frequency of input data
%
% Example input for assignment: FM_demod(x,80000, 10, 16000, 5, 2400000);

%Lowpass filter 1------------------------------------------------------
%Butter
order=6;
[b_1,a_1] = butter(order,B1/(fs/2));
y_B1=filter(b_1,a_1,x);

%Windowed
%order=63;
%b_1=fir1(order,B1/(fs/2));
%y_B1=filter(b_1,1,x);


%Downsampling 1---------------------------------------------------------
%decimate(x,r) includes LPF which would be redundant
%so downsample(x,n) is used instead
y_N1=downsample(y_B1,N1);
fs_1=fs/N1;


%Discriminator----------------------------------------------------------
z_dis=discrim(y_N1);


%Lowpass filter 2-------------------------------------------------------
%Butter
order=6;
[b_2,a_2] = butter(order,B2/(fs_1/2));
z_B2=filter(b_2,a_2,z_dis);

%Windowed
%order=63;
%b_2=fir1(order,B1/(fs_1/2));
%z_B2=filter(b_2,1,z_dis);



%Downsampling 2---------------------------------------------------------
z_N2=downsample(z_B2,N2);
fs_2=fs_1/N2;

%soundsc(z_N2, fs_2);

%De-emphasis filter-----------------------------------------------------
%Emphasis time constant (Europe: 50us, US: 75us)
tau=50*10^-6;
%Feedback coefficient
a1=exp(-1/(tau*fs_2));
%Filters
a=[1,-a1];
b=[1-a1];
%Final audio output----------------------------------------------------
z_out=filter(b,a,z_N2);


%soundsc(z_N2, fs_2);
%simpleSA(z_out,2^14,fs_2);

