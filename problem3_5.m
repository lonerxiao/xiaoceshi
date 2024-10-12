% 加载数据
%C5为可替换变量
data = readtable('C5.csv');

% 显示前几行以检查数据结构
disp(head(data));

% 计算每秒每辆车的速度
diffXY = diff(data{:, {'x', 'y'}}); % 仅计算 'x' 和 'y' 的差值
speed = [NaN; sqrt(sum(diffXY.^2, 2))]; % 计算速度，在开头添加 NaN 以匹配数据行数

% 将速度存储在数据表中
data.speed = speed;

% 注意：这种方法假设数据表 'data' 具有名为 'x' 和 'y' 的列。

% 标记是否停止（速度 == 0）
data.stopped = data.speed == 0;

% 分析停止和启动事件
data.stop_change = [NaN; diff(data.stopped)];
stop_times = data(data.stop_change == 1, :);
start_times = data(data.stop_change == -1, :);

% 计算停止持续时间
stop_durations = [];
for i = 1:height(stop_times)
    subsequent_start_times = start_times((start_times.vehicle_id == stop_times.vehicle_id(i)) & ...
        (start_times.time > stop_times.time(i)), :);
    if ~isempty(subsequent_start_times)
        start_time = subsequent_start_times.time(1);
        duration = start_time - stop_times.time(i);
        if duration > 0
            stop_durations = [stop_durations; duration];
        end
    end
end

% 将停止持续时间转换为数组并进行统计分析
disp('有效停止持续时间数据：');
disp(stop_durations);

% 可视化停止持续时间
figure;
histogram(stop_durations, 'BinWidth', 1, 'FaceColor', 'blue', 'EdgeColor', 'black');
title('停止持续时间直方图');
xlabel('停止持续时间（秒）');
ylabel('频率');
grid on;
exportgraphics(gcf,'问题3_C5.png','Resolution',300)
% 检查是否正确获得峰值数组
mean_duration = mean(stop_durations);
[peaks, peakProps] = findpeaks(stop_durations, 'MinPeakHeight', mean_duration);

