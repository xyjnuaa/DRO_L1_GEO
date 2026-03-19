function seed_geo = build_common_geo_seed(data)
%==========================================================================
% 函数名称：build_common_geo_seed
% 功能说明：
%   用单路非差多普勒的线性最小二乘残差做 GEO 粗搜索，
%   给传统方法、纯 FDOA 和纯 FROA 提供一个更稳健的几何初值。
%==========================================================================

a_grid = data.const.geo_a_km + (-600:75:600);
lambda_grid = 96:2:124;
dlambda_grid = -0.10:0.02:0.14;

best_cost = inf;
seed_geo = [data.const.geo_a_km, 110.0, 0.0];

for ia = 1:numel(a_grid)
    for il = 1:numel(lambda_grid)
        for id = 1:numel(dlambda_grid)
            x_geo = [a_grid(ia), lambda_grid(il), dlambda_grid(id)];
            radio0 = estimate_initial_radio_params(x_geo, data, 'traditional');
            pred = predict_radio_measurements(x_geo, radio0, data);
            cost = sum(((data.z.f1_hz - pred.f1_hz) / data.meas.sigma_f1).^2) + ...
                   sum(((data.z.f2_hz - pred.f2_hz) / data.meas.sigma_f2).^2);
            if cost < best_cost
                best_cost = cost;
                seed_geo = x_geo;
            end
        end
    end
end
end
