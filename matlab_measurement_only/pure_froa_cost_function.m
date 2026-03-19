function J = pure_froa_cost_function(x, data)
% 纯 FROA 目标函数：只拟合频率比量测。

if ~is_valid_radio_state([x(1:3), data.meas.fc_nominal_hz, x(4)], data)
    J = 1e30;
    return;
end

x_geo = x(1:3);
radio = struct( ...
    'fc0_hz', data.meas.fc_nominal_hz, ...
    'tx_drift_hz_s', x(4), ...
    'rx1_bias_hz', 0, ...
    'rx1_drift_hz_s', 0, ...
    'rx2_bias_hz', 0, ...
    'rx2_drift_hz_s', 0);

pred = predict_radio_measurements(x_geo, radio, data);
res = (data.z.froa - pred.froa) / data.meas.sigma_froa;
J = sum(res.^2);
J = J + (x(4) / 0.05)^2;
end
