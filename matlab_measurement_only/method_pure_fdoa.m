function result = method_pure_fdoa(data, seed_geo)
%==========================================================================
% 函数名称：method_pure_fdoa
% 功能说明：
%   纯 FDOA 方法。
%
% 说明：
%   在完美接收机时钟假设下，FDOA 中不再包含接收机差分偏差项，
%   这里只估计：
%   [fc0, tx_drift]
%==========================================================================

if nargin < 2 || isempty(seed_geo)
    seed_geo = build_common_geo_seed(data);
end

radio0 = estimate_initial_radio_params(seed_geo, data, 'fdoa');
x0 = [seed_geo(:).', radio0.fc0_hz, radio0.tx_drift_hz_s];

objfun = @(x) pure_fdoa_cost_function(x, data);
opts = optimset('Display','off', 'TolX',1e-6, 'TolFun',1e-8, ...
    'MaxFunEvals',2500, 'MaxIter',1800);

tic;
[xhat, fval] = fminsearch(objfun, x0, opts);
elapsed = toc;

result.name = '纯FDOA';
result.kind = 'fdoa';
result.xhat = xhat;
result.est = unpack_estimate_vector(xhat, 'fdoa');
result.fval = fval;
result.time_sec = elapsed;
result.success = true;
end
