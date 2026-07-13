%% ========================================================================
% CELL BALANCING ALGORITHM
% ========================================================================

clear all; close all; clc;
BMS_Parameters;

fprintf('\n========================================\n');
fprintf('CELL BALANCING ANALYSIS\n');
fprintf('========================================\n\n');

% Simulate cell voltage variations
num_cells = BMS.Num_Cells_Series;
t = linspace(0, 3600, 3601);

% Generate voltage variations with degradation
V_cells = zeros(num_cells, length(t));
for i = 1:num_cells
    % Base voltage with SOC variation
    V_base = 3.7 + 0.2 * sin(2*pi*t/3600);
    % Add manufacturing variation
    V_offset = 0.05 * (2*rand - 1);
    % Add aging effect
    V_age = -0.01 * (i / num_cells);
    V_cells(i, :) = V_base + V_offset + V_age + 0.02 * randn(1, length(t));
end

% Clamp to valid range
V_cells = max(BMS.Min_Cell_Voltage, min(BMS.Max_Cell_Voltage, V_cells));

% Calculate balancing
balancing_current = zeros(num_cells, length(t));
for k = 1:length(t)
    V_avg = mean(V_cells(:, k));
    V_max = max(V_cells(:, k));
    V_imbalance = V_max - min(V_cells(:, k));
    
    if V_imbalance > Balancing.Passive_Threshold
        for i = 1:num_cells
            if V_cells(i, k) > V_avg + 0.01
                balancing_current(i, k) = Balancing.Passive_Balancing_Current;
            end
        end
    end
end

% Calculate voltage distribution
V_min = min(V_cells);
V_max = max(V_cells);
V_avg = mean(V_cells);
V_std = std(V_cells);

figure('Position', [100 100 1200 800]);

subplot(2,2,1);
for i = 1:min(16, num_cells)
    plot(t, V_cells(i, :), 'LineWidth', 1);
    hold on;
end
xlabel('Time (s)'); ylabel('Voltage (V)'); title('Cell Voltage Profile (Sample Cells)');
grid on; legend(arrayfun(@(x) sprintf('Cell %d', x), 1:min(16, num_cells), 'UniformOutput', false));

subplot(2,2,2);
V_imb = zeros(1, length(t));
for k = 1:length(t)
    V_imb(k) = max(V_cells(:, k)) - min(V_cells(:, k));
end
plot(t, V_imb, 'b-', 'LineWidth', 2);
hold on;
plot(t, ones(size(t)) * Balancing.Passive_Threshold, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Threshold');
xlabel('Time (s)'); ylabel('Imbalance (V)'); title('Voltage Imbalance');
legend; grid on;

subplot(2,2,3);
V_range = zeros(2, length(t));
for k = 1:length(t)
    V_range(1, k) = min(V_cells(:, k));
    V_range(2, k) = max(V_cells(:, k));
end
fill_between(t, V_range(1, :), V_range(2, :), 'Median');
xlabel('Time (s)'); ylabel('Voltage (V)'); title('Min-Max Voltage Range');
grid on;

subplot(2,2,4);
num_balancing = sum(balancing_current > 0, 1);
bar(t, num_balancing, 'g');
xlabel('Time (s)'); ylabel('Cells Being Balanced');
title('Active Balancing Cells');
grid on;

sgtitle('Cell Balancing System Analysis', 'FontSize', 14, 'FontWeight', 'bold');

fprintf('CELL BALANCING RESULTS:\n');
fprintf('======================\n\n');
fprintf('Voltage Statistics:\n');
fprintf('  Min Voltage: %.4f V\n', min(V_cells(:)));
fprintf('  Max Voltage: %.4f V\n', max(V_cells(:)));
fprintf('  Imbalance: %.4f V\n', max(V_cells(:)) - min(V_cells(:)));
fprintf('  Target: < %.4f V\n\n', Balancing.Target_Voltage_Difference);
fprintf('Balancing Performance:\n');
fprintf('  Max Cells Balanced: %d\n', max(num_balancing));
fprintf('  Avg Cells Balanced: %.1f\n', mean(num_balancing));
fprintf('  Total Balancing Events: %d\n', sum(num_balancing > 0));
fprintf('========================================\n');

function fill_between(x, y1, y2, label)
    fill([x, fliplr(x)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    hold on;
    plot(x, y1, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Min');
    plot(x, y2, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Max');
    legend;
end

save('Cell_Balancing_Data.mat', 't', 'V_cells', 'balancing_current', 'V_imb');
fprintf('\nBalancing data saved to Cell_Balancing_Data.mat\n');