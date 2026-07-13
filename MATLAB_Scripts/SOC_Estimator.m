%% ========================================================================
% STATE OF CHARGE (SOC) ESTIMATOR
% ========================================================================

function SOC_est = SOC_Coulomb_Counting(SOC_prev, I, dt, Q_nom)
    dSOC = (I * dt) / (Q_nom * 3600) * 100;
    SOC_est = SOC_prev - dSOC;
    SOC_est = max(0, min(100, SOC_est));
end

function [SOC_est, x_kf] = SOC_Kalman_Filter(SOC_prev, I, V_term, V_oc, dt, Q_nom, x_kf_prev, P_prev, KF_params)
    Q_process = KF_params.Q_process;
    R_measure = KF_params.R_measure;
    
    dSOC = (I * dt) / (Q_nom * 3600) * 100;
    x_kf_pred = x_kf_prev - dSOC;
    P_pred = P_prev + Q_process;
    
    z = V_term - V_oc;
    K = P_pred / (P_pred + R_measure);
    dV_dSOC = -0.05;
    
    x_kf = x_kf_pred + K * z / dV_dSOC;
    P = (1 - K / dV_dSOC) * P_pred;
    
    SOC_est = max(0, min(100, x_kf));
end

clear all; close all; clc;
BMS_Parameters;
load('Battery_Model_Data.mat');

fprintf('\n========================================\n');
fprintf('SOC ESTIMATION ANALYSIS\n');
fprintf('========================================\n\n');

SOC_coulomb = zeros(length(t), 1);
SOC_kalman = zeros(length(t), 1);
SOC_ocv = zeros(length(t), 1);

x_kf = SOC.Initial_Value;
P_kf = KF.Initial_Uncertainty;
KF_params.Q_process = KF.Process_Noise;
KF_params.R_measure = KF.Measurement_Noise;

load('OCV_Table.mat', 'OCV_Table');

fprintf('Running SOC estimation algorithms...\n');

for k = 1:length(t)
    if k == 1
        SOC_coulomb(k) = SOC.Initial_Value;
        SOC_kalman(k) = SOC.Initial_Value;
    else
        dt_step = t(k) - t(k-1);
        SOC_coulomb(k) = SOC_Coulomb_Counting(SOC_coulomb(k-1), I_array(k), dt_step, BMS.Nominal_Capacity);
        
        V_oc_est = interp1(OCV_Table(:,1), OCV_Table(:,2), SOC_coulomb(k), 'linear');
        V_oc_est = V_oc_est * BMS.Num_Cells_Series;
        
        [SOC_kalman(k), x_kf] = SOC_Kalman_Filter(SOC_kalman(k-1), I_array(k), V_terminal(k), V_oc_est, dt_step, BMS.Nominal_Capacity, x_kf, P_kf, KF_params);
        P_kf = (1 - KF_params.R_measure / (KF_params.R_measure + P_kf)) * P_kf;
    end
    
    SOC_ocv(k) = interp1(OCV_Table(:,1), OCV_Table(:,2), V_oc(k), 'linear');
end

Error_Kalman = SOC_kalman - SOC_coulomb;
Error_OCV = SOC_ocv - SOC_coulomb;

MAE_Kalman = mean(abs(Error_Kalman));
RMSE_Kalman = sqrt(mean(Error_Kalman.^2));
MAE_OCV = mean(abs(Error_OCV));
RMSE_OCV = sqrt(mean(Error_OCV.^2));

figure('Position', [100 100 1200 800]);
subplot(2,3,1); plot(t, SOC_coulomb, 'b-', 'LineWidth', 2); hold on; plot(t, SOC_kalman, 'r--', 'LineWidth', 1.5); plot(t, SOC_ocv, 'g:', 'LineWidth', 1.5); xlabel('Time (s)'); ylabel('SOC (%)'); title('SOC Comparison'); legend('Coulomb', 'Kalman', 'OCV'); grid on;
subplot(2,3,2); plot(t, Error_Kalman, 'r', 'LineWidth', 1.5); xlabel('Time (s)'); ylabel('Error (%)'); title(sprintf('Kalman Error (MAE: %.2f%%)', MAE_Kalman)); grid on; hold on; plot(t, zeros(size(t)), 'k--', 'LineWidth', 0.5);
subplot(2,3,3); plot(t, Error_OCV, 'g', 'LineWidth', 1.5); xlabel('Time (s)'); ylabel('Error (%)'); title(sprintf('OCV Error (MAE: %.2f%%)', MAE_OCV)); grid on; hold on; plot(t, zeros(size(t)), 'k--', 'LineWidth', 0.5);
subplot(2,3,4); yyaxis left; plot(t, V_terminal, 'b', 'LineWidth', 1.5); ylabel('Voltage (V)'); yyaxis right; plot(t, I_array, 'r', 'LineWidth', 1.5); ylabel('Current (A)'); xlabel('Time (s)'); title('V-I Profile'); grid on;
subplot(2,3,5); plot(t, Temp_array, 'LineWidth', 2); xlabel('Time (s)'); ylabel('Temperature (°C)'); title('Battery Temperature'); grid on;
subplot(2,3,6); histogram(Error_Kalman, 30, 'FaceColor', 'r', 'Alpha', 0.7); hold on; histogram(Error_OCV, 30, 'FaceColor', 'g', 'Alpha', 0.7); xlabel('Error (%)'); ylabel('Frequency'); title('Error Distribution'); legend(sprintf('Kalman (σ=%.3f)', std(Error_Kalman)), sprintf('OCV (σ=%.3f)', std(Error_OCV))); grid on;
sgtitle('State of Charge (SOC) Estimation Results', 'FontSize', 14, 'FontWeight', 'bold');

fprintf('\nSOC ESTIMATION RESULTS:\n');
fprintf('========================\n\n');
fprintf('COULOMB COUNTING:\n'); fprintf('  Initial: %.2f %%\n', SOC_coulomb(1)); fprintf('  Final: %.2f %%\n', SOC_coulomb(end)); fprintf('  Min: %.2f %%\n', min(SOC_coulomb)); fprintf('  Max: %.2f %%\n\n', max(SOC_coulomb));
fprintf('KALMAN FILTER:\n'); fprintf('  MAE: %.3f %%\n', MAE_Kalman); fprintf('  RMSE: %.3f %%\n\n', RMSE_Kalman);
fprintf('OCV-BASED:\n'); fprintf('  MAE: %.3f %%\n', MAE_OCV); fprintf('  RMSE: %.3f %%\n', RMSE_OCV);
fprintf('========================================\n');

save('SOC_Estimation_Data.mat', 't', 'SOC_coulomb', 'SOC_kalman', 'SOC_ocv', 'Error_Kalman', 'Error_OCV');
fprintf('\nResults saved to SOC_Estimation_Data.mat\n');