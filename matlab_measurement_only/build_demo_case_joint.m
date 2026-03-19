function data = build_demo_case_joint(Nobs, seed, sigma_dopp_hz)
%==========================================================================
% 函数名称：build_demo_case_joint
% 功能说明：
%   构造一组“GEO 非合作目标初轨确定”仿真数据，并统一输出后续各方法共用的数据结构。
%
% 本版相较于旧版的主要变化：
%   1) 第二条观测轨道由原来的 3:1 DRO 替换为 L1 Halo 轨道；
%   2) 量测模型同时考虑：
%      - 发射源初始载频未知
%      - 发射源频漂
%      - 两个接收机各自的频偏
%      - 两个接收机各自的频漂
%   3) 一次性生成单路非差多普勒、FDOA、FROA 三类量测，
%      供传统方法、纯 FDOA、纯 FROA 和组合方法公平比较。
%==========================================================================

if nargin < 2 || isempty(seed)
    seed = 1;
end
if nargin < 3 || isempty(sigma_dopp_hz)
    sigma_dopp_hz = 0.05;
end
rng(seed);

%% 常数与轨道文件
const = get_constants();
this_dir = fileparts(mfilename('fullpath'));
csv_dro = fullfile(this_dir, '2：1共振比DRO轨道初值.csv');
csv_l1  = fullfile(this_dir, 'L1轨道.csv');

obs1 = read_dro_init(csv_dro);
obs2 = read_dro_init(csv_l1);

%% 仿真时域
T_hours = 12;
dt = 120;
t = (0:dt:T_hours*3600).';
Nall = numel(t);

if Nobs > Nall
    error('Nobs = %d 超过总历元数 %d，请减小 Nobs。', Nobs, Nall);
end

%% GEO 真值轨道参数
truth.a = const.geo_a_km + 20;
truth.lambda0_deg = 110.0;
truth.dlambda_deg_day = 0.08;
truth.inc_deg = 0.05;
truth.ecc = 0.0003;

%% 无线电真值参数
% 说明：
%   这里把“发射源频偏”并入真实发射初始载频 fc0_hz。
%   因此各方法最后输出的载频估计值，就是目标在起始历元实际发射的载频。
radio.fc_nominal_hz = 12e9;
radio.fc0_hz = radio.fc_nominal_hz + 3600;
radio.tx_drift_hz_s = 0.2;
radio.rx1_bias_hz = 0;%35;
radio.rx1_drift_hz_s = 0;%0.004;
radio.rx2_bias_hz = 0;%-20;
radio.rx2_drift_hz_s = 0;%-0.003;

meas.sigma_dopp_hz = sigma_dopp_hz;
meas.fc_nominal_hz = radio.fc_nominal_hz;

%% 两条观测星轨道传播
X01 = [obs1.x0; obs1.y0; obs1.z0; obs1.vx0; obs1.vy0; obs1.vz0];
X02 = [obs2.x0; obs2.y0; obs2.z0; obs2.vx0; obs2.vy0; obs2.vz0];

traj1 = propagate_dro_cr3bp(X01, t, const.mu);
traj2 = propagate_dro_cr3bp(X02, t, const.mu);

[r1_eci_km, v1_eci_kms] = synodic_to_eci_earthcentered(traj1(:,1:3), traj1(:,4:6), t, const);
[r2_eci_km, v2_eci_kms] = synodic_to_eci_earthcentered(traj2(:,1:3), traj2(:,4:6), t, const);

%% GEO 真值轨道传播
[rT_km, vT_kms] = propagate_geo_simple(truth, t, const);

%% 生成统一量测
meas_truth = radio;
meas_truth.sigma_dopp_hz = sigma_dopp_hz;
[z, aux] = generate_measurements_joint(rT_km, vT_kms, ...
    r1_eci_km, v1_eci_kms, r2_eci_km, v2_eci_kms, t, meas_truth, const);

%% 只保留前 Nobs 个历元
idx = 1:Nobs;

data.const = const;
data.t = t(idx);
data.meas = meas;
data.truth = truth;
data.truth_radio = radio;

data.r1_eci_km = r1_eci_km(idx,:);
data.v1_eci_kms = v1_eci_kms(idx,:);
data.r2_eci_km = r2_eci_km(idx,:);
data.v2_eci_kms = v2_eci_kms(idx,:);

data.rT_km = rT_km(idx,:);
data.vT_kms = vT_kms(idx,:);

data.z = slice_measurement_struct(z, idx);
data.aux = slice_measurement_struct(aux, idx);
data.z_fdoa = data.z.fdoa_hz;
data.z_froa = data.z.froa;
data.meas.fc_hz = radio.fc0_hz;

% 为不同目标函数准备量纲归一化尺度。
data.meas.sigma_f1 = std(data.z.f1_hz - data.aux.f1_true_hz);
data.meas.sigma_f2 = std(data.z.f2_hz - data.aux.f2_true_hz);
data.meas.sigma_fdoa = std(data.z.fdoa_hz - data.aux.fdoa_true_hz);
data.meas.sigma_froa = std(data.z.froa - data.aux.froa_true);

if ~(isfinite(data.meas.sigma_f1) && data.meas.sigma_f1 > 0)
    data.meas.sigma_f1 = sigma_dopp_hz;
end
if ~(isfinite(data.meas.sigma_f2) && data.meas.sigma_f2 > 0)
    data.meas.sigma_f2 = sigma_dopp_hz;
end
if ~(isfinite(data.meas.sigma_fdoa) && data.meas.sigma_fdoa > 0)
    data.meas.sigma_fdoa = sqrt(2) * sigma_dopp_hz;
end
if ~(isfinite(data.meas.sigma_froa) && data.meas.sigma_froa > 0)
    data.meas.sigma_froa = 1e-9;
end

end

function out = slice_measurement_struct(in, idx)
% 按历元索引裁剪量测结构体。
names = fieldnames(in);
for i = 1:numel(names)
    out.(names{i}) = in.(names{i})(idx,:);
end
end
