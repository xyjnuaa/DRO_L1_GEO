function result = method_froa_screen_then_fdoa(data)
%==========================================================================
% 函数名称：method_froa_screen_then_fdoa
% 功能说明：
%   先利用 FROA 做三维粗搜索，缩小 GEO 参数搜索域，
%   再用 FROA + FDOA 联合目标函数做局部精估。
%==========================================================================

seed_froa = build_froa_screen_seed(data);
seed_common = build_common_geo_seed(data);
seed_list = [seed_froa; seed_common];

objfun = @(x) joint_fdoa_froa_cost_function(x, data);
opts = optimset('Display','off', 'TolX',1e-6, 'TolFun',1e-10, ...
    'MaxFunEvals',3000, 'MaxIter',2000);

best_fval = inf;
best_xhat = [];
best_seed = seed_froa;

tic;
for i = 1:size(seed_list, 1)
    seed_geo = seed_list(i,:);
    radio0 = estimate_initial_radio_params(seed_geo, data, 'joint');
    x0 = [seed_geo(:).', radio0.fc0_hz, radio0.tx_drift_hz_s];
    [xhat_i, fval_i] = fminsearch(objfun, x0, opts);
    if fval_i < best_fval
        best_fval = fval_i;
        best_xhat = xhat_i;
        best_seed = seed_geo;
    end
end
elapsed = toc;

result.name = 'FROA筛选+联合精估';
result.kind = 'joint';
result.seed_geo = best_seed;
result.xhat = best_xhat;
result.est = unpack_estimate_vector(best_xhat, 'joint');
result.fval = best_fval;
result.time_sec = elapsed;
result.success = true;
end
