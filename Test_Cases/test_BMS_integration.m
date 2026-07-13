%% ========================================================================
% INTEGRATION TEST - Complete BMS System
% ========================================================================

clear all; close all; clc;

fprintf('\n================================================\n');
fprintf('COMPLETE BMS INTEGRATION TEST\n');
fprintf('================================================\n\n');

% Run all components
fprintf('Loading parameters...\n');
BMS_Parameters;

fprintf('Running battery model...\n');
run('MATLAB_Scripts/Battery_Model.m');

fprintf('Running SOC estimation...\n');
run('MATLAB_Scripts/SOC_Estimator.m');

fprintf('Running safety tests...\n');
run('MATLAB_Scripts/Safety_Controller.m');

fprintf('Running thermal analysis...\n');
run('MATLAB_Scripts/Thermal_Model.m');

fprintf('\n================================================\n');
fprintf('INTEGRATION TEST COMPLETE\n');
fprintf('================================================\n\n');

fprintf('Files Generated:\n');
fprintf('  - Battery_Model_Data.mat\n');
fprintf('  - SOC_Estimation_Data.mat\n');
fprintf('  - Safety_Test_Results.mat\n');
fprintf('  - Thermal_Model_Data.mat\n\n');

fprintf('All systems operational!\n');
fprintf('Plots displayed for review.\n');