本压缩包是“只研究测量体制，不引入GEO两层可行域约束”的 MATLAB 原理验证工程。

============================
一、这份代码现在只做什么
============================
当前工程只专注于比较不同频率测量体制对 GEO 初轨确定的影响，不再包含：
- 第一层 GEO 可行域
- 第二层观测一致性可行域
- 任何基于可行域的粗筛选或候选剔除

也就是说，现在所有方法都采用“直接数值优化”的思路，核心对比对象只剩下测量模型本身。

============================
二、当前重点比较哪两种方法
============================
1) 纯 FDOA 直接估计
   - 同时估计 [a, lambda0, dlambda, fc]
   - 只使用 FDOA 残差作为目标函数

2) 联合 FROA + FDOA 直接估计
   - 同时估计 [a, lambda0, dlambda, fc]
   - 同时使用 FROA 残差与 FDOA 残差

这样做的目的，是先把“测量体制”的价值研究清楚：
- 纯 FDOA 是否足够
- FROA 的引入是否真的能够改善未知载频条件下的估计性能

============================
三、建议先运行哪个文件
============================
1) 单次演示：
   main_demo_measurement_compare

2) Monte Carlo 对比：
   results = run_monte_carlo_measurement_compare;

============================
四、当前状态参数定义
============================
当前 GEO 状态采用 3 参数简化形式：
    x_geo = [a, lambda0_deg, dlambda_deg_day]

如果把发射载频也一起估计，则扩展状态为：
    x_aug = [a, lambda0_deg, dlambda_deg_day, fc_hz]

其中：
- a                半长轴（km）
- lambda0_deg      初始经度（deg）
- dlambda_deg_day  经度漂移率（deg/day）
- fc_hz            发射载频（Hz）

============================
五、保留了哪些基础模块
============================
1) 轨道传播
   - cr3bp_rhs.m
   - propagate_dro_cr3bp.m
   - synodic_to_eci_earthcentered.m
   - propagate_geo_simple.m
   - propagate_geo_from_x.m

2) 量测生成
   - generate_measurements_fdoa.m
   - generate_measurements_joint.m

3) 目标函数
   - fdoa_cost_function_unknown_fc.m
   - joint_cost_function.m

4) 方法封装
   - method_direct_fdoa_unknownfc.m
   - method_direct_joint.m

5) 结果提取与出图
   - extract_estimation_metrics.m
   - plot_measurement_compare_results.m
   - plot_measurement_parameter_results.m

============================
六、当前故意不做的事
============================
为了把问题收缩到“测量体制比较”上，当前故意不做：
- 可行域粗搜索
- 候选点筛选
- GEO 两层先验约束
- 接收机频偏 / 时钟漂移
- TDOA
- 小偏心 / 小倾角 6 参数 GEO 建模

============================
七、这份代码现在适合回答什么问题
============================
这份代码最适合回答：
1) 当发射载频未知并作为待估参数加入状态后，纯 FDOA 会不会明显退化？
2) 联合 FROA + FDOA 是否能缓解轨道参数与载频之间的耦合？
3) 在少历元条件下，哪种测量体制更稳、更准？

============================
八、后续若要继续扩展
============================
后续建议顺序：
1) 先把“测量体制”的结论做稳
2) 再逐步加入接收机频偏/时钟漂移
3) 再引入更复杂的 GEO 状态参数化
4) 最后再把 GEO 两层可行域筛选加回来
