%% ========================================================================
% UTILITY FUNCTIONS FOR BMS
% ========================================================================

function plot_comparison(t, data1, data2, label1, label2, title_str, ylabel_str)
    figure;
    plot(t, data1, 'b-', 'LineWidth', 2, 'DisplayName', label1);
    hold on;
    plot(t, data2, 'r--', 'LineWidth', 1.5, 'DisplayName', label2);
    xlabel('Time (s)');
    ylabel(ylabel_str);
    title(title_str);
    legend;
    grid on;
end

function error_metrics = calculate_errors(estimated, reference)
    error_metrics.MAE = mean(abs(estimated - reference));
    error_metrics.RMSE = sqrt(mean((estimated - reference).^2));
    error_metrics.Max_Error = max(abs(estimated - reference));
    error_metrics.Min_Error = min(abs(estimated - reference));
    error_metrics.Std_Dev = std(estimated - reference);
end

function report = generate_report(scenario_name, data, thresholds)
    report.Scenario = scenario_name;
    report.Min_Value = min(data);
    report.Max_Value = max(data);
    report.Mean_Value = mean(data);
    report.Std_Dev = std(data);
    report.Violations = sum(abs(data) > thresholds);
    report.Violation_Percentage = (report.Violations / length(data)) * 100;
end

function filtered_data = lowpass_filter(data, cutoff_freq, sample_rate)
    [b, a] = butter(2, cutoff_freq / (sample_rate / 2));
    filtered_data = filtfilt(b, a, data);
end

fprintf('Utility functions loaded successfully!\n');