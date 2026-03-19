function [r_km, v_kms] = propagate_geo_from_x(x, t_sec, const)
%==========================================================================
% 函数名称：propagate_geo_from_x
% 功能说明：
%   根据当前待估参数 x = [a, lambda0_deg, dlambda_deg_day] 传播一条候选GEO轨道。
%
% 输入：
%   x      - 参数向量 [a_km, lambda0_deg, dlambda_deg_day]
%   t_sec  - 时间序列（秒）
%   const  - 常数结构体
%
% 输出：
%   r_km   - 候选轨道位置（km）
%   v_kms  - 候选轨道速度（km/s）
%==========================================================================

truth.a = x(1);
truth.lambda0_deg = x(2);
truth.dlambda_deg_day = x(3);
truth.inc_deg = 0;   % 当前简化模型先不估倾角
truth.ecc = 0;       % 当前简化模型先不估偏心率

[r_km, v_kms] = propagate_geo_simple(truth, t_sec, const);

end
