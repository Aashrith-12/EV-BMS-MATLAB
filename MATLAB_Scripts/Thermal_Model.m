%% ========================================================================
% THERMAL MODEL - Battery Pack Temperature Simulation
% ========================================================================

clear all; close all; clc;
BMS_Parameters;
load('Battery_Model_Data.mat');

fprintf('\n========================================\n');
fprintf('THERMAL MANAGEMENT SIMULATION\n');
fprintf('========================================\n\n');

% Thermal parameters
m_total = Cell_Params.num_cells * 0.060; % Total mass (kg)
cp = 900; % Specific heat (J/kg·K)
hA = Thermal.Convection_Coefficient * Thermal.Surface_Area; % h*A

% Temperature simulation (using P_loss from Battery Model)
Temp_sim = zeros(length(t), 1);
Cooling_Power = zeros(length(t), 1);
Heating_Power = zeros(length(t), 1);
Net_Heat = zeros(length(t), 1);

Temp_sim(1) = 25; % Initial temperature

for k = 1:length(t)-1
    dt = t(k+1) - t(k);
    
    % Heat generation
    Q_gen = P_loss(k);
    
    % Cooling power (Newton's law)
    Q_cool = hA * (Temp_sim(k) - Thermal.Ambient_Temp);
    
    % Heating (if needed for cold start)
    Q_heat = 0;
    if Temp_sim(k) < Thermal.Heating_Setpoint && I_array(k) < 10
        Q_heat = Thermal.Max_Heating_Power * 0.5;
    end
    
    Cooling_Power(k) = Q_cool;
    Heating_Power(k) = Q_heat;
    Net_Heat(k) = Q_gen - Q_cool + Q_heat;
    
    % Temperature change
    dT = Net_Heat(k) / (m_total * cp);
    Temp_sim(k+1) = Temp_sim(k) + dT * dt;
    
    % Clamp to valid range
    Temp_sim(k+1) = max(Thermal.Ambient_Temp - 10, Temp_sim(k+1));
end

% Plots
figure('Position', [100 100 1200 800]);

subplot(2,2,1);
plot(t, Temp_sim, 'b-', 'LineWidth', 2);
hold on;
plot(t, ones(size(t)) * Thermal.OTP_Discharge_High, 'r--', 'LineWidth', 1.5, 'DisplayName', 'OTP High');
plot(t, ones(size(t)) * Thermal.Ambient_Temp, 'g--', 'LineWidth', 1.5, 'DisplayName', 'Ambient');
xlabel('Time (s)'); ylabel('Temperature (°C)'); title('Temperature Profile');
legend; grid on;

subplot(2,2,2);
plot(t, P_loss, 'r', 'LineWidth', 1.5, 'DisplayName', 'Heat Gen');
hold on;
plot(t, Cooling_Power, 'b', 'LineWidth', 1.5, 'DisplayName', 'Cooling');
plot(t, Heating_Power, 'g', 'LineWidth', 1.5, 'DisplayName', 'Heating');
xlabel('Time (s)'); ylabel('Power (W)'); title('Thermal Power Balance');
legend; grid on;

subplot(2,2,3);
plot(t, Net_Heat, 'purple', 'LineWidth', 1.5);
hold on; plot(t, zeros(size(t)), 'k--', 'LineWidth', 0.5);
xlabel('Time (s)'); ylabel('Net Heat (W)'); title('Net Heat Flow');
grid on;

subplot(2,2,4);
yyaxis left;
plot(t, I_array, 'b', 'LineWidth', 1.5);
ylabel('Current (A)');
yyaxis right;
plot(t, Temp_sim, 'r', 'LineWidth', 1.5);
ylabel('Temperature (°C)');
xlabel('Time (s)'); title('Current vs Temperature');
grid on;

sgtitle('Thermal Management System Analysis', 'FontSize', 14, 'FontWeight', 'bold');

fprintf('THERMAL ANALYSIS RESULTS:\n');
fprintf('==========================\n\n');
fprintf('Initial Temperature: %.2f °C\n', Temp_sim(1));
fprintf('Final Temperature: %.2f °C\n', Temp_sim(end));
fprintf('Max Temperature: %.2f °C\n', max(Temp_sim));
fprintf('Min Temperature: %.2f °C\n', min(Temp_sim));
fprintf('Temperature Rise: %.2f °C\n\n', max(Temp_sim) - Temp_sim(1));
fprintf('Max Heat Generation: %.0f W\n', max(P_loss));
fprintf('Max Cooling Power: %.0f W\n', max(Cooling_Power));
fprintf('Avg Cooling Power: %.0f W\n\n', mean(Cooling_Power));
fprintf('Thermal Time Constant: %.1f seconds\n', (m_total * cp) / hA);
fprintf('========================================\n');

save('Thermal_Model_Data.mat', 't', 'Temp_sim', 'P_loss', 'Cooling_Power', 'Heating_Power', 'Net_Heat');
fprintf('Thermal data saved to Thermal_Model_Data.mat\n');