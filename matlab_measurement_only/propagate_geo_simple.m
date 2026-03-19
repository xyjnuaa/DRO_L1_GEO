function [r_km, v_kms] = propagate_geo_simple(truth, t_sec, const)
%==========================================================================
% 函数名称：propagate_geo_simple
% 功能说明：
%   使用“简化近圆近赤道GEO模型”传播目标轨道。
%
% 输入：
%   truth - 结构体，至少包含：
%       truth.a                 半长轴（km）
%       truth.lambda0_deg       初始经度（deg）
%       truth.dlambda_deg_day   经度漂移率（deg/day）
%   t_sec - 时间序列（秒）
%   const - 常数结构体
%
% 输出：
%   r_km  - 位置（km）
%   v_kms - 速度（km/s）
%
% 说明：
%   这是一个“原理验证版”的GEO传播模型：
%   - 假设目标轨道在赤道平面内
%   - 近圆轨道
%   - 用经度漂移率来描述其相对地球自转的偏差
%==========================================================================

N = numel(t_sec);
r_km = zeros(N,3);
v_kms = zeros(N,3);

% 轨道名义平均角速度
n_orb = sqrt(const.muE_km3s2 / truth.a^3); %#ok<NASGU>

% 地球自转角速度
wE = const.wE_rad_s;

% 用户给出的经度漂移率，单位由 deg/day 转换为 rad/s
extra = deg2rad(truth.dlambda_deg_day) / 86400;

% 为了体现“地固经度的漂移”，令惯性相位速度 = 地球自转角速度 + 漂移率
n_eff = wE + extra;

% 初始相位
phi0 = deg2rad(truth.lambda0_deg);

for k = 1:N
    phi = phi0 + n_eff * t_sec(k);

    r = truth.a * [cos(phi); sin(phi); 0];
    v = truth.a * n_eff * [-sin(phi); cos(phi); 0];

    r_km(k,:)  = r';
    v_kms(k,:) = v';
end

end
