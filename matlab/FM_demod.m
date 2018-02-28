function [z_out, z_B2, z_N2, z_dis, y_N1, y_B1]=FM_demod(x, B1, N1, B2, N2, fs)
% subplot(4,1,1)
% simpleSA(x, 2^14,fs/1000);

%Lowpass filter 1
%Butter
order=6;
[b_1,a_1] = butter(order,B1/(fs/2));
y_B1=filter(b_1,a_1,x);

%Windowed
%order=63;
%b_1=fir1(order,B1/(fs/2));
%y_B1=filter(b_1,1,x);

% subplot(4,1,2)
% simpleSA(y_B1, 2^14,fs/1000);

%Downsampling 1
%decimate(x,r) includes LPF which would be redundant
%so downsample(x,n) is used instead
y_N1=downsample(y_B1,N1);
fs_1=fs/N1;

% subplot(4,1,3)
% simpleSA(y_N1, 2^14,fs_1/1000);

%Discriminator
z_dis=discrim(y_N1);

% subplot(4,1,4)
% simpleSA(z_dis, 2^14,fs_1/1000);

%Lowpass filter 2
%Butter
order=6;
[b_2,a_2] = butter(order,B2/(fs_1/2));
z_B2=filter(b_2,a_2,z_dis);

%Windowed
%order=63;
%b_2=fir1(order,B1/(fs_1/2));
%z_B2=filter(b_2,1,z_dis);



%Downsampling 2
z_N2=downsample(z_B2,N2);
fs_2=fs_1/N2;

%simpleSA(z_B2, 2^14,fs_1/1000);
soundsc(z_N2, fs_2);