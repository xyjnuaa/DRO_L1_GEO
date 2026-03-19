function main_demo_measurement_compare()
%==========================================================================
% 函数名称：main_demo_measurement_compare
% 功能说明：
%   单次演示入口。
%
% 演示内容：
%   在“接收机时钟完美”的假设下，比较四种方法对 GEO 轨道参数
%   和发射源频率参数的估计能力：
%   1) 传统非差多普勒
%   2) 纯 FDOA
%   3) 纯 FROA
%   4) FROA 先筛选搜索域，再做 FROA+FDOA 联合精估
%==========================================================================

clc; clear; close all;

Nobs = 10;
seed = 2025;
sigma_dopp_hz = 0.05;

trial = run_one_trial_measurement_compare(Nobs, seed, sigma_dopp_hz);

fprintf('\n==================== 单次测量体制对比结果 ====================\n');
print_metrics('传统非差多普勒', trial.traditional.metrics);
print_metrics('纯FDOA', trial.fdoa.metrics);
print_metrics('纯FROA', trial.froa.metrics);
print_metrics('FROA筛选+联合精估', trial.combo.metrics);

method_labels = {'传统非差', '纯FDOA', '纯FROA', 'FROA筛选+联合'};
err_a = [trial.traditional.metrics.err_a_km, trial.fdoa.metrics.err_a_km, ...
    trial.froa.metrics.err_a_km, trial.combo.metrics.err_a_km];
err_lambda = [trial.traditional.metrics.err_lambda_deg, trial.fdoa.metrics.err_lambda_deg, ...
    trial.froa.metrics.err_lambda_deg, trial.combo.metrics.err_lambda_deg];
err_fc0 = [trial.traditional.metrics.err_fc0_hz, trial.fdoa.metrics.err_fc0_hz, ...
    trial.froa.metrics.err_fc0_hz, trial.combo.metrics.err_fc0_hz];
err_tx_drift = [trial.traditional.metrics.err_tx_drift_hz_s, trial.fdoa.metrics.err_tx_drift_hz_s, ...
    trial.froa.metrics.err_tx_drift_hz_s, trial.combo.metrics.err_tx_drift_hz_s];

figure('Color', 'w');

subplot(2,2,1);
bar(err_a);
set(gca, 'XTickLabel', method_labels);
xtickangle(20);
ylabel('半长轴误差 (km)');
title('半长轴估计误差');
grid on;

subplot(2,2,2);
bar(err_lambda);
set(gca, 'XTickLabel', method_labels);
xtickangle(20);
ylabel('初始经度误差 (deg)');
title('初始经度估计误差');
grid on;

subplot(2,2,3);
bar(err_fc0);
set(gca, 'XTickLabel', method_labels);
xtickangle(20);
ylabel('载频估计误差 (Hz)');
title('发射源初始载频估计误差');
grid on;

subplot(2,2,4);
bar(err_tx_drift);
set(gca, 'XTickLabel', method_labels);
xtickangle(20);
ylabel('频漂估计误差 (Hz/s)');
title('发射源频漂估计误差');
grid on;
end

function print_metrics(name, m)
fprintf('\n%s：\n', name);
fprintf('  最大位置误差       = %.6f km\n', m.err_pos_max_km);
fprintf('  半长轴误差         = %.6f km\n', m.err_a_km);
fprintf('  初始经度误差       = %.6f deg\n', m.err_lambda_deg);
fprintf('  经度漂移率误差     = %.6f deg/day\n', m.err_dlambda_deg_day);
fprintf('  载频估计误差       = %.6f Hz\n', m.err_fc0_hz);
fprintf('  发射源频漂误差     = %.6f Hz/s\n', m.err_tx_drift_hz_s);
fprintf('  接收机1频偏误差    = %.6f Hz\n', m.err_rx1_bias_hz);
fprintf('  接收机1频漂误差    = %.6f Hz/s\n', m.err_rx1_drift_hz_s);
fprintf('  接收机2频偏误差    = %.6f Hz\n', m.err_rx2_bias_hz);
fprintf('  接收机2频漂误差    = %.6f Hz/s\n', m.err_rx2_drift_hz_s);
fprintf('  接收机差分频偏误差 = %.6f Hz\n', m.err_rx_diff_bias_hz);
fprintf('  接收机差分频漂误差 = %.6f Hz/s\n', m.err_rx_diff_drift_hz_s);
end
