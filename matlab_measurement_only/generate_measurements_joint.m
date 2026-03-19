function [z, aux] = generate_measurements_joint(rT_km, vT_kms, ...
    r1_eci_km, v1_eci_kms, r2_eci_km, v2_eci_kms, t_sec, meas, const)
%==========================================================================
% 函数名称：generate_measurements_joint
% 功能说明：
%   在统一的“未知载频 + 发射源频漂 + 接收机频偏/频漂”模型下生成量测。
%
% 量测模型：
%   f_tx(t) = fc0_hz + tx_drift_hz_s * t
%   f_i(t)  = f_tx(t) * (1 - rhodot_i/c) + rx_bias_i + rx_drift_i * t + noise
%
% 由此进一步构造：
%   FDOA = f1 - f2
%   FROA = f1 / f2
%==========================================================================

N = size(rT_km,1);
c = const.c_km_s;

f1_true_hz = zeros(N,1);
f2_true_hz = zeros(N,1);
rhodot1_kms = zeros(N,1);
rhodot2_kms = zeros(N,1);

if isfield(meas, 'sigma_dopp_hz')
    sigma = meas.sigma_dopp_hz;
else
    sigma = 0;
end

for k = 1:N
    rho1_vec = rT_km(k,:) - r1_eci_km(k,:);
    u1 = rho1_vec / norm(rho1_vec);
    rhodot1_kms(k) = u1 * (vT_kms(k,:) - v1_eci_kms(k,:)).';

    rho2_vec = rT_km(k,:) - r2_eci_km(k,:);
    u2 = rho2_vec / norm(rho2_vec);
    rhodot2_kms(k) = u2 * (vT_kms(k,:) - v2_eci_kms(k,:)).';

    tx_freq_hz = meas.fc0_hz + meas.tx_drift_hz_s * t_sec(k);

    f1_true_hz(k) = tx_freq_hz * (1 - rhodot1_kms(k) / c) + ...
        meas.rx1_bias_hz + meas.rx1_drift_hz_s * t_sec(k);
    f2_true_hz(k) = tx_freq_hz * (1 - rhodot2_kms(k) / c) + ...
        meas.rx2_bias_hz + meas.rx2_drift_hz_s * t_sec(k);
end

z.f1_hz = f1_true_hz + sigma * randn(N,1);
z.f2_hz = f2_true_hz + sigma * randn(N,1);
z.fdoa_hz = z.f1_hz - z.f2_hz;
z.froa = z.f1_hz ./ z.f2_hz;

aux.f1_true_hz = f1_true_hz;
aux.f2_true_hz = f2_true_hz;
aux.fdoa_true_hz = f1_true_hz - f2_true_hz;
aux.froa_true = f1_true_hz ./ f2_true_hz;
aux.rhodot1_kms = rhodot1_kms;
aux.rhodot2_kms = rhodot2_kms;
end
