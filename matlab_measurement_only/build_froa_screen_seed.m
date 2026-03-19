function seed_geo = build_froa_screen_seed(data)
%==========================================================================
% 函数名称：build_froa_screen_seed
% 功能说明：
%   用 FROA 先做一个较粗的三维网格搜索，
%   找到 [a, lambda0, dlambda] 的较优起点，供后续 FDOA 精估使用。
%
% 说明：
%   为了控制计算量，这里的粗搜索只使用“理想无接收机偏差”的 FROA 几何模型，
%   目的是缩小搜索域，而不是直接给出最终最优解。
%==========================================================================

a_grid = data.const.geo_a_km + (-600:75:600);
lambda_grid = 96:2:124;
dlambda_grid = -0.10:0.02:0.14;

best_cost = inf;
seed_geo = [data.const.geo_a_km, 100.0, 0.0];

for ia = 1:numel(a_grid)
    for il = 1:numel(lambda_grid)
        for id = 1:numel(dlambda_grid)
            x_geo = [a_grid(ia), lambda_grid(il), dlambda_grid(id)];
            radio0 = estimate_initial_radio_params(x_geo, data, 'traditional');
            pred = predict_radio_measurements(x_geo, radio0, data);
            cost = sum(((data.z.froa - pred.froa) / data.meas.sigma_froa).^2);
            if cost < best_cost
                best_cost = cost;
                seed_geo = x_geo;
            end
        end
    end
end
end
