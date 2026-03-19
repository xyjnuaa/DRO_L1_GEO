function J = pure_fdoa_cost_function(x, data)
% 纯 FDOA 目标函数：只拟合差分频率量测。

if ~is_valid_radio_state(x(1:5), data)
    J = 1e30;
    return;
end

x_geo = x(1:3);
radio = struct( ...
    'fc0_hz', x(4), ...
    'tx_drift_hz_s', x(5), ...
    'rx1_bias_hz', 0, ...
    'rx1_drift_hz_s', 0, ...
    'rx2_bias_hz', 0, ...
    'rx2_drift_hz_s', 0);

pred = predict_radio_measurements(x_geo, radio, data);
res = (data.z.fdoa_hz - pred.fdoa_hz) / data.meas.sigma_fdoa;
J = sum(res.^2);
J = J + (x(5) / 0.05)^2;
end
