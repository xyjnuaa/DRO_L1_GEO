function [rECI_km, vECI_kms] = synodic_to_eci_earthcentered(rSyn, vSyn, t_sec, const)
%==========================================================================
% 函数名称：synodic_to_eci_earthcentered
% 功能说明：
%   将地月旋转坐标系（synodic）下的无量纲状态，转换到地心惯性系ECI。
%
% 输入：
%   rSyn  - 旋转系位置，N×3，无量纲
%   vSyn  - 旋转系速度，N×3，无量纲/TU
%   t_sec - 历元（秒）
%   const - 常数结构体
%
% 输出：
%   rECI_km   - 地心惯性系位置（km）
%   vECI_kms  - 地心惯性系速度（km/s）
%
% 说明：
%   1) 旋转系原点位于地月质心
%   2) 输出坐标系原点改为地心
%==========================================================================

N = size(rSyn,1);
rECI_km = zeros(N,3);
vECI_kms = zeros(N,3);

for k = 1:N
    theta = const.omega_EM * t_sec(k);  % 该时刻地月旋转角
    c = cos(theta);
    s = sin(theta);

    % 旋转矩阵：旋转系 -> 惯性系
    R = [c -s 0;
         s  c 0;
         0  0 1];

    % 系统角速度向量
    Omega = [0; 0; const.omega_EM];

    % 当前无量纲旋转系状态
    r_bar = rSyn(k,:)';
    v_bar = vSyn(k,:)';

    % 先转到以地月质心为原点的惯性系
    rI_bar = R * r_bar; % 仍是无量纲位置

    % 速度转换注意：旋转系速度转惯性系速度时，需要加上 Ω×r
    vI_kms = R * v_bar * const.vu_kms + cross(Omega, R*r_bar*const.LU_km);

    % 地球在地月质心旋转系中的无量纲位置是 [-mu,0,0]
    rE_bar = [-const.mu; 0; 0];
    rE_I_km = R * rE_bar * const.LU_km;

    % 改成地心原点
    rECI_km(k,:) = (rI_bar * const.LU_km - rE_I_km)';
    vECI_kms(k,:) = vI_kms';
end

end
