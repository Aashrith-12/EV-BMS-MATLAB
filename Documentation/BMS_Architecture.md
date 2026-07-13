# BMS Architecture and Design

## 🏗️ System Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│         Intelligent Battery Management System (BMS)    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────┐      ┌──────────────────┐        │
│  │  SENSORS LAYER   │      │  BATTERY PACK    │        │
│  ├──────────────────┤      ├──────────────────┤        │
│  │ • Voltage (96×)  │◄────►│ 96 Cells Series  │        │
│  │ • Current (1×)   │      │ 75 Ah Capacity   │        │
│  │ • Temp (8×)      │      │ 384 V Pack       │        │
│  └──────────────────┘      └──────────────────┘        │
│           │                                             │
│           ▼                                             │
│  ┌─────────────────────────────────────────┐           │
│  │    STATE ESTIMATION LAYER               │           │
│  ├─────────────────────────────────────────┤           │
│  │ • SOC Estimation (Coulomb + Kalman)     │           │
│  │ • SOH Monitoring                        │           │
│  │ • Thermal Estimation                    │           │
│  │ • Fault Detection                       │           │
│  └─────────────────────────────────────────┘           │
│           │                                             │
│           ▼                                             │
│  ┌─────────────────────────────────────────┐           │
│  │    CONTROL & PROTECTION LAYER           │           │
│  ├─────────────────────────────────────────┤           │
│  │ • Safety Checks (OVP, UVP, OCP, OTP)    │           │
│  │ • Cell Balancing Control                │           │
│  │ • Thermal Management                    │           │
│  │ • Load Management                       │           │
│  └─────────────────────────────────────────┘           │
│           │                                             │
│           ▼                                             │
│  ┌─────────────────────────────────────────┐           │
│  │    ACTUATOR LAYER                       │           │
│  ├─────────────────────────────────────────┤           │
│  │ • Main Contactor (Connect/Disconnect)   │           │
│  │ • Precharge Circuit                     │           │
│  │ • Balancing Resistors/Switches          │           │
│  │ • Cooling/Heating System                │           │
│  │ • Fan Control                           │           │
│  └─────────────────────────────────────────┘           │
│           │                                             │
│           ▼                                             │
│  ┌─────────────────────────────────────────┐           │
│  │    COMMUNICATION LAYER (CAN Bus)        │           │
│  ├─────────────────────────────────────────┤           │
│  │ • Vehicle Control Unit (VCU)            │           │
│  │ • Motor Controller                      │           │
│  │ • Charger                               │           │
│  │ • Diagnostics                           │           │
│  └─────────────────────────────────────────┘           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 📊 Component Specifications

### Battery Pack Configuration

| Parameter | Value | Unit |
|-----------|-------|------|
| Battery Type | Lithium-ion | - |
| Chemistry | LiPo | - |
| Total Cells | 96 | Series |
| Cell Voltage | 3.7 | V (nominal) |
| Pack Voltage | 355.2 → 403.2 | V (min → max) |
| Capacity | 75 | Ah |
| Energy | 27 | kWh |
| Max Discharge | 150 | A |
| Max Charge | 100 | A |
| Operating Temp | -20 to +55 | °C |

### Sensor Configuration

| Sensor | Quantity | Range | Accuracy |
|--------|----------|-------|----------|
| Voltage Sensors | 96 | 0-4.5V | ±10mV |
| Current Sensor | 1 | ±200A | ±1A |
| Temperature Sensors | 8 | -40 to +80°C | ±2°C |
| Pressure Sensors | 2 | 0-500kPa | ±5kPa |

### Protection Thresholds

| Protection | Threshold | Action | Recovery |
|-----------|-----------|--------|----------|
| OVP (Over-Voltage) | 4.3V/cell | Stop Charge | 4.2V/cell |
| UVP (Under-Voltage) | 2.4V/cell | Stop Discharge | 2.5V/cell |
| OCP (Over-Current) | >160A | Limit Current | <150A |
| OTP High | >60°C (discharge) | Reduce Load | <55°C |
| OTP High | >50°C (charge) | Stop Charge | <45°C |
| Thermal Runaway | >80°C | EMERGENCY | N/A |

---

## 🔄 Operating Modes

### 1. Idle Mode
- **Conditions**: No charging/discharging
- **Actions**: 
  - Periodic monitoring
  - Balancing enabled
  - Minimal power consumption
  - Data logging

### 2. Discharge Mode (Vehicle Driving)
- **Conditions**: Current > 0A (vehicle drawing power)
- **Actions**:
  - Real-time SOC tracking
  - Thermal management
  - Load limiting if necessary
  - Safety monitoring

### 3. Charge Mode (Vehicle Charging)
- **Conditions**: Current < 0A (charger supplying power)
- **Actions**:
  - Charge current limiting
  - Cell balancing
  - Thermal control
  - Pre-charge sequence

### 4. Fault Mode
- **Conditions**: Any safety threshold exceeded
- **Actions**:
  - Immediate contactor open
  - Fault logging
  - Alert to VCU
  - Diagnostic mode

---

## 🔌 Simulink Model Structure

### Main BMS Model (BMS_Main_Model.slx)

```
Input Signals:
├── Voltage (96 channels)
├── Current (1 channel)
├── Temperature (8 channels)
└── Control Signals

Processing:
├── State Estimator Subsystem
│   ├── SOC Calculator
│   ├── SOH Monitor
│   └── Thermal Model
├── Safety Controller Subsystem
│   ├── OVP Checker
│   ├── UVP Checker
│   ├── OCP Checker
│   └── OTP Checker
├── Cell Balancing Subsystem
│   ├── Voltage Analyzer
│   ├── Balancing Logic
│   └── Control Signals
└── Thermal Management Subsystem
    ├── Heat Calculation
    ├── Cooling Control
    └── Heating Control

Output Signals:
├── Safe Flag (1 bit)
├── Fault Code (8 bits)
├── Control Actions
├── SOC, SOH, Temperature
└── Diagnostic Data
```

---

## 🧮 Key Algorithms

### SOC Estimation Algorithm

```
Algorithm: Hybrid Coulomb Counting + Kalman Filter

Input: Current I(k), Voltage V(k), Temperature T(k)
Output: SOC_estimate(k)

Step 1: Coulomb Counting
    ΔQ = I(k) × Δt
    SOC_cc = SOC_prev - ΔQ/Q_nom

Step 2: Kalman Filter Prediction
    x_pred = x_prev + u_cc
    P_pred = P_prev + Q

Step 3: Measurement Update
    z_meas = V_oc(V_meas) - V_oc_expected
    K = P_pred / (P_pred + R)
    x_final = x_pred + K × (z_meas / sensitivity)

Step 4: Clamp to Valid Range
    SOC = max(0, min(100, x_final))
```

### Cell Balancing Algorithm

```
Algorithm: Adaptive Voltage Balancing

Input: Voltage of all 96 cells
Output: Balancing control signals for each cell

Step 1: Calculate Statistics
    V_avg = mean(V_cells)
    V_max = max(V_cells)
    V_min = min(V_cells)
    V_imbalance = V_max - V_min

Step 2: Threshold Check
    if V_imbalance > Threshold
        Enable balancing
    else
        Disable balancing

Step 3: Select Cells to Balance
    For each cell:
        if V_cell > V_avg + margin
            Enable balancing resistor
        end
    end

Step 4: Monitor Progress
    if V_imbalance < target
        Stop balancing
    end
```

### Thermal Management Algorithm

```
Algorithm: PID-based Temperature Control

Input: Current T_measured, Target T_setpoint
Output: Cooling/Heating power command

Step 1: Calculate Heat Generation
    P_loss = I² × R_internal + Polarization losses

Step 2: Thermal Model
    dT/dt = (P_loss - P_cooling) / (m × cp)

Step 3: PID Controller
    error = T_setpoint - T_measured
    P_cooling = Kp × error + Ki × ∫error + Kd × derror/dt

Step 4: Saturation & Limits
    P_cooling = max(0, min(P_max, P_cooling))
    Fan_speed = P_cooling / P_nominal
```

---

## 📈 Data Logging

### Logged Parameters

| Parameter | Sample Rate | Storage |
|-----------|-------------|---------|
| Voltage (all 96 cells) | 10 Hz | 1 hour = 360 kB |
| Current | 100 Hz | 1 hour = 360 kB |
| Temperature (8 sensors) | 10 Hz | 1 hour = 360 kB |
| SOC | 1 Hz | 1 hour = 3.6 kB |
| SOH | 0.01 Hz | 1 hour = 36 bytes |
| Faults | Event-based | 1 hour = 1 kB |

### Total Storage
- **1 hour**: ~1 MB
- **1 day**: ~24 MB
- **1 year**: ~8.7 GB

---

## 🎯 Performance Targets

| Metric | Target | Current |
|--------|--------|---------|
| SOC Accuracy | ±2% | To be verified |
| Thermal Response Time | <5 seconds | To be tested |
| Fault Detection Time | <100 ms | To be tested |
| Balancing Imbalance | <50 mV | To be tested |
| System Uptime | >99.9% | In development |

