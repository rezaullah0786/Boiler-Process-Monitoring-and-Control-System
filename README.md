# Boiler Process Monitoring and Control System Using Siemens TIA Portal V17 and Ladder Logic

> **Engineering Status:** Educational Simulation & Technical Reference Specification  
> **Target Controller:** Siemens SIMATIC S7-1200 (CPU 1214C DC/DC/DC, FW V4.5)  
> **Engineering Environment:** Siemens TIA Portal V17 & S7-PLCSIM V17  
> **Programming Language:** Ladder Diagram (LAD / KOP) — IEC 61131-3 Standard  

---

## 1. Project Overview

This project provides a comprehensive, deterministic industrial automation reference model designed for an educational steam boiler drum water-level monitoring system. 

Maintaining adequate water level inside an industrial boiler drum is of paramount safety importance: an undetected low-water condition exposes water-wall boiling tubes to furnace temperatures exceeding $1000^\circ\text{C}$ without internal cooling, leading to catastrophic tube rupture, metallurgical failure, and potential boiler explosion.

This project implements the complete PLC logic required to process a simulated drum water level variable (`Water_Level`, `REAL`, $0.0\% - 100.0\%$), compare it cyclically against an operator-adjustable low-level safety setpoint (`Low_Level_Threshold`, `REAL`, default $30.0\%$), and drive a non-latching Boolean alarm output (`Low_Level_Alarm`, `BOOL`). An extended diagnostic tier monitors signal boundaries to detect out-of-range sensor and configuration anomalies.

> [!NOTE]
> **Simulation & Scope Boundary Statement:**  
> This project is an educational software simulation and design specification developed for testing within Siemens S7-PLCSIM V17 and TIA Portal V17. It does **not** connect to physical sensors, a real boiler, physical actuators, or a live SCADA runtime. In an actual industrial plant, boiler safety shutdown functions require a validated, fail-safe Safety-Instrumented System (SIS) certified under IEC 61508 / IEC 61511.

---

## 2. Problem Statement

In industrial water-tube steam boilers:
1. **Low Water Level:** Causes dry-out of boiling tubes, loss of natural circulation, rapid metal creep, and severe rupture.
2. **High Water Level:** Leads to moisture carryover into steam headers, superheaters, and steam turbines, eroding turbine blades and inducing thermal shock.
3. **Control Challenges:** Due to high evaporation rates relative to drum volume (often 30–60 seconds of liquid storage), controllers must execute deterministic, sub-second monitoring.
4. **Engineering Knowledge Gap:** Beginners in industrial automation frequently struggle with floating-point memory alignment, distinction between non-latching alarms and latched emergency trips, and testing methodologies without physical I/O hardware.

---

## 3. Key Features

- **Standardized Floating-Point (REAL) Processing:** Uses IEEE 754 32-bit single-precision floating-point numbers ($0.0\% - 100.0\%$) to maintain fractional accuracy without integer quantization distortion.
- **Strict Inequality Determinism:** Implements Siemens `CMP <` (Real) comparison instruction to evaluate $IN1 < IN2$.
- **Non-Latching Automatic Clearing:** Employs an assignment coil `-( )` so that the alarm activates when the condition is true and immediately deactivates when water level recovers to or above the threshold.
- **Configurable Trip Point:** Allows operators or testing engineers to dynamically adjust the low-water trip threshold via Watch Tables.
- **Extended Supervisory Diagnostics:** Includes dedicated range validation rungs to flag values $< 0.0\%$ or $> 100.0\%$ (`Water_Level_Input_Invalid`, `Threshold_Configuration_Invalid`) without silently clamping raw data.
- **Comprehensive 10-Point Test Matrix:** Rigorously validates nominal, sub-threshold, recovery, and equal-to-threshold edge cases.

---

## 4. Software & Platform Requirements

| Component | Specification |
| :--- | :--- |
| **Engineering Suite** | Siemens TIA Portal V17 (Totally Integrated Automation) |
| **PLC Programming Package** | SIMATIC STEP 7 Professional V17 |
| **Simulation Runtime** | Siemens S7-PLCSIM V17 |
| **Target Controller** | SIMATIC S7-1200 CPU 1214C DC/DC/DC (Order No: `6ES7 214-1AG40-0XB0`, Firmware V4.5) |
| **Host Operating System** | Microsoft Windows 10 / 11 (64-bit) Professional or Enterprise |
| **Python Environment (Optional)** | Python 3.10+ (for rendering supporting diagrams and generating reports) |

---

## 5. System Architecture

```text
 ┌────────────────────────────────────────────────────────┐
 │ 1. SIMULATION STIMULUS (Operator / Watch Table)        │
 │    - Water_Level Modify Value: 0.0% to 100.0%          │
 │    - Low_Level_Threshold Modify Value: Default 30.0%   │
 └───────────────────────────┬────────────────────────────┘
                             │
                             ▼
 ┌────────────────────────────────────────────────────────┐
 │ 2. SIMATIC S7-1200 CPU [Main OB1]                      │
 │    - Tag: "Water_Level"          (%MD10, REAL)         │
 │    - Tag: "Low_Level_Threshold"  (%MD14, REAL)         │
 │    - Instruction: CMP < (Real)                         │
 │      Evaluates condition: Water_Level < Threshold      │
 └───────────────────────────┬────────────────────────────┘
                             │
                             ▼
 ┌────────────────────────────────────────────────────────┐
 │ 3. PROCESS ALARM OUTPUT                                │
 │    - Ladder Assignment Coil: -(  )-                    │
 │    - Tag: "Low_Level_Alarm" (%M0.0, BOOL)              │
 │    - Behavior: TRUE = Active | FALSE = Clear           │
 └───────────────────────────┬────────────────────────────┘
                             │
                             ▼ (Future Interface)
 ┌────────────────────────────────────────────────────────┐
 │ 4. OPTIONAL FUTURE EXTENSIONS                          │
 │    - HMI / SCADA Dashboard (WinCC Unified / Ignition)  │
 │    - Closed-Loop Feedwater Pump Control Interlocks     │
 └────────────────────────────────────────────────────────┘
```

A visual architecture diagram is provided in [`diagrams/System_Architecture.png`](diagrams/System_Architecture.png) and vector format [`diagrams/System_Architecture.svg`](diagrams/System_Architecture.svg).

---

## 6. PLC Tag Summary

| Tag Name | Suggested Address | Data Type | Initial Value | Purpose | Expected Behavior |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Water_Level` | `%MD10` | `Real` | `60.0` | Simulated drum level (%) | Process variable modified in Watch Table ($0.0 - 100.0\%$). |
| `Low_Level_Threshold` | `%MD14` | `Real` | `30.0` | Low-level alarm setpoint | Configurable trip point. Triggers alarm if level drops below this value. |
| `Low_Level_Alarm` | `%M0.0` | `Bool` | `FALSE` | Low water level alarm | Evaluates to `TRUE` when level is below threshold; auto-resets to `FALSE`. |
| `Water_Level_Input_Invalid` | `%M0.1` | `Bool` | `FALSE` | [Extended] Level diagnostic | Evaluates to `TRUE` if `Water_Level` $< 0.0$ or $> 100.0$. |
| `Threshold_Configuration_Invalid` | `%M0.2` | `Bool` | `FALSE` | [Extended] Setpoint diagnostic | Evaluates to `TRUE` if threshold $< 0.0$ or $> 100.0$. |

> [!IMPORTANT]
> **Memory Alignment Notice:** A `REAL` value requires 4 consecutive bytes. Notice that `%MD10` uses bytes 10–13, and `%MD14` uses bytes 14–17. Never allocate consecutive word increments like `%MD10` and `%MD12`, as this causes severe memory overlap and data corruption.

---

## 7. Ladder Logic Implementation

The core logic resides in `Main [OB1]`, Network 1:

```text
  ---|-------------------------[ CMP < ]--------------------------( )-------------|---
     |                         |  Real  |                   "Low_Level_Alarm"     |
     |                         |        |                         %M0.0           |
     |  "Water_Level" -------->| IN1    |                                         |
     |      %MD10              |        |                                         |
     |                         |        |                                         |
     |  "Low_Level_Threshold"->| IN2    |                                         |
     |      %MD14              +--------+                                         |
```

### Key Logic Characteristics:
- **Comparison:** Evaluates $\text{Water\_Level} < \text{Low\_Level\_Threshold}$.
- **Strict Inequality ($<$):** If $\text{Water\_Level} = 30.0$ and $\text{Threshold} = 30.0$, the condition $30.0 < 30.0$ is **FALSE**, so the alarm remains clear.
- **Non-Latching Coil:** When power flow is false, the coil `-( )` actively writes `0` (`FALSE`) to `%M0.0`.

---

## 8. Step-by-Step Setup & Implementation Instructions

For the complete 20-step walkthrough with screenshots and common mistakes, consult [`docs/TIA_Portal_V17_Guide.md`](docs/TIA_Portal_V17_Guide.md).

### Quick Setup Summary:
1. Open **Siemens TIA Portal V17** $\rightarrow$ Create project `Boiler_Process_Monitoring`.
2. Add device: **SIMATIC S7-1200 CPU 1214C DC/DC/DC** (6ES7 214-1AG40-0XB0, FW V4.5).
3. Open **PLC tags** $\rightarrow$ `Default tag table` and enter `Water_Level` (%MD10, Real), `Low_Level_Threshold` (%MD14, Real), and `Low_Level_Alarm` (%M0.0, Bool).
4. Open **Program blocks** $\rightarrow$ `Main [OB1]`.
5. Insert instruction `CMP <` (Comparator) into Network 1. Set data type to **Real**.
6. Wire `IN1` = `"Water_Level"`, `IN2` = `"Low_Level_Threshold"`.
7. Insert standard assignment coil `-( )` and assign to `"Low_Level_Alarm"`.
8. Compile program (`Ctrl + B`) and verify `0 Errors, 0 Warnings`.

---

## 9. Simulation Instructions (S7-PLCSIM)

1. Select `PLC_1` in the Project tree and click **Start simulation** (`Ctrl + Shift + X`).
2. S7-PLCSIM V17 launches. In the download dialog, select `PN/IE` and click **Load**.
3. Set CPU mode to **RUN** (virtual LED turns solid green).
4. In TIA Portal, create a Watch Table: `Watch_Table_Boiler_Level`.
5. Add `"Water_Level"`, `"Low_Level_Threshold"`, and `"Low_Level_Alarm"`.
6. Click **Monitor all** (`👓▶`).
7. Enter values into **Modify value** column and click **Modify now** (`⚡`) to execute test cases.

---

## 10. Test Matrix & Verification

| Test ID | Water_Level (%) | Threshold (%) | Logic Expression | Expected Alarm | Test Purpose |
| :---: | :---: | :---: | :---: | :---: | :--- |
| **TC-01** | `80.0` | `30.0` | $80.0 < 30.0 \rightarrow \text{FALSE}$ | `FALSE` | Normal safe operating level |
| **TC-02** | `60.0` | `30.0` | $60.0 < 30.0 \rightarrow \text{FALSE}$ | `FALSE` | Normal mid-range level |
| **TC-03** | `30.0` | `30.0` | $30.0 < 30.0 \rightarrow \text{FALSE}$ | `FALSE` | **Boundary test:** Level equal to threshold |
| **TC-04** | `29.9` | `30.0` | $29.9 < 30.0 \rightarrow \text{TRUE}$ | `TRUE` | **Trip test:** 0.1% sub-threshold condition |
| **TC-05** | `20.0` | `30.0` | $20.0 < 30.0 \rightarrow \text{TRUE}$ | `TRUE` | Standard low level trip |
| **TC-06** | `0.0` | `30.0` | $0.0 < 30.0 \rightarrow \text{TRUE}$ | `TRUE` | Extreme low level (dry drum simulation) |
| **TC-07** | `45.0` | `30.0` | $45.0 < 30.0 \rightarrow \text{FALSE}$ | `FALSE` | **Recovery test:** Verifies auto-clearing |
| **TC-08** | `25.0` | `40.0` | $25.0 < 40.0 \rightarrow \text{TRUE}$ | `TRUE` | Dynamic setpoint: Setpoint raised to 40% |
| **TC-09** | `50.0` | `40.0` | $50.0 < 40.0 \rightarrow \text{FALSE}$ | `FALSE` | Dynamic setpoint: Normal level at 40% SP |
| **TC-10** | `20.0` | `20.0` | $20.0 < 20.0 \rightarrow \text{FALSE}$ | `FALSE` | **Boundary test:** Setpoint lowered to 20% |

The tracking template for recording live testing results is available in [`reports/Test_Execution_Checklist.md`](reports/Test_Execution_Checklist.md).

---

## 11. Known Limitations & Scope Distinctions

1. **No Physical Sensors:** Values are entered via RAM Watch Tables; physical 4–20 mA transmitters with analog noise and drift are not present.
2. **No Thermodynamic Physics:** Water evaporation, boiling dynamics, steam pressure shifts, and shrink/swell phenomena are not calculated.
3. **Non-Safety Certification:** This project is not a certified Safety-Instrumented System (SIS / SIL). It must not be deployed to control live boiler equipment.

---

## 12. Future Roadmap

1. **Analog Scaling:** Implement `NORM_X` and `SCALE_X` to simulate 4–20 mA analog input acquisition from `%IW64`.
2. **Alarm Deadband & Debounce:** Implement a 2.0% hysteresis deadband and an on-delay timer (`TON`) to eliminate alarm chatter near the setpoint.
3. **WinCC Unified HMI:** Build an animated drum level gauge, alarm banner, and setpoint input dashboard.
4. **Closed-Loop Feedwater Control:** Simulate three-element boiler control with modulating valve and pump interlocks.

---

## 13. Project Folder Structure

```text
Boiler_Process_Monitoring/
│
├── README.md                               <-- Primary project dossier and reference
│
├── docs/
│   ├── Project_Report.md                   <-- Full 23-section formal engineering report
│   ├── Project_Report.pdf                  <-- Formatted PDF engineering report
│   ├── generate_pdf_report.py              <-- Pure Python script to regenerate PDF
│   ├── TIA_Portal_V17_Guide.md             <-- 20-step beginner implementation guide
│   ├── Ladder_Logic_Explanation.md         <-- In-depth LAD instruction & execution mechanics
│   ├── PLC_Tag_Table.csv                   <-- Tag dictionary with addresses and data types
│   ├── Test_Plan.csv                       <-- 10-point test matrix in CSV format
│   ├── Interview_Preparation.md            <-- Comprehensive interview Q&A and defense guide
│   └── Troubleshooting.md                  <-- Diagnostic matrix for compilation & PLCSIM
│
├── diagrams/
│   ├── System_Architecture.png             <-- High-resolution architecture diagram (1100x850)
│   ├── System_Architecture.svg             <-- Scalable vector architecture diagram
│   └── generate_diagram.ps1                <-- PowerShell script to regenerate PNG diagram
│
├── plc_reference/
│   ├── OB1_Network_Design.md               <-- Network by network ladder design & FB specs
│   ├── PLC_Logic_Pseudocode.txt            <-- Pseudocode, Structured Text (SCL), & Netlist
│   └── Implementation_Notes.md             <-- S7-1200 memory mapping & IEEE 754 notes
│
└── reports/
    └── Test_Execution_Checklist.md         <-- Printable operator verification checklist
```

---

## 14. Verification & Validation Summary

All files in this repository have been cross-checked for absolute consistency:
- Tag names (`Water_Level`, `Low_Level_Threshold`, `Low_Level_Alarm`) are identical across all markdown, CSV, pseudocode, and diagram files.
- Addresses (`%MD10`, `%MD14`, `%M0.0`) maintain 4-byte boundaries without overlap.
- Test case predictions strictly follow $IN1 < IN2$.
- PDF and PNG assets were generated cleanly with native scripts.
