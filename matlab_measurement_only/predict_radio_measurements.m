function pred = predict_radio_measurements(x_geo, radio_param, data)
%==========================================================================
% 函数名称：predict_radio_measurements
% 功能说明：
%   在给定候选 GEO 参数和候选无线电参数的情况下，预测每个历元的：
%   1) 单路接收频率 f1、f2
%   2) FDOA
%   3) FROA
%==========================================================================

[rT_km, vT_kms] = propagate_geo_from_x(x_geo, data.t, data.const);
N = numel(data.t);
c = data.const.c_km_s;

f1_hz = zeros(N,1);
f2_hz = zeros(N,1);
rhodot1_kms = zeros(N,1);
rhodot2_kms = zeros(N,1);

for k = 1:N
    rho1_vec = rT_km(k,:) - data.r1_eci_km(k,:);
    u1 = rho1_vec / norm(rho1_vec);
    rhodot1_kms(k) = u1 * (vT_kms(k,:) - data.v1_eci_kms(k,:)).';

    rho2_vec = rT_km(k,:) - data.r2_eci_km(k,:);
    u2 = rho2_vec / norm(rho2_vec);
    rhodot2_kms(k) = u2 * (vT_kms(k,:) - data.v2_eci_kms(k,:)).';

    doppler_scale_1 = 1 - rhodot1_kms(k) / c;
    doppler_scale_2 = 1 - rhodot2_kms(k) / c;
    tx_freq_hz = radio_param.fc0_hz + radio_param.tx_drift_hz_s * data.t(k);

    f1_hz(k) = tx_freq_hz * doppler_scale_1 + ...
        radio_param.rx1_bias_hz + radio_param.rx1_drift_hz_s * data.t(k);
    f2_hz(k) = tx_freq_hz * doppler_scale_2 + ...
        radio_param.rx2_bias_hz + radio_param.rx2_drift_hz_s * data.t(k);
end

pred.r_km = rT_km;
pred.v_kms = vT_kms;
pred.rhodot1_kms = rhodot1_kms;
pred.rhodot2_kms = rhodot2_kms;
pred.f1_hz = f1_hz;
pred.f2_hz = f2_hz;
pred.fdoa_hz = f1_hz - f2_hz;
pred.froa = f1_hz ./ f2_hz;
end
