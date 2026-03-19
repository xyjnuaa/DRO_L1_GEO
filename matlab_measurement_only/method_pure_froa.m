function result = method_pure_froa(data)
%==========================================================================
% 函数名称：method_pure_froa
% 功能说明：
%   纯 FROA 方法。
%
% 说明：
%   在完美接收机时钟假设下，FROA 对共同载频幅值并不敏感，
%   因而这里主要估计：
%   [a, lambda0, dlambda, tx_drift]
%==========================================================================

seed_geo = build_common_geo_seed(data);
radio0 = estimate_initial_radio_params(seed_geo, data, 'joint');
x0 = [...
    seed_geo(:).', ...
    radio0.tx_drift_hz_s];

objfun = @(x) pure_froa_cost_function(x, data);
opts = optimset('Display','off', 'TolX',1e-6, 'TolFun',1e-10, ...
    'MaxFunEvals',4000, 'MaxIter',2500);

tic;
[xhat, fval] = fminsearch(objfun, x0, opts);
elapsed = toc;

result.name = '纯FROA';
result.kind = 'froa';
result.xhat = xhat;
result.est = unpack_estimate_vector(xhat, 'froa');
result.fval = fval;
result.time_sec = elapsed;
result.success = true;
end
