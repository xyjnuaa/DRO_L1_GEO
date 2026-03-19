function est = unpack_estimate_vector(xhat, mode_name)
%==========================================================================
% 函数名称：unpack_estimate_vector
% 功能说明：
%   将不同方法输出的参数向量统一映射到同一套字段，便于后续统一比较。
%==========================================================================

est = struct( ...
    'a_km', NaN, ...
    'lambda0_deg', NaN, ...
    'dlambda_deg_day', NaN, ...
    'fc0_hz', NaN, ...
    'tx_drift_hz_s', NaN, ...
    'rx1_bias_hz', NaN, ...
    'rx1_drift_hz_s', NaN, ...
    'rx2_bias_hz', NaN, ...
    'rx2_drift_hz_s', NaN, ...
    'rx_diff_bias_hz', NaN, ...
    'rx_diff_drift_hz_s', NaN);

est.a_km = xhat(1);
est.lambda0_deg = xhat(2);
est.dlambda_deg_day = xhat(3);

switch lower(mode_name)
    case 'traditional'
        est.fc0_hz = xhat(4);
        est.tx_drift_hz_s = xhat(5);
        est.rx1_bias_hz = 0;
        est.rx1_drift_hz_s = 0;
        est.rx2_bias_hz = 0;
        est.rx2_drift_hz_s = 0;
        est.rx_diff_bias_hz = 0;
        est.rx_diff_drift_hz_s = 0;

    case 'fdoa'
        est.fc0_hz = xhat(4);
        est.tx_drift_hz_s = xhat(5);
        est.rx1_bias_hz = 0;
        est.rx1_drift_hz_s = 0;
        est.rx2_bias_hz = 0;
        est.rx2_drift_hz_s = 0;
        est.rx_diff_bias_hz = 0;
        est.rx_diff_drift_hz_s = 0;

    case 'froa'
        est.fc0_hz = NaN;
        est.tx_drift_hz_s = xhat(4);
        est.rx1_bias_hz = 0;
        est.rx1_drift_hz_s = 0;
        est.rx2_bias_hz = 0;
        est.rx2_drift_hz_s = 0;
        est.rx_diff_bias_hz = 0;
        est.rx_diff_drift_hz_s = 0;

    case 'joint'
        est.fc0_hz = xhat(4);
        est.tx_drift_hz_s = xhat(5);
        est.rx1_bias_hz = 0;
        est.rx1_drift_hz_s = 0;
        est.rx2_bias_hz = 0;
        est.rx2_drift_hz_s = 0;
        est.rx_diff_bias_hz = 0;
        est.rx_diff_drift_hz_s = 0;

    otherwise
        error('未知的参数向量模式：%s', mode_name);
end
end
