function J = traditional_cost_function(x, data)
% 传统非差多普勒目标函数：直接拟合两条单路频率量测。

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

r1 = (data.z.f1_hz - pred.f1_hz) / data.meas.sigma_f1;
r2 = (data.z.f2_hz - pred.f2_hz) / data.meas.sigma_f2;

J = sum(r1.^2) + sum(r2.^2);
J = J + (x(5) / 0.05)^2;
end
