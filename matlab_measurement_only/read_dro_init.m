function obs = read_dro_init(csvfile)
%==========================================================================
% 函数名称：read_dro_init
% 功能说明：
%   从CSV文件中读取DRO轨道初值。
%
% 输入：
%   csvfile - CSV文件路径
%
% 输出：
%   obs     - 结构体，包含：
%             x0, y0, z0, vx0, vy0, vz0 等字段
%
% 说明：
%   你上传的CSV第一行就是一组轨道初值，文件中可能含有中文表头，
%   因此这里使用 readtable + table2array 的方式读取。
%==========================================================================

T = readtable(csvfile, 'VariableNamingRule', 'preserve');
A = table2array(T(1,:));

obs.id = A(1);
obs.x0 = A(2);
obs.y0 = A(3);
obs.z0 = A(4);
obs.vx0 = A(5);
obs.vy0 = A(6);
obs.vz0 = A(7);
obs.CJ = A(8);
obs.period_TU = A(9);
obs.period_day = A(10);
obs.stab = A(11);
obs.mu = A(12);

end
