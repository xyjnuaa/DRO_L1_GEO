function J = joint_fdoa_froa_cost_function(x, data)
%==========================================================================
% 函数名称：joint_fdoa_froa_cost_function
% 功能说明：
%   在“接收机时钟完美”的假设下，同时利用 FDOA 与 FROA 做联合估计。
%
% 待估参数：
%   x = [a, lambda0_deg, dlambda_deg_day, fc0_hz, tx_drift_hz_s]
%
% 说明：
%   这里对 FROA 残差做了略小于 FDOA 的加权，
%   目的是让 FROA 起到补充几何信息的作用，而不是在数值上压过 FDOA。
%==========================================================================

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
rD = (data.z.fdoa_hz - pred.fdoa_hz) / data.meas.sigma_fdoa;
rR = (data.z.froa - pred.froa) / data.meas.sigma_froa;

J = sum(rD.^2) + 0.6 * sum(rR.^2) + (x(5) / 0.05)^2;
end
