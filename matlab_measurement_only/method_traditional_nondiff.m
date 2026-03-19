function result = method_traditional_nondiff(data)
%==========================================================================
% 函数名称：method_traditional_nondiff
% 功能说明：
%   传统非差多普勒方法。
%
% 核心思想：
%   在“接收机时钟完美”的假设下，直接利用两条单路频率量测 f1、f2 建立目标函数，
%   只估计：
%   [a, lambda0, dlambda, fc0, tx_drift]
%==========================================================================

seed_geo = build_common_geo_seed(data);
radio0 = estimate_initial_radio_params(seed_geo, data, 'traditional');
x0 = [...
    seed_geo(:).', ...
    radio0.fc0_hz, ...
    radio0.tx_drift_hz_s];

objfun = @(x) traditional_cost_function(x, data);
opts = optimset('Display','off', 'TolX',1e-6, 'TolFun',1e-8, ...
    'MaxFunEvals',4000, 'MaxIter',2500);

tic;
[xhat, fval] = fminsearch(objfun, x0, opts);
elapsed = toc;

result.name = '传统非差多普勒';
result.kind = 'traditional';
result.xhat = xhat;
result.est = unpack_estimate_vector(xhat, 'traditional');
result.fval = fval;
result.time_sec = elapsed;
result.success = true;
end
