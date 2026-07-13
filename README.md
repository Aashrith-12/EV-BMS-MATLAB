# Intelligent Battery Management System (BMS) for Electric Vehicles

## 📋 Project Overview

This project implements a comprehensive **Battery Management System (BMS)** for Electric Vehicles using MATLAB/Simulink. The BMS monitors, protects, and optimizes battery pack performance in real-time.

## 🎯 Key Features

### 1. **State of Charge (SOC) Estimation**
- Coulomb counting method
- Kalman filter-based estimation
- Improved accuracy with voltage compensation

### 2. **State of Health (SOH) Monitoring**
- Battery capacity tracking
- Degradation monitoring
- Cycle counting

### 3. **Thermal Management**
- Temperature monitoring (multiple cells)
- Cooling/heating control
- Thermal runaway prevention

### 4. **Cell Balancing**
- Active cell balancing
- Passive balancing
- Voltage equalization

### 5. **Safety Protection**
- Over-voltage protection (OVP)
- Under-voltage protection (UVP)
- Over-current protection (OCP)
- Over-temperature protection (OTP)
- Thermal runaway detection

### 6. **Simulink Models**
- Multi-cell battery pack model
- Equivalent circuit model (ECM)
- Thermal dynamics model
- Safety controller logic

## 📁 Project Structure

```
EV-BMS-MATLAB/
├── README.md                          # Project overview
├── .gitignore                         # Git ignore file
│
├── 📂 Documentation/
│   ├── BMS_Architecture.md            # System architecture
│   ├── Physics_and_Math.md            # Physics background
│   ├── Quick_Start.md                 # Quick start guide
│   └── Testing_Guide.md               # Testing procedures
│
├── 📂 MATLAB_Scripts/
│   ├── BMS_Parameters.m               # System parameters
│   ├── Battery_Model.m                # Battery model
│   ├── SOC_Estimator.m                # SOC estimation
│   ├── SOH_Monitor.m                  # Health monitoring
│   ├── Thermal_Model.m                # Thermal dynamics
│   ├── Safety_Controller.m            # Safety controls
│   ├── Cell_Balancer.m                # Cell balancing
│   └── Utilities.m                    # Helper functions
│
├── 📂 Simulink_Models/
│   ├── BMS_Main_Model.slx             # Main BMS system
│   ├── Battery_Cell_Model.slx         # Cell model
│   ├── Battery_Pack_Model.slx         # Pack model
│   ├── Thermal_Management.slx         # Thermal system
│   └── Safety_System.slx              # Safety controls
│
├── 📂 Test_Cases/
│   ├── test_SOC_estimation.m          # SOC tests
│   ├── test_thermal_management.m      # Thermal tests
│   ├── test_safety_limits.m           # Safety tests
│   └── test_BMS_integration.m         # Integration tests
│
└── 📂 Data/
    ├── Battery_Specifications.m       # Battery params
    └── Simulation_Results/            # Output data
```

## 🚀 Quick Start (5 Minutes)

### Prerequisites
- ✅ MATLAB R2019b or later
- ✅ Simulink
- ✅ Control System Toolbox

### Step 1: Clone Repository
```bash
git clone https://github.com/Aashrith-12/EV-BMS-MATLAB.git
cd EV-BMS-MATLAB
```

### Step 2: Setup Path
```matlab
addpath(genpath(pwd))
```

### Step 3: Run Parameters
```matlab
BMS_Parameters
```

### Step 4: Run Simulations
```matlab
Battery_Model      % Battery electrical model
SOC_Estimator      % State of charge estimation
Safety_Controller  % Safety protection tests
```

### Step 5: View Results
- Plots will display automatically
- Data saved to `.mat` files
- Read `Documentation/Quick_Start.md` for details

## 📊 System Architecture

```
Sensors (V, I, T)
      ↓
State Estimators (SOC, SOH, Temp)
      ↓
Safety & Control (OVP, UVP, OCP, OTP)
      ↓
Cell Balancing & Thermal Management
      ↓
Actuators (Contactors, Fans, Balancing)
      ↓
CAN Communication (to Vehicle Controller)
```

## 📈 Key Capabilities

| Feature | Capability | Status |
|---------|-----------|--------|
| SOC Estimation | ±2% accuracy | ✅ Implemented |
| Thermal Modeling | Real-time prediction | ✅ Implemented |
| Safety Protection | <100ms response | ✅ Implemented |
| Cell Balancing | Active & Passive | 🔄 In Progress |
| CAN Communication | SAE J1939 | 📋 Planned |
| Hardware Integration | Microcontroller | 📋 Planned |

## 🧮 Core Equations

### State of Charge (Coulomb Counting)
```
SOC(t) = SOC(0) - ∫[I(τ)/Q_nom]dτ
```

### Terminal Voltage (ECM)
```
V_terminal = V_oc(SOC) - I·R_internal - V_rc
```

### Thermal Model
```
dT/dt = (P_loss - P_cooling) / (m·cp)
```

## 📖 Documentation

- **Getting Started**: Read `Documentation/Quick_Start.md`
- **Architecture**: Read `Documentation/BMS_Architecture.md`
- **Physics & Math**: Read `Documentation/Physics_and_Math.md`
- **Testing**: Read `Documentation/Testing_Guide.md`

## 🧪 Testing

Run comprehensive tests:
```matlab
run('Test_Cases/test_BMS_integration.m')
```

Expected results:
- SOC Estimation Error: < 2%
- Temperature Prediction: ± 2°C
- Safety Response: < 100ms
- Balancing Efficiency: > 95%

## 🔄 Workflow

```
1. Load Parameters (BMS_Parameters.m)
   ↓
2. Define Driving Cycle/Load Profile
   ↓
3. Run Battery Model (Battery_Model.m)
   ↓
4. Estimate States (SOC_Estimator.m)
   ↓
5. Test Safety (Safety_Controller.m)
   ↓
6. Analyze Results & Generate Plots
```

## 🎯 Next Steps (Roadmap)

### Phase 1: Core Development ✅
- [x] Battery modeling
- [x] SOC estimation
- [x] Safety controls
- [x] Documentation

### Phase 2: Advanced Features 🔄
- [ ] Machine learning SOC predictor
- [ ] Fault diagnostics
- [ ] CAN communication
- [ ] Real-time optimization

### Phase 3: Hardware Integration 📋
- [ ] Microcontroller implementation
- [ ] Real vehicle testing
- [ ] Production readiness

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make changes and test
4. Submit a pull request

## 📄 License

This project is open source for educational purposes.

## 📞 Support

For questions or issues:
1. Check `Documentation/Quick_Start.md`
2. Review `Documentation/Physics_and_Math.md`
3. Open a GitHub issue with details

## 📚 References

- IEEE Standards for EV Battery Management
- SAE J1939 CAN Protocol
- Lithium-ion Battery Electrochemistry
- Kalman Filter State Estimation
- Control Systems Theory

## 🎓 Learning Outcomes

After completing this project, you'll understand:
- ✅ Battery electrochemistry & modeling
- ✅ State estimation techniques
- ✅ Safety critical systems
- ✅ Thermal management
- ✅ MATLAB/Simulink simulation
- ✅ Real-time control systems

## 📊 Example Results

### SOC Estimation Accuracy
```
Method              Error (1 hour)
Coulomb Counting    1-3%
Kalman Filter       0.1-0.5%
OCV-based          0.5-2%
```

### Thermal Response
```
At 50A discharge:
- Temperature rise: ~0.5°C/minute
- Peak temp: ~35-40°C (after 1 hour)
- Cooling effectiveness: >85%
```

### Safety System
```
Protection          Response Time
OVP (>4.3V)        Immediate
UVP (<2.4V)        Immediate
OCP (>160A)        Immediate
OTP (>60°C)        Immediate
```

---

**Version**: 1.0.0  
**Last Updated**: July 2024  
**Status**: Active Development 🚀

For detailed usage, see **Documentation/** folder.
