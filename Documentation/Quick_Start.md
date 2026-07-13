# Quick Start Guide - BMS MATLAB Simulation

## ✅ Prerequisites

- ✓ MATLAB R2019b or later
- ✓ Simulink
- ✓ Control System Toolbox
- ✓ This repository cloned to your computer

---

## 🚀 Getting Started (5 Minutes)

### Step 1: Add Path to MATLAB
```matlab
% In MATLAB command window:
addpath(genpath(pwd))
```

### Step 2: Run Parameters
```matlab
% Load all system parameters
BMS_Parameters
```

**Expected Output**:
```
========================================
BMS PARAMETERS INITIALIZED
========================================

BATTERY PACK CONFIGURATION:
  Total Cells (Series): 96
  Pack Voltage: 355.2 V
  Pack Capacity: 75.0 Ah
  Total Energy: 26640.0 Wh
  ...
```

### Step 3: Run Battery Model
```matlab
% Simulate battery electrical behavior
Battery_Model
```

**Output**: 
- 6 plots showing voltage, current, temperature, power
- Data saved to `Battery_Model_Data.mat`

### Step 4: Run SOC Estimation
```matlab
% Test state of charge estimation
SOC_Estimator
```

**Output**:
- 6 plots comparing 3 SOC estimation methods
- Error analysis
- Data saved to `SOC_Estimation_Data.mat`

### Step 5: Run Safety Tests
```matlab
% Test protection systems
Safety_Controller
```

**Output**:
- 6 plots showing safety responses
- Test results for OVP, UVP, OCP, OTP
- Data saved to `Safety_Test_Results.mat`

---

## 📊 Understanding the Results

### Battery Model Plots

**Plot 1: Current Profile**
- Shows discharge/charge cycles
- Helps validate simulation scenarios

**Plot 2: Terminal Voltage vs OCV**
- Terminal voltage includes ohmic losses
- OCV is theoretical ideal voltage

**Plot 3: State of Charge**
- Tracks energy remaining in battery
- Should be 0-100%

**Plot 4: Temperature**
- Shows heat generation during operation
- Critical for safety and longevity

**Plot 5: Power Loss**
- I²R losses (Joule heating)
- Indicates efficiency

**Plot 6: Energy**
- Cumulative charge flow
- Used to verify Coulomb counting

### SOC Estimation Comparison

**Coulomb Counting**: Simple, drifts over time
**Kalman Filter**: Best accuracy, self-correcting
**OCV-based**: Reference method, requires cell rest

### Safety Test Results

- **Normal Operation**: Should show all safe conditions
- **Over-Voltage**: Detects when V > 4.3V
- **Over-Current**: Detects when |I| > 160A
- **Over-Temperature**: Detects when T > 60°C

---

## 🔧 Customization

### Change Battery Parameters

Edit `BMS_Parameters.m`:

```matlab
% Example: Change capacity to 100 Ah
BMS.Nominal_Capacity = 100;

% Example: Change number of cells
BMS.Num_Cells_Series = 120;

% Example: Change temperature limit
BMS.Max_Operating_Temp = 65;
```

Then re-run the scripts.

### Change Simulation Duration

In `BMS_Parameters.m`:

```matlab
Sim.End_Time = 7200;  % Change to 2 hours (default: 3600s = 1 hour)
```

### Change Current Profile

In `Battery_Model.m`, modify the "Define Load Profile" section:

```matlab
% Example: Constant 50A discharge for entire simulation
I_profile = ones(length(t), 1) * 50;

% Example: WLTP driving cycle (use real data)
load('WLTP_cycle.mat');
I_profile = WLTP_current;
```

---

## 📁 File Organization

```
MATLAB_Scripts/
├── BMS_Parameters.m          ← START HERE
├── Battery_Model.m           ← Run 1st
├── SOC_Estimator.m          ← Run 2nd
├── Safety_Controller.m       ← Run 3rd
├── Thermal_Model.m          ← Coming soon
├── Cell_Balancer.m          ← Coming soon
└── Utilities.m              ← Coming soon

Documentation/
├── BMS_Architecture.md       ← Read first
├── Physics_and_Math.md       ← Background theory
├── Quick_Start.md           ← This file
└── Testing_Guide.md         ← Validation procedures

Simulink_Models/
├── BMS_Main_Model.slx       ← Coming soon
├── Battery_Cell_Model.slx   ← Coming soon
└── Safety_System.slx        ← Coming soon

Test_Cases/
├── test_SOC_estimation.m    ← Coming soon
├── test_thermal_management.m ← Coming soon
└── test_safety_limits.m     ← Coming soon

Data/
└── (Generated simulation results)
```

---

## 🐛 Troubleshooting

### Issue: "Undefined function or variable"

**Solution**:
```matlab
% Make sure you're in the correct directory
cd('path/to/EV-BMS-MATLAB')
addpath(genpath(pwd))
```

### Issue: "Matrix dimensions don't match"

**Solution**: Ensure you ran `BMS_Parameters.m` first
```matlab
BMS_Parameters  % Always run this first!
```

### Issue: Plots don't show

**Solution**: Make sure figures are enabled
```matlab
set(groot,'DefaultFigureVisible','on')
```

### Issue: "Cannot find OCV_Table.mat"

**Solution**: This is created by `BMS_Parameters.m`, so run it first

### Issue: Memory issues with large simulations

**Solution**: Reduce `Sim.Time_Step` or `Sim.End_Time`
```matlab
% Reduce time points
Sim.End_Time = 1800;  % Reduce from 3600 to 1800 seconds
Sim.Time_Step = 0.1;  % Increase from 0.01 to 0.1 seconds
```

---

## 📊 Typical Simulation Results

### SOC Estimation Accuracy
```
Coulomb Counting:
  Error after 1 hour: ~1-3%
  
Kalman Filter:
  Error after 1 hour: ~0.1-0.5%
  Much more accurate!
  
OCV-based:
  Error: ~0.5-2% (reference)
  Needs battery at rest
```

### Thermal Response
```
At 50A discharge:
  Temperature rise: ~0.5°C/minute
  Peak temperature: ~35-40°C after 1 hour
  Cooling stops drift
```

### Safety Response
```
Over-Voltage: Triggers immediately when V > 4.3V
Over-Current: Triggers immediately when I > 160A
Over-Temperature: Triggers immediately when T > 60°C
Response time: <1 millisecond
```

---

## 🎯 Next Steps

1. ✅ Run all three main scripts
2. ✅ Understand the plots and outputs
3. ⭕ Modify parameters and re-run
4. ⭕ Create Simulink models (coming soon)
5. ⭕ Run test cases for validation
6. ⭕ Implement on actual hardware

---

## 📞 Getting Help

### Common Questions

**Q: Why is my SOC estimate drifting?**  
A: This is normal for Coulomb counting. The Kalman Filter corrects this automatically.

**Q: Can I test with real driving data?**  
A: Yes! Replace `I_profile` with your actual current measurements.

**Q: How do I export results?**  
A: All results are already saved to `.mat` files. Use:
```matlab
load('Battery_Model_Data.mat')
```

**Q: Can I run this on a microcontroller?**  
A: Yes, but you'll need to simplify the algorithms and use C code generation.

---

## 📝 Notes

- All simulations assume ideal sensors (no noise)
- Temperature model is simplified
- Cell aging is not included yet
- CAN communication not implemented yet

---

**Congratulations! You now have a working BMS simulator! 🎉**

For detailed theory, read `Physics_and_Math.md`  
For architecture details, read `BMS_Architecture.md`

