function plot_measurement_parameter_results(results)
%==========================================================================
% 函数名称：plot_measurement_parameter_results
% 功能说明：
%   绘制关键状态量的 Monte Carlo 平均误差曲线。
%==========================================================================

N_list = results.N_list;
styles = {'ks-','bo-','r^-','md-'};
fields = {'traditional','fdoa','froa','combo'};
labels = {'传统非差多普勒','纯FDOA','纯FROA','FROA筛选+FDOA'};

figure('Color','w');

subplot(2,2,1); hold on;
for i = 1:numel(fields)
    plot(N_list, results.(fields{i}).err_a_mean, styles{i}, ...
        'LineWidth',1.5, 'MarkerFaceColor', styles{i}(1));
end
grid on;
xlabel('历元数 Nobs');
ylabel('半长轴误差 (km)');
title('半长轴估计误差');
legend(labels, 'Location', 'best');

subplot(2,2,2); hold on;
for i = 1:numel(fields)
    plot(N_list, results.(fields{i}).err_lambda_mean, styles{i}, ...
        'LineWidth',1.5, 'MarkerFaceColor', styles{i}(1));
end
grid on;
xlabel('历元数 Nobs');
ylabel('初始经度误差 (deg)');
title('初始经度估计误差');

subplot(2,2,3); hold on;
for i = 1:numel(fields)
    plot(N_list, results.(fields{i}).err_fc0_mean, styles{i}, ...
        'LineWidth',1.5, 'MarkerFaceColor', styles{i}(1));
end
grid on;
xlabel('历元数 Nobs');
ylabel('载频误差 (Hz)');
title('发射源初始载频估计误差');

subplot(2,2,4); hold on;
for i = 1:numel(fields)
    plot(N_list, results.(fields{i}).err_rx_diff_bias_mean, styles{i}, ...
        'LineWidth',1.5, 'MarkerFaceColor', styles{i}(1));
end
grid on;
xlabel('历元数 Nobs');
ylabel('差分频偏误差 (Hz)');
title('接收机差分频偏估计误差');
end
