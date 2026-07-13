%% ========================================================================
% BATTERY MODEL - Equivalent Circuit Model (ECM)
% ========================================================================
% Purpose: Simulate battery voltage and current response
% Model: 1RC (Resistor-Capacitor) equivalent circuit
% Input: Current (A), Temperature (°C)
% Output: Terminal Voltage (V), State Variables
% ========================================================================

function [V_terminal, V_oc, P_loss] = Battery_Model(I, SOC, T, Cell_Params)
    if nargin < 4
        error('Battery_Model requires: Current, SOC, Temperature, Cell_Params');
    end
    
    % Get OCV from SOC
    if isfile('OCV_Table.mat')
        load('OCV_Table.mat', 'OCV_Table');
    else
        OCV_Table = [0 2.5; 10 3.2; 20 3.4; 30 3.55; 40 3.65; 50 3.7; 60 3.75; 70 3.8; 80 3.9; 90 4.05; 100 4.2];
    end
    
    V_oc_single = interp1(OCV_Table(:,1), OCV_Table(:,2), SOC, 'linear');
    Temp_Effect = Cell_Params.Temperature_Coefficient * (T - 25);
    V_oc_single = V_oc_single + Temp_Effect;
    V_oc = V_oc_single * Cell_Params.num_cells;
    
    % Internal resistance (temperature & SOC dependent)
    R_internal = Cell_Params.Internal_Resistance;
    if T < 25
        R_internal = R_internal * (1 + 0.005 * (25 - T));
    else
        R_internal = R_internal * (1 + 0.002 * (T - 25));
    end
    
    if SOC < 20
        R_internal = R_internal * (1 + 0.1 * (20 - SOC)/20);
    elseif SOC > 80
        R_internal = R_internal * (1 + 0.08 * (SOC - 80)/20);
    end
    
    R_internal_pack = R_internal * Cell_Params.num_cells;
    
    % RC branch
    R_rc = 0.3 * R_internal_pack;
    C_rc = 5000;
    V_rc = 0;
    
    % Terminal voltage
    V_terminal = V_oc - I * R_internal_pack - V_rc;
    
    % Power loss
    P_joule = I^2 * R_internal_pack;
    P_polarization = I * V_rc;
    P_loss = P_joule + P_polarization;
end

clear all; close all; clc;
BMS_Parameters;

fprintf('\n========================================\n');
fprintf('BATTERY MODEL INITIALIZATION\n');
fprintf('========================================\n\n');

t = Sim.Time_Points';
dt = Sim.Time_Step;

V_terminal = zeros(length(t), 1);
V_oc = zeros(length(t), 1);
P_loss = zeros(length(t), 1);
SOC_array = zeros(length(t), 1);
I_array = zeros(length(t), 1);
Temp_array = zeros(length(t), 1);

Cell_Params.num_cells = BMS.Num_Cells_Series;
Cell_Params.Internal_Resistance = 0.02;
Cell_Params.Temperature_Coefficient = -0.003;

SOC_array(1) = SOC.Initial_Value;
Temp_array(1) = 25;

I_profile = zeros(length(t), 1);
idx_discharge = t <= 1000;
I_profile(idx_discharge) = 50;
idx_charge = (t > 1000) & (t <= 3000);
I_profile(idx_charge) = -30;
idx_rest = t > 3000;
I_profile(idx_rest) = 0;

fprintf('Running battery simulation...\n');

for k = 1:length(t)-1
    I_current = I_profile(k);
    I_array(k) = I_current;
    
    [V_term, V_oc_val, P_loss_val] = Battery_Model(I_current, SOC_array(k), Temp_array(k), Cell_Params);
    V_terminal(k) = V_term;
    V_oc(k) = V_oc_val;
    P_loss(k) = P_loss_val;
    
    dSOC = -(I_current * dt) / (BMS.Nominal_Capacity * 3600) * 100;
    SOC_array(k+1) = SOC_array(k) + dSOC;
    SOC_array(k+1) = max(0, min(100, SOC_array(k+1)));
    
    m_total = Cell_Params.num_cells * 0.060;
    cp = 900;
    P_cooling = Thermal.Convection_Coefficient * Thermal.Surface_Area * (Temp_array(k) - Thermal.Ambient_Temp);
    dT = (P_loss_val - P_cooling) / (m_total * cp);
    Temp_array(k+1) = Temp_array(k) + dT * dt;
end

V_terminal(end) = V_terminal(end-1);
V_oc(end) = V_oc(end-1);
P_loss(end) = P_loss(end-1);
I_array(end) = I_profile(end);

fprintf('Simulation complete! Generating plots...\n\n');

figure('Position', [100 100 1200 800]);
subplot(3,2,1); plot(t, I_array, 'b', 'LineWidth', 1.5); xlabel('Time (s)'); ylabel('Current (A)'); title('Current Profile'); grid on;
subplot(3,2,2); plot(t, V_terminal, 'b', 'LineWidth', 1.5); hold on; plot(t, V_oc, 'r--', 'LineWidth', 1); xlabel('Time (s)'); ylabel('Voltage (V)'); title('Terminal Voltage vs OCV'); legend('Terminal', 'OCV'); grid on;
subplot(3,2,3); plot(t, SOC_array, 'g', 'LineWidth', 1.5); xlabel('Time (s)'); ylabel('SOC (%)'); title('State of Charge'); grid on; ylim([0 100]);
subplot(3,2,4); plot(t, Temp_array, 'm', 'LineWidth', 1.5); xlabel('Time (s)'); ylabel('Temperature (°C)'); title('Battery Temperature'); grid on;
subplot(3,2,5); plot(t, P_loss, 'c', 'LineWidth', 1.5); xlabel('Time (s)'); ylabel('Power (W)'); title('Power Loss'); grid on;
subplot(3,2,6); Energy = cumsum(I_array) * dt / 3600; plot(t, Energy, 'k', 'LineWidth', 1.5); xlabel('Time (s)'); ylabel('Energy (Ah)'); title('Cumulative Energy'); grid on;
sgtitle('Battery Model Simulation Results', 'FontSize', 14, 'FontWeight', 'bold');

fprintf('SIMULATION RESULTS:\n');
fprintf('Initial SOC: %.2f %%\n', SOC_array(1));
fprintf('Final SOC: %.2f %%\n', SOC_array(end));
fprintf('Min Voltage: %.2f V\n', min(V_terminal));
fprintf('Max Voltage: %.2f V\n', max(V_terminal));
fprintf('Max Temperature: %.2f °C\n', max(Temp_array));
fprintf('========================================\n');

save('Battery_Model_Data.mat', 't', 'V_terminal', 'V_oc', 'I_array', 'SOC_array', 'Temp_array', 'P_loss');
fprintf('Data saved to Battery_Model_Data.mat\n');