function radio0 = estimate_initial_radio_params(seed_geo, data, mode_name)
%==========================================================================
% 函数名称：estimate_initial_radio_params
% 功能说明：
%   在 GEO 几何参数固定的前提下，用线性最小二乘给无线电参数生成一个更稳健的初值。
%
% mode_name:
%   'traditional' - 在完美接收机时钟假设下，估计 fc0、tx_drift
%   'fdoa'        - 在完美接收机时钟假设下，估计 fc0、tx_drift
%   'joint'       - 利用均值与差分信息联合给出 fc0、tx_drift 初值
%==========================================================================

geom = predict_radio_measurements(seed_geo, zero_radio(), data);
t = data.t(:);
D1 = geom.f1_hz(:);
D2 = geom.f2_hz(:);
fc0_anchor = data.meas.fc_nominal_hz ;

switch lower(mode_name)
    case 'traditional'
        H = [0.5 * (D1 + D2), 0.5 * (D1 + D2) .* t];
        y = 0.5 * (data.z.f1_hz(:) + data.z.f2_hz(:));
        theta = H \ y;

        radio0.fc0_hz = theta(1);
        radio0.tx_drift_hz_s = theta(2);
        radio0.rx1_bias_hz = 0;
        radio0.rx1_drift_hz_s = 0;
        radio0.rx2_bias_hz = 0;
        radio0.rx2_drift_hz_s = 0;

    case 'fdoa'
        Hd = [D1 - D2, (D1 - D2) .* t];
        theta = Hd \ data.z.fdoa_hz(:);

        radio0.fc0_hz = theta(1);
        radio0.tx_drift_hz_s = theta(2);
        radio0.rx_diff_bias_hz = 0;
        radio0.rx_diff_drift_hz_s = 0;

    case 'joint'
        Havg = [0.5 * (D1 + D2), 0.5 * (D1 + D2) .* t];
        yavg = 0.5 * (data.z.f1_hz(:) + data.z.f2_hz(:));
        theta_avg = Havg \ yavg;

        Hd = [D1 - D2, (D1 - D2) .* t];
        yd = data.z.fdoa_hz(:);
        theta_d = Hd \ yd;

        radio0.fc0_hz = 0.5 * (theta_avg(1) + theta_d(1));
        radio0.tx_drift_hz_s = 0.5 * (theta_avg(2) + theta_d(2));
        radio0.rx1_bias_hz = 0;
        radio0.rx1_drift_hz_s = 0;
        radio0.rx2_bias_hz = 0;
        radio0.rx2_drift_hz_s = 0;

    otherwise
        error('未知的初值模式：%s', mode_name);
end
end

function radio = zero_radio()
radio.fc0_hz = 1;
radio.tx_drift_hz_s = 0;
radio.rx1_bias_hz = 0;
radio.rx1_drift_hz_s = 0;
radio.rx2_bias_hz = 0;
radio.rx2_drift_hz_s = 0;
end
