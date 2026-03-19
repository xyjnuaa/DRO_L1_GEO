function traj = propagate_dro_cr3bp(X0, t_sec, mu)
%==========================================================================
% 函数名称：propagate_dro_cr3bp
% 功能说明：
%   在地月CR3BP旋转系下传播一条DRO轨道。
%
% 输入：
%   X0    - 初始状态 [x; y; z; vx; vy; vz]，无量纲
%   t_sec - 传播时间序列（秒）
%   mu    - 月球质量比
%
% 输出：
%   traj  - 各历元状态，大小 N×6，仍为无量纲旋转系状态
%==========================================================================

const = get_constants();

t_tu = t_sec / const.TU_s;   % 把秒转换为CR3BP的标准化时间TU
opts = odeset('RelTol',1e-11,'AbsTol',1e-12);

[~, X] = ode113(@(tt,xx) cr3bp_rhs(tt,xx,mu), t_tu, X0, opts);
traj = X;

end
