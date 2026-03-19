function results = run_monte_carlo_measurement_compare()
%==========================================================================
% 函数名称：run_monte_carlo_measurement_compare
% 功能说明：
%   对四种方法做 Monte Carlo 对比，并输出：
%   1) 轨道位置误差 / 成功率 / 平均耗时
%   2) 各状态量估计误差均值
%==========================================================================

clc; close all;

N_list = [ 5 10 30];
MC = 20;
sigma_dopp_hz = 0.5;

results.N_list = N_list;
method_names = {'traditional', 'fdoa', 'froa', 'combo'};
for i = 1:numel(method_names)
    results.(method_names{i}) = init_result_struct(numel(N_list));
end

for iN = 1:numel(N_list)
    Nobs = N_list(iN);
    fprintf('\n============================\n');
    fprintf('开始处理 Nobs = %d\n', Nobs);
    fprintf('============================\n');

    for iMethod = 1:numel(method_names)
        tmp.(method_names{iMethod}) = init_trial_array(MC); %#ok<AGROW>
    end

    for mc = 1:MC
        fprintf('  Monte Carlo %d / %d ...\n', mc, MC);
        seed = 3000 + iN * 100 + mc;
        trial = run_one_trial_measurement_compare(Nobs, seed, sigma_dopp_hz);

        for iMethod = 1:numel(method_names)
            name = method_names{iMethod};
            tmp.(name).err_pos(mc) = trial.(name).metrics.err_pos_max_km;
            tmp.(name).succ(mc) = trial.(name).metrics.success;
            tmp.(name).time(mc) = trial.(name).time_sec;
            tmp.(name).err_a(mc) = trial.(name).metrics.err_a_km;
            tmp.(name).err_lambda(mc) = trial.(name).metrics.err_lambda_deg;
            tmp.(name).err_dlambda(mc) = trial.(name).metrics.err_dlambda_deg_day;
            tmp.(name).err_fc0(mc) = trial.(name).metrics.err_fc0_hz;
            tmp.(name).err_tx_drift(mc) = trial.(name).metrics.err_tx_drift_hz_s;
            tmp.(name).err_rx1_bias(mc) = trial.(name).metrics.err_rx1_bias_hz;
            tmp.(name).err_rx1_drift(mc) = trial.(name).metrics.err_rx1_drift_hz_s;
            tmp.(name).err_rx2_bias(mc) = trial.(name).metrics.err_rx2_bias_hz;
            tmp.(name).err_rx2_drift(mc) = trial.(name).metrics.err_rx2_drift_hz_s;
            tmp.(name).err_rx_diff_bias(mc) = trial.(name).metrics.err_rx_diff_bias_hz;
            tmp.(name).err_rx_diff_drift(mc) = trial.(name).metrics.err_rx_diff_drift_hz_s;
        end
    end

    for iMethod = 1:numel(method_names)
        name = method_names{iMethod};
        results.(name).err_mean(iN) = mean(tmp.(name).err_pos);
        results.(name).succ_rate(iN) = mean(tmp.(name).succ);
        results.(name).time_mean(iN) = mean(tmp.(name).time);
        results.(name).err_a_mean(iN) = mean(tmp.(name).err_a);
        results.(name).err_lambda_mean(iN) = mean(tmp.(name).err_lambda);
        results.(name).err_dlambda_mean(iN) = mean(tmp.(name).err_dlambda);
        results.(name).err_fc0_mean(iN) = mean(tmp.(name).err_fc0);
        results.(name).err_tx_drift_mean(iN) = mean(tmp.(name).err_tx_drift);
        results.(name).err_rx1_bias_mean(iN) = mean_without_nan(tmp.(name).err_rx1_bias);
        results.(name).err_rx1_drift_mean(iN) = mean_without_nan(tmp.(name).err_rx1_drift);
        results.(name).err_rx2_bias_mean(iN) = mean_without_nan(tmp.(name).err_rx2_bias);
        results.(name).err_rx2_drift_mean(iN) = mean_without_nan(tmp.(name).err_rx2_drift);
        results.(name).err_rx_diff_bias_mean(iN) = mean_without_nan(tmp.(name).err_rx_diff_bias);
        results.(name).err_rx_diff_drift_mean(iN) = mean_without_nan(tmp.(name).err_rx_diff_drift);
    end
end

save('monte_carlo_measurement_compare_results.mat', 'results');
plot_measurement_compare_results(results);
plot_measurement_parameter_results(results);

fprintf('\nMonte Carlo 对比完成，结果已保存到 monte_carlo_measurement_compare_results.mat\n');
end

function S = init_result_struct(n)
S.err_mean = nan(1,n);
S.succ_rate = nan(1,n);
S.time_mean = nan(1,n);
S.err_a_mean = nan(1,n);
S.err_lambda_mean = nan(1,n);
S.err_dlambda_mean = nan(1,n);
S.err_fc0_mean = nan(1,n);
S.err_tx_drift_mean = nan(1,n);
S.err_rx1_bias_mean = nan(1,n);
S.err_rx1_drift_mean = nan(1,n);
S.err_rx2_bias_mean = nan(1,n);
S.err_rx2_drift_mean = nan(1,n);
S.err_rx_diff_bias_mean = nan(1,n);
S.err_rx_diff_drift_mean = nan(1,n);
end

function T = init_trial_array(MC)
fields = {'err_pos','succ','time','err_a','err_lambda','err_dlambda', ...
    'err_fc0','err_tx_drift','err_rx1_bias','err_rx1_drift', ...
    'err_rx2_bias','err_rx2_drift','err_rx_diff_bias','err_rx_diff_drift'};
for i = 1:numel(fields)
    T.(fields{i}) = nan(MC,1);
end
end

function v = mean_without_nan(x)
x = x(~isnan(x));
if isempty(x)
    v = NaN;
else
    v = mean(x);
end
end
