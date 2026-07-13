%% ========================================================================
% SAFETY CONTROLLER - PROTECTION SYSTEMS
% ========================================================================

function [Safe_Flag, Fault_Code, Control_Action] = Safety_Controller(V_cell, V_pack, I_pack, T_max, T_min, Safety_Params, Fault_Status_Prev)
    Safe_Flag = 1;
    Fault_Code = 0;
    Control_Action = 'Normal';
    
    if any(V_cell > Safety_Params.OVP_Threshold)
        Safe_Flag = 0; Fault_Code = 1; Control_Action = 'Stop_Charge'; return;
    end
    if any(V_cell < Safety_Params.UVP_Threshold)
        Safe_Flag = 0; Fault_Code = 2; Control_Action = 'Stop_Discharge'; return;
    end
    if abs(I_pack) > Safety_Params.OCP_Threshold
        Safe_Flag = 0; Fault_Code = 3; Control_Action = 'Limit_Current'; return;
    end
    if T_max > Safety_Params.OTP_High_Threshold
        Safe_Flag = 0; Fault_Code = 4; Control_Action = 'Stop_and_Cool'; return;
    end
    if T_min < Safety_Params.OTP_Low_Threshold
        Safe_Flag = 0; Fault_Code = 5; Control_Action = 'Stop_and_Heat'; return;
    end
    if T_max > Safety_Params.Thermal_Runaway_Threshold
        Safe_Flag = 0; Fault_Code = 6; Control_Action = 'Emergency_Shutdown'; return;
    end
    
    V_imbalance = max(V_cell) - min(V_cell);
    if V_imbalance > Safety_Params.Voltage_Imbalance_Threshold
        Fault_Code = 101; Control_Action = 'Trigger_Balancing';
    end
end

clear all; close all; clc;
BMS_Parameters;
load('Battery_Model_Data.mat');

fprintf('\n========================================\n');
fprintf('SAFETY PROTECTION SYSTEM TEST\n');
fprintf('========================================\n\n');

Safety_Params.OVP_Threshold = BMS.Max_Cell_Voltage + 0.05;
Safety_Params.OVP_Recovery = BMS.Max_Cell_Voltage;
Safety_Params.UVP_Threshold = BMS.Min_Cell_Voltage - 0.05;
Safety_Params.UVP_Recovery = BMS.Min_Cell_Voltage + 0.1;
Safety_Params.OCP_Threshold = BMS.Max_Discharge_Current + 10;
Safety_Params.OTP_High_Threshold = BMS.Max_Operating_Temp + 5;
Safety_Params.OTP_Low_Threshold = BMS.Min_Operating_Temp - 5;
Safety_Params.Voltage_Imbalance_Threshold = 0.3;
Safety_Params.Thermal_Runaway_Threshold = 80;

Safe_Flag_Array = ones(length(t), 1);
Fault_Code_Array = zeros(length(t), 1);
Control_Action_Array = repmat({'Normal'}, length(t), 1);
V_cell_Array = V_oc / BMS.Num_Cells_Series;

fprintf('TEST CASE 1: Normal Operation\n'); fprintf('------------------------------\n');
for k = 1:length(t)
    V_cell = V_cell_Array + 0.01 * randn(BMS.Num_Cells_Series, 1);
    [Safe_Flag_Array(k), Fault_Code_Array(k), Control_Action_Array{k}] = Safety_Controller(V_cell, V_terminal(k), I_array(k), Temp_array(k), Temp_array(k), Safety_Params, 0);
end
fprintf('  Status: %d safe, %d fault events\n\n', sum(Safe_Flag_Array), sum(~Safe_Flag_Array));

I_ovv = I_array; V_term_ovv = V_terminal; V_cell_ovv = V_cell_Array + 0.3;
Safe_OVV = zeros(length(t), 1);
fprintf('TEST CASE 2: Over-Voltage Scenario\n'); fprintf('-----------------------------------\n');
for k = 1:length(t)
    V_cell = V_cell_ovv + 0.01 * randn(BMS.Num_Cells_Series, 1);
    [Safe_OVV(k), ~, ~] = Safety_Controller(V_cell, V_term_ovv(k), I_ovv(k), Temp_array(k), Temp_array(k), Safety_Params, 0);
end
ovv_fault_index = find(~Safe_OVV, 1, 'first');
if ~isempty(ovv_fault_index), fprintf('  Over-voltage detected at t = %.1f seconds\n\n', t(ovv_fault_index)); end

I_occ = I_array * 2; Safe_OCC = zeros(length(t), 1);
fprintf('TEST CASE 3: Over-Current Scenario\n'); fprintf('-----------------------------------\n');
for k = 1:length(t)
    V_cell = V_cell_Array + 0.01 * randn(BMS.Num_Cells_Series, 1);
    [Safe_OCC(k), ~, ~] = Safety_Controller(V_cell, V_terminal(k), I_occ(k), Temp_array(k), Temp_array(k), Safety_Params, 0);
end
occ_fault_index = find(~Safe_OCC, 1, 'first');
if ~isempty(occ_fault_index), fprintf('  Over-current detected at t = %.1f seconds\n\n', t(occ_fault_index)); end

Temp_otp = Temp_array + 35; Safe_OTP = zeros(length(t), 1);
fprintf('TEST CASE 4: Over-Temperature Scenario\n'); fprintf('--------------------------------------\n');
for k = 1:length(t)
    V_cell = V_cell_Array + 0.01 * randn(BMS.Num_Cells_Series, 1);
    [Safe_OTP(k), ~, ~] = Safety_Controller(V_cell, V_terminal(k), I_array(k), Temp_otp(k), Temp_otp(k), Safety_Params, 0);
end
otp_fault_index = find(~Safe_OTP, 1, 'first');
if ~isempty(otp_fault_index), fprintf('  Over-temperature detected at t = %.1f seconds (T = %.1f°C)\n\n', t(otp_fault_index), Temp_otp(otp_fault_index)); end

figure('Position', [100 100 1200 800]);
subplot(2,3,1); plot(t, Safe_Flag_Array, 'b', 'LineWidth', 2); xlabel('Time (s)'); ylabel('Safe (1=Yes, 0=No)'); title('Normal Operation'); grid on; ylim([-0.1 1.1]);
subplot(2,3,2); plot(t, Safe_OVV, 'r', 'LineWidth', 2); xlabel('Time (s)'); ylabel('Safe'); title('Over-Voltage Test'); grid on;
subplot(2,3,3); plot(t, Safe_OCC, 'g', 'LineWidth', 2); xlabel('Time (s)'); ylabel('Safe'); title('Over-Current Test'); grid on;
subplot(2,3,4); plot(t, Safe_OTP, 'm', 'LineWidth', 2); xlabel('Time (s)'); ylabel('Safe'); title('Over-Temperature Test'); grid on;
subplot(2,3,5); bar(Fault_Code_Array); xlabel('Time Index'); ylabel('Fault Code'); title('Fault Codes'); grid on;
subplot(2,3,6); axis off; text(0.1, 0.5, sprintf('SAFETY TEST SUMMARY\n\nNormal Op: %d safe\nOVV: %s\nOCC: %s\nOTP: %s', sum(Safe_Flag_Array), iif(~isempty(ovv_fault_index), 'YES', 'NO'), iif(~isempty(occ_fault_index), 'YES', 'NO'), iif(~isempty(otp_fault_index), 'YES', 'NO')), 'FontSize', 11, 'VerticalAlignment', 'middle', 'FontName', 'monospace');
sgtitle('Safety Protection System - Test Results', 'FontSize', 14, 'FontWeight', 'bold');

fprintf('\n========================================\n'); fprintf('DETAILED SAFETY TEST REPORT\n'); fprintf('========================================\n\n');
fprintf('NORMAL OPERATION TEST:\n'); fprintf('  Duration: %.1f seconds\n', t(end)); fprintf('  Safe Events: %d (%.1f%%)\n', sum(Safe_Flag_Array), sum(Safe_Flag_Array)/length(Safe_Flag_Array)*100); fprintf('  Fault Events: %d\n\n', sum(~Safe_Flag_Array));
fprintf('FAULT MEANINGS:\n'); fprintf('  1: OVP, 2: UVP, 3: OCP, 4: OTP High, 5: OTP Low, 6: Thermal Runaway\n');
fprintf('========================================\n');

function result = iif(condition, value_true, value_false)
    if condition, result = value_true; else, result = value_false; end
end

save('Safety_Test_Results.mat', 'Safe_Flag_Array', 'Fault_Code_Array', 'Safe_OVV', 'Safe_OCC', 'Safe_OTP', 't');
fprintf('Results saved to Safety_Test_Results.mat\n');