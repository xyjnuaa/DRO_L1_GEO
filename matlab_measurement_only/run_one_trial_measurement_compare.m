function trial = run_one_trial_measurement_compare(Nobs, seed, sigma_dopp_hz)
%==========================================================================
% 函数名称：run_one_trial_measurement_compare
% 功能说明：
%   在完全相同的一组真值轨道、无线电参数和带噪量测下，
%   公平比较四种方法：
%   1) 传统非差多普勒
%   2) 纯 FDOA
%   3) 纯 FROA
%   4) FROA 先筛选搜索域，再用 FDOA 精估
%==========================================================================

if nargin < 3 || isempty(sigma_dopp_hz)
    sigma_dopp_hz = 0.05;
end

data = build_demo_case_joint(Nobs, seed, sigma_dopp_hz);

trial.traditional = method_traditional_nondiff(data);
trial.fdoa = method_pure_fdoa(data);
trial.froa = method_pure_froa(data);
trial.combo = method_froa_screen_then_fdoa(data);

trial.traditional.metrics = extract_estimation_metrics(trial.traditional.est, data);
trial.fdoa.metrics = extract_estimation_metrics(trial.fdoa.est, data);
trial.froa.metrics = extract_estimation_metrics(trial.froa.est, data);
trial.combo.metrics = extract_estimation_metrics(trial.combo.est, data);

trial.data = data;
end
