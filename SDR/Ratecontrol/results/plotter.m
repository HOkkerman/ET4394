%This script will make graphs of the simulation results
close all
load 'Original_avg.mat'
load 'Average_avg.mat'
load 'Weighted_avg.mat'
load 'Bandit_avg.mat'

load 'Original_per.mat'
load 'Average_per.mat'
load 'Weighted_per.mat'
load 'Bandit_per.mat'

model=categorical({'A','B','C','D','E','F'});
bandwidth_i=['CBW20 '; 'CBW40 '; 'CBW80 '; 'CBW160'];
bandwidth=cellstr(bandwidth_i);

for d=1:2
    figure()

    for bw=1:4
        avg=[avg_original(bw,:,d);avg_average(bw,:,d);avg_weighted(bw,:,d);avg_bandit(bw,:,d)]';
        subplot(2,2,bw)
        fig=bar(model,avg);
        title(['Bandwidth: ' bandwidth(bw)])
        xlabel('Delay model:')
        ylabel('Throughput (MHz):')
        names={'O', 'A', 'W', 'B'};
        legend(fig, names)
    end  
end





for d=1:2
    figure()

    for bw=1:4
        per=[PER_original(bw,:,d);PER_average(bw,:,d);PER_weighted(bw,:,d);PER_bandit(bw,:,d)]';
        subplot(2,2,bw)
        fig=bar(model,per);
        title(['Bandwidth: ' bandwidth(bw)])
        xlabel('Delay model:')
        ylabel('Package error rate:')
        names={'O', 'A', 'W', 'B'};
        legend(fig, names)
    end  
end

mean_o=mean(avg_original(4,:,2))
mean_a=mean(avg_average(4,:,2))
mean_w=mean(avg_weighted(4,:,2))
mean_b=mean(avg_bandit(4,:,2))
