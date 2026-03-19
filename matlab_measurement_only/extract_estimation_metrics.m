function metrics = extract_estimation_metrics(est, data)
%==========================================================================
% 函数名称：extract_estimation_metrics
% 功能说明：
%   将某一种方法的估计结果映射为统一误差指标，便于四种方法公平比较。
%==========================================================================

x_geo = [est.a_km, est.lambda0_deg, est.dlambda_deg_day];
[rHat_km, ~] = propagate_geo_from_x(x_geo, data.t, data.const);
geo_err_km = sqrt(sum((data.rT_km - rHat_km).^2, 2));

metrics.err_pos_max_km = max(geo_err_km);
metrics.err_pos_mean_km = mean(geo_err_km);
metrics.err_a_km = abs(est.a_km - data.truth.a);
metrics.err_lambda_deg = abs(wrapTo180_local(est.lambda0_deg - data.truth.lambda0_deg));
metrics.err_dlambda_deg_day = abs(est.dlambda_deg_day - data.truth.dlambda_deg_day);

metrics.err_fc0_hz = abs(est.fc0_hz - data.truth_radio.fc0_hz);
metrics.err_tx_drift_hz_s = abs(est.tx_drift_hz_s - data.truth_radio.tx_drift_hz_s);

metrics.err_rx1_bias_hz = safe_abs_diff(est.rx1_bias_hz, data.truth_radio.rx1_bias_hz);
metrics.err_rx1_drift_hz_s = safe_abs_diff(est.rx1_drift_hz_s, data.truth_radio.rx1_drift_hz_s);
metrics.err_rx2_bias_hz = safe_abs_diff(est.rx2_bias_hz, data.truth_radio.rx2_bias_hz);
metrics.err_rx2_drift_hz_s = safe_abs_diff(est.rx2_drift_hz_s, data.truth_radio.rx2_drift_hz_s);

truth_diff_bias = data.truth_radio.rx1_bias_hz - data.truth_radio.rx2_bias_hz;
truth_diff_drift = data.truth_radio.rx1_drift_hz_s - data.truth_radio.rx2_drift_hz_s;
metrics.err_rx_diff_bias_hz = safe_abs_diff(est.rx_diff_bias_hz, truth_diff_bias);
metrics.err_rx_diff_drift_hz_s = safe_abs_diff(est.rx_diff_drift_hz_s, truth_diff_drift);

metrics.success = (metrics.err_pos_max_km < 100) && ...
                  (metrics.err_a_km < 50) && ...
                  (metrics.err_lambda_deg < 0.5);
end

function v = safe_abs_diff(a, b)
if isnan(a)
    v = NaN;
else
    v = abs(a - b);
end
end
