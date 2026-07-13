# Simulink Models for BMS

This directory contains Simulink models for the Battery Management System.

## Models (To be created)

1. **BMS_Main_Model.slx** - Main BMS control system
2. **Battery_Cell_Model.slx** - Single cell equivalent circuit
3. **Battery_Pack_Model.slx** - Multi-cell battery pack
4. **Thermal_Management.slx** - Thermal control system
5. **Safety_System.slx** - Safety protection logic
6. **Plant_Model.slx** - Vehicle plant model

## Getting Started

1. Open MATLAB/Simulink
2. Load desired model: `open('BMS_Main_Model.slx')`
3. Run simulation: Press Ctrl+T or Run button
4. Analyze results in workspace

## Model Architecture

Each model follows this structure:
- **Inputs**: Sensor readings (V, I, T)
- **Processing**: State estimators, controllers, protections
- **Outputs**: Control signals, diagnostics, data logging

## Integration with MATLAB Scripts

The Simulink models use parameters defined in:
- `MATLAB_Scripts/BMS_Parameters.m`
- Generated lookup tables (OCV_Table.mat)

## Simulation Settings

- Solver: ode45 (variable step)
- Step size: 0.01 seconds
- Duration: 3600 seconds (1 hour)
- Sample time: 0.1 seconds

## Notes

- Models use Bus objects for signal management
- Subsystems are modular for easy testing
- All parameters configurable via workspace
