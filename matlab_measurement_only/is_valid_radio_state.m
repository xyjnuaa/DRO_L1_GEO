function tf = is_valid_radio_state(x5, data)
% 判断 GEO 参数与发射源参数是否落在合理范围内。

a = x5(1);
lambda0_deg = x5(2);
dlambda_deg_day = x5(3);
fc0_hz = x5(4);
tx_drift_hz_s = x5(5);

tf = true;

if a < data.const.geo_a_km - 1500 || a > data.const.geo_a_km + 1500
    tf = false;
    return;
end
if lambda0_deg < 0 || lambda0_deg > 360
    tf = false;
    return;
end
if abs(dlambda_deg_day) > 3
    tf = false;
    return;
end
if fc0_hz < data.meas.fc_nominal_hz - 2e6 || fc0_hz > data.meas.fc_nominal_hz + 2e6
    tf = false;
    return;
end
if abs(tx_drift_hz_s) > 2
    tf = false;
end
end
