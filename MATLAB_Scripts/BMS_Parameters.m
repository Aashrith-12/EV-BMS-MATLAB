% ========================================================================
% BATTERY MANAGEMENT SYSTEM (BMS) - MAIN PARAMETERS
% ========================================================================
% Author: BMS Development Team
% Purpose: Define all system parameters for the BMS simulation
% Date: 2024
% ========================================================================

clear all; close all; clc;

%% ================== BATTERY PACK CONFIGURATION =======================

% Physical Configuration
BMS.Num_Cells_Series = 96;          % Number of cells in series
BMS.Num_Cells_Parallel = 1;         % Number of parallel strings
BMS.Total_Cells = BMS.Num_Cells_Series * BMS.Num_Cells_Parallel;

% Voltage Specifications (Per Cell)
BMS.Nominal_Voltage_Cell = 3.7;     % V (nominal per cell)
BMS.Min_Cell_Voltage = 2.5;         % V (discharge cutoff)
BMS.Max_Cell_Voltage = 4.2;         % V (charge limit)
BMS.Nominal_Voltage_Pack = BMS.Nominal_Voltage_Cell * BMS.Num_Cells_Series;

% Capacity Specifications
BMS.Nominal_Capacity = 75;          % Ah (battery pack)
BMS.Energy_Capacity = BMS.Nominal_Capacity * BMS.Nominal_Voltage_Pack; % Wh

% Current Limits
BMS.Max_Discharge_Current = 150;    % A (maximum discharge)
BMS.Max_Charge_Current = 100;       % A (maximum charge)
BMS.Continuous_Discharge = 120;     % A (continuous discharge)
BMS.Continuous_Charge = 80;         % A (continuous charge)

% Temperature Specifications (°C)
BMS.Min_Operating_Temp = -20;       % Minimum operating temperature
BMS.Max_Operating_Temp = 55;        % Maximum operating temperature
BMS.Optimal_Temp = 25;              % Optimal operating temperature
BMS.Min_Charge_Temp = 0;            % Minimum charge temperature
BMS.Max_Charge_Temp = 45;           % Maximum charge temperature
BMS.Thermal_Runaway_Temp = 80;      % Thermal runaway threshold

%% ==================== CELL SPECIFICATIONS =============================

% Cell Model Parameters (LiPo/LiFePO4)
Cell.Type = 'LiPo';                 % Battery type
Cell.Nominal_Voltage = 3.7;         % V
Cell.Capacity = BMS.Nominal_Capacity / BMS.Num_Cells_Series; % Ah per cell
Cell.Internal_Resistance = 0.02;    % Ohms (initial)
Cell.RC_Time_Constant = 10;         % seconds (resistor-capacitor pair)
Cell.Charge_Transfer_Resistance = 0.001; % Ohms

% Electrochemical Parameters
Cell.OCV_Min = 2.5;                 % Open circuit voltage minimum
Cell.OCV_Max = 4.2;                 % Open circuit voltage maximum
Cell.OCV_Nominal = 3.7;             % Open circuit voltage nominal
Cell.Temperature_Coefficient = -0.003; % V/°C (OCV temperature dependence)

% Thermal Parameters
Cell.Mass = 0.060;                  % kg (per cell)
Cell.Specific_Heat = 900;           % J/(kg·K)
Cell.Thermal_Conductivity = 0.5;    % W/(m·K)
Cell.Heat_Generation_Coeff = 0.1;   % Coefficient for I²R heating

% State of Health (SOH) Parameters
Cell.Initial_SOH = 100;             % % (initial health)
Cell.Cycle_Life = 1000;             % cycles to 80% capacity
Cell.Calendar_Life = 10;            % years
Cell.Degradation_Rate = 0.00001;    % % per cycle

%% ==================== STATE ESTIMATION PARAMETERS ======================

% State of Charge (SOC) Estimation
SOC.Initial_Value = 50;             % % (initial SOC)
SOC.Method = 'Coulomb_Counting';    % Estimation method
SOC.Min_Threshold = 5;              % % (low battery warning)
SOC.Max_Threshold = 95;             % % (full charge threshold)
SOC.Coulomb_Counter_Gain = 1 / (BMS.Nominal_Capacity * 3600); % Convert to SOC

% Kalman Filter Parameters (for SOC estimation)
KF.Process_Noise = 0.01;            % Q parameter
KF.Measurement_Noise = 0.1;         % R parameter
KF.Initial_Uncertainty = 0.1;       % Initial state uncertainty

% Open Circuit Voltage (OCV) Lookup Table
% SOC (%) vs OCV (V)
OCV_Table = [
    0   2.5;
    10  3.2;
    20  3.4;
    30  3.55;
    40  3.65;
    50  3.7;
    60  3.75;
    70  3.8;
    80  3.9;
    90  4.05;
    100 4.2
];

%% ==================== PROTECTION & SAFETY PARAMETERS ====================

% Voltage Protection
Safety.OVP_Threshold = BMS.Max_Cell_Voltage + 0.1;  % Over voltage
Safety.OVP_Recovery = BMS.Max_Cell_Voltage - 0.05;  % Recovery voltage
Safety.UVP_Threshold = BMS.Min_Cell_Voltage - 0.1;  % Under voltage
Safety.UVP_Recovery = BMS.Min_Cell_Voltage + 0.2;   % Recovery voltage

% Current Protection
Safety.OCP_Discharge_Threshold = BMS.Max_Discharge_Current + 10; % A
Safety.OCP_Charge_Threshold = BMS.Max_Charge_Current + 10;       % A
Safety.OCP_Recovery_Time = 1;                        % seconds
Safety.OCP_Response_Delay = 0.01;                    % seconds

% Temperature Protection
Safety.OTP_Discharge_High = 60;     % °C (discharge high temp)
Safety.OTP_Charge_High = 50;        % °C (charge high temp)
Safety.OTP_Discharge_Low = -20;     % °C (discharge low temp)
Safety.OTP_Charge_Low = 0;          % °C (charge low temp)
Safety.OTP_Recovery_Margin = 5;     % °C hysteresis

% Thermal Runaway Protection
Safety.Thermal_Runaway_Threshold = 80;  % °C
Safety.Thermal_Runaway_Rate = 5;        % °C/second rate threshold
Safety.Emergency_Shutdown_Temp = 85;    % °C

% Fault Detection
Safety.Voltage_Imbalance_Threshold = 0.3;  % V (max cell voltage difference)
Safety.Current_Sensor_Fault_Threshold = 10; % A (inconsistency)
Safety.Temp_Sensor_Fault_Threshold = 5;     % °C (inconsistency)

%% ==================== CELL BALANCING PARAMETERS ==========================

% Passive Balancing
Balancing.Passive_Method = 'Fixed_Resistor';
Balancing.Passive_Resistor = 50;    % Ohms
Balancing.Passive_Balancing_Current = 0.08; % A per cell
Balancing.Passive_Threshold = 0.05; % V (voltage difference to trigger)

% Active Balancing
Balancing.Active_Method = 'Switched_Capacitor';
Balancing.Active_Balancing_Current = 0.5; % A per cell
Balancing.Active_Threshold = 0.1;   % V (voltage difference to trigger)
Balancing.Capacitor_Size = 100e-6;  % Farads
Balancing.Switching_Frequency = 1000; % Hz

% Balancing Control
Balancing.Enable = true;            % Enable/disable balancing
Balancing.Target_Voltage_Difference = 0.02; % V
Balancing.Max_Cells_Balanced_Simultaneously = 12;
Balancing.Update_Interval = 10;     % seconds

%% ==================== THERMAL MANAGEMENT PARAMETERS ====================

% Cooling System
Thermal.Cooling_Type = 'Active_Liquid';
Thermal.Max_Cooling_Power = 5000;   % W
Thermal.Coolant_Flow_Rate = 0.5;    % L/min
Thermal.Coolant_Temp_Setpoint = 25; % °C
Thermal.Cooling_Response_Time = 2;  % seconds

% Heating System
Thermal.Heating_Type = 'PTC_Heater';
Thermal.Max_Heating_Power = 2000;   % W
Thermal.Heating_Setpoint = 15;      % °C
Thermal.Heating_Response_Time = 5;  % seconds

% Thermal Model Parameters
Thermal.Ambient_Temp = 25;          % °C
Thermal.Convection_Coefficient = 50; % W/(m²·K)
Thermal.Surface_Area = 0.5;         % m² (total surface area)
Thermal.Thermal_Mass = 20;          % Thermal mass equivalent

% Temperature Sensor Configuration
Thermal.Num_Temp_Sensors = 8;       % Number of temperature sensors
Thermal.Sensor_Locations = 'Distributed'; % Sensor placement
Thermal.Sensor_Update_Rate = 10;    % Hz

%% ==================== COMMUNICATION & INTERFACE ==========================

% CAN Bus Configuration (future implementation)
Comm.CAN_Baudrate = 500000;         % bps
Comm.Message_Update_Rate = 100;     % Hz
Comm.Protocol = 'SAE_J1939';        % Communication standard

% Data Logging
Logging.Enable = true;              % Enable data logging
Logging.Sample_Rate = 100;          % Hz
Logging.Buffer_Size = 100000;       % samples
Logging.Save_Directory = './Data/';

%% ==================== SIMULATION PARAMETERS ==============================

% Time Configuration
Sim.Start_Time = 0;                 % seconds
Sim.End_Time = 3600;                % seconds (1 hour)
Sim.Time_Step = 0.01;               % seconds
Sim.Time_Points = Sim.Start_Time:Sim.Time_Step:Sim.End_Time;

% Solver Settings
Sim.Solver = 'ode45';               % Solver type
Sim.Relative_Tolerance = 1e-6;      % Relative tolerance
Sim.Absolute_Tolerance = 1e-9;      % Absolute tolerance

% Model Type
Sim.Use_Simplified_Model = false;   % Use simplified or full model
Sim.Include_Thermal_Model = true;   % Include thermal dynamics
Sim.Include_Aging_Model = false;    % Include battery aging

%% ==================== DISPLAY PARAMETERS ==================================

% Print Configuration
fprintf('========================================\n');
fprintf('BMS PARAMETERS INITIALIZED\n');
fprintf('========================================\n\n');

fprintf('BATTERY PACK CONFIGURATION:\n');
fprintf('  Total Cells (Series): %d\n', BMS.Num_Cells_Series);
fprintf('  Pack Voltage: %.1f V\n', BMS.Nominal_Voltage_Pack);
fprintf('  Pack Capacity: %.1f Ah\n', BMS.Nominal_Capacity);
fprintf('  Total Energy: %.1f Wh\n\n', BMS.Energy_Capacity);

fprintf('PROTECTION THRESHOLDS:\n');
fprintf('  Max Cell Voltage: %.2f V\n', BMS.Max_Cell_Voltage);
fprintf('  Min Cell Voltage: %.2f V\n', BMS.Min_Cell_Voltage);
fprintf('  Max Discharge Current: %.1f A\n', BMS.Max_Discharge_Current);
fprintf('  Max Temperature: %.1f °C\n\n', BMS.Max_Operating_Temp);

fprintf('STATE ESTIMATION:\n');
fprintf('  Initial SOC: %.1f %%\n', SOC.Initial_Value);
fprintf('  Estimation Method: %s\n\n', SOC.Method);

fprintf('SIMULATION PARAMETERS:\n');
fprintf('  Duration: %.1f seconds\n', Sim.End_Time);
fprintf('  Time Step: %.4f seconds\n', Sim.Time_Step);
fprintf('  Data Points: %d\n\n', length(Sim.Time_Points));

% Save OCV table
save('OCV_Table.mat', 'OCV_Table');
fprintf('OCV lookup table saved!\n');
fprintf('========================================\n');

% Make all variables available in workspace
clearvars -except BMS Cell SOC KF OCV_Table Safety Balancing Thermal Comm Logging Sim
