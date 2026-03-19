function plot_measurement_compare_results(results)
%==========================================================================
% 函数名称：plot_measurement_compare_results
% 功能说明：
%   绘制四种方法在 Monte Carlo 下的总体比较结果：
%   1) 最大位置误差均值
%   2) 成功率
%   3) 平均耗时
%==========================================================================

N_list = results.N_list;
styles = {'ks-','bo-','r^-','md-'};
fields = {'traditional','fdoa','froa','combo'};
labels = {'传统非差多普勒','纯FDOA','纯FROA','FROA筛选+FDOA'};

figure('Color','w');

subplot(3,1,1); hold on;
for i = 1:numel(fields)
    plot(N_list, results.(fields{i}).err_mean, styles{i}, ...
        'LineWidth',1.5, 'MarkerFaceColor', styles{i}(1));
end
grid on;
ylabel('最大位置误差均值 (km)');
legend(labels, 'Location', 'best');
title('Monte Carlo 对比：四种方法总体表现');

subplot(3,1,2); hold on;
for i = 1:numel(fields)
    plot(N_list, results.(fields{i}).succ_rate, styles{i}, ...
        'LineWidth',1.5, 'MarkerFaceColor', styles{i}(1));
end
grid on;
ylabel('成功率');

subplot(3,1,3); hold on;
for i = 1:numel(fields)
    plot(N_list, results.(fields{i}).time_mean, styles{i}, ...
        'LineWidth',1.5, 'MarkerFaceColor', styles{i}(1));
end
grid on;
xlabel('历元数 Nobs');
ylabel('平均耗时 (s)');
end
