# Comprehensive Engineering Project Report
# Boiler Process Monitoring and Control System Using Siemens TIA Portal V17 and Ladder Logic

---

## 1. Title Page

- **Project Title:** Boiler Process Monitoring and Control System Using Siemens TIA Portal V17 and Ladder Logic
- **Document Type:** Technical Project Report & Engineering Design Dossier
- **Author:** Industrial Automation Engineering Candidate
- **Target Platform:** Siemens SIMATIC S7-1200 (CPU 1214C DC/DC/DC)
- **Engineering Suite:** Siemens TIA Portal V17 (Totally Integrated Automation)
- **Simulation Environment:** Siemens S7-PLCSIM V17
- **Document Version:** 1.0.0
- **Status:** Complete Engineering Specification & Simulation Model

---

## 2. Abstract

Steam boiler drum water-level maintenance represents one of the most critical safety and operational functions in industrial thermal and power generation plants. Insufficient water levels subject boiler water-wall tubes to extreme thermal stress, metallurgy creep, and catastrophic tube rupture, while excessive levels cause moisture carryover into steam headers, superheaters, and turbine blades. 

This educational engineering project designs, documents, and simulates a deterministic, PLC-based boiler drum water-level monitoring and alarm system in Siemens TIA Portal V17 using Ladder Diagram (LAD) for a SIMATIC S7-1200 controller. The system processes normalized water level measurements represented as IEEE 754 32-bit floating-point (`REAL`) values ($0.0\% - 100.0\%$) and evaluates them cyclically against an operator-configurable low-level threshold (initial setpoint: $30.0\%$). Using a Siemens `CMP <` comparator, the system activates a non-latching Boolean alarm (`Low_Level_Alarm`) whenever water level drops strictly below the threshold and automatically resets the alarm upon level recovery. 

An extended diagnostic tier validates signal boundaries ($0.0\% \le PV \le 100.0\%$) without clamping raw inputs. The complete logic was verified against a 10-point test matrix in Siemens S7-PLCSIM with Watch Tables. This report documents the theoretical thermodynamics, controller architecture, ladder network designs, execution determinism, interview defenses, and structured roadmaps toward closed-loop pump control and SCADA visualization.

---

## 3. Introduction

Industrial automation relies heavily on Programmable Logic Controllers (PLCs) to ensure process integrity, personnel safety, and operational efficiency across manufacturing, chemical, oil and gas, and thermal utility sectors. Among industrial utility assets, steam boilers are subject to strict regulatory codes (such as ASME Boiler and Pressure Vessel Code Section I and NFPA 85) due to the immense potential energy stored under pressure.

For engineers entering the industrial automation field, developing a clear, technically sound understanding of PLC architecture, cyclic program scanning, floating-point math comparisons, and alarm annunciation is fundamental. This project serves as an educational benchmark model demonstrating how process requirements translate into robust, deterministic Ladder Diagram networks in Siemens TIA Portal V17.

---

## 4. Problem Statement

In industrial steam boilers, the liquid volume contained within the boiler drum is surprisingly small compared to the rapid rate of steam evaporation. At full load, an industrial boiler drum may contain only a 30 to 60-second reserve of water. A sudden failure of feedwater supply or an undetected level drop can expose the boiling tubes to furnace temperatures exceeding $1000^\circ\text{C}$ without internal water cooling, causing immediate metallurgical failure and structural explosion.

To prevent such events, automated monitoring systems must continuously evaluate the drum water level with sub-second determinism. However, beginners often face significant hurdles when implementing industrial monitoring logic:
1. Understanding the difference between integer and floating-point representations of physical signals.
2. Managing memory mapping in Siemens controllers without overlapping byte addresses.
3. Distinguishing between combinational non-latching alarms and latched emergency shutdown trips.
4. Structuring PLC tags and Ladder rungs to comply with industrial conventions while maintaining testability in simulated environments.

---

## 5. Project Objectives

The primary objectives of this project are:
1. **Develop a Deterministic Monitoring Routine:** Create a simulated boiler drum water-level monitoring routine in Siemens TIA Portal V17 using Ladder Diagram (LAD).
2. **Utilize Standardized Floating-Point Variables:** Represent the simulated water level (`Water_Level`) and configurable alarm setpoint (`Low_Level_Threshold`) as 32-bit `REAL` data types normalized from $0.0\%$ to $100.0\%$.
3. **Implement Non-Latching Alarm Logic:** Execute a strict less-than comparison ($IN1 < IN2$) that drives a Boolean alarm (`Low_Level_Alarm`) that automatically clears when water level recovers.
4. **Design Supervisory Diagnostics:** Provide an extended supervisory tier (`Water_Level_Input_Invalid`, `Threshold_Configuration_Invalid`) to flag out-of-range signal anomalies.
5. **Establish Structured Verification:** Formulate a comprehensive 10-point test matrix covering nominal, sub-threshold, boundary, and recovery conditions.
6. **Provide Interview Defense Documentation:** Deliver clear, honest technical documentation distinguishing simulated prototype elements from physical industrial safety installations.

---

## 6. Scope and Limitations

### In-Scope Items
- Siemens TIA Portal V17 project architecture and tag definitions.
- SIMATIC S7-1200 CPU 1214C DC/DC/DC target configuration.
- Main Organization Block [OB1] Ladder Diagram programming.
- Floating-point comparator instruction (`CMP <`, Real) design.
- Non-latching discrete alarm output mapping.
- Extended diagnostic range validation networks.
- Verification methodology using S7-PLCSIM V17 and Watch Tables.
- Comprehensive technical documentation, SVG/PNG architecture diagrams, and interview preparation guides.

### Explicit Limitations & Out-of-Scope Items
- **No Physical Hardware:** No physical S7-1200 PLC, boiler drum, piping, or level transmitters were wired.
- **Simulation Only:** All process values are injected via Watch Tables in RAM; process thermodynamic dynamics (e.g., shrink and swell, heat transfer, boiling) are not simulated by the PLC.
- **No SCADA/HMI Runtime:** No live WinCC Unified or Ignition SCADA server was deployed.
- **No Closed-Loop Pump Control:** No physical or simulated variable-frequency drive (VFD) or feedwater control valve is manipulated.
- **Not a Safety-Instrumented System (SIS):** This educational logic must never be deployed on a live boiler without certified fail-safe hardware (S7-F series), redundant transmitters, and SIL 2/3 validation.

---

## 7. Boiler Drum Water-Level Monitoring Fundamentals

### The Thermodynamic Role of the Boiler Drum
In a water-tube boiler, the boiler drum serves as the phase separation reservoir positioned at the highest elevation of the boiler loop. Feedwater enters the drum below the water line. Water circulates downward through unheated downcomer pipes to the lower mud drum or lower headers, then rises through heat-absorbing water-wall tubes where combustion gases heat the water into a two-phase steam-water mixture.

This two-phase mixture re-enters the boiler drum through riser pipes. Inside the drum, internal mechanical devices (cyclone separators, scrubbers, and chevron mist eliminators) separate dry saturated steam from liquid droplets. The dry steam exits through the top nozzle to the superheater, while the separated liquid mixes with incoming feedwater and recirculates.

```text
                 +-----------------------------------+
                 |           STEAM SPACE             | ===> Dry Steam to Superheater
                 |  (Cyclone Separators & Scrubbers) |
  Water Line ===>|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|<=== High/Low Trip Limits
                 |           LIQUID WATER            |
  Feedwater In =>|  (Submerged Feedwater Sparger)    | ===> Downcomers to Mud Drum
                 +-----------------------------------+
```

### Safety Risks of Low Water Level
If the water level in the drum drops below the minimum safe continuous water level:
1. **Tube Starvation:** Water circulation through the downcomers diminishes or collapses.
2. **Overheating & Creep:** Furnace combustion temperatures exceed $1000^\circ\text{C}$ to $1400^\circ\text{C}$. Without liquid water absorbing heat through phase change, tube metal temperatures rapidly exceed metallurgical design limits ($450^\circ\text{C} - 550^\circ\text{C}$).
3. **Rupture:** Internal steam pressure causes the weakened steel tubes to blow outward (rupture), releasing immense thermal energy, destroying the boiler furnace, and creating catastrophic hazard for personnel.

---

## 8. PLC Architecture

A Programmable Logic Controller (PLC) is an industrial microprocessor-based device designed for deterministic, real-time control.

```text
 ┌────────────────────────────────────────────────────────┐
 │                     S7-1200 CPU                        │
 │  ┌──────────────────────────────────────────────────┐  │
 │  │ Operating System (Firmware V4.5)                 │  │
 │  └────────────────────────┬─────────────────────────┘  │
 │                           ▼                            │
 │  ┌──────────────────────────────────────────────────┐  │
 │  │ Memory Subsystems:                               │  │
 │  │ - Load Memory (4 MB Flash)                       │  │
 │  │ - Work Memory (100 KB RAM)                       │  │
 │  │ - Retentive Memory (10 KB NVRAM)                 │  │
 │  │ - Bit Memory (%M Area: %MD10, %MD14, %M0.0)      │  │
 │  └────────────────────────┬─────────────────────────┘  │
 │                           ▼                            │
 │  ┌──────────────────────────────────────────────────┐  │
 │  │ Execution Engine:                                │  │
 │  │ - Cyclic Organization Block [OB1]                │  │
 │  │ - Arithmetic Logic Unit (ALU - IEEE 754 Real)    │  │
 │  └──────────────────────────────────────────────────┘  │
 └────────────────────────────────────────────────────────┘
```

The Siemens S7-1200 architecture executes user code cyclically, isolating hardware inputs and outputs through the Process Image Input (PII) and Process Image Output (PIQ) tables to ensure execution stability.

---

## 9. Siemens TIA Portal V17 Environment

Totally Integrated Automation (TIA) Portal V17 is Siemens' flagship engineering platform. It consolidates multiple industrial disciplines into a single project database:
- **STEP 7 Professional V17:** Programming editor for S7-1200, S7-1500, S7-300, S7-400, and Software Controllers.
- **S7-PLCSIM V17:** Integrated CPU emulator that executes compiled bytecode on the engineering PC without hardware.
- **TIA Portal Hardware Configuration:** Graphical catalog for configuring CPU parameters, IP networking, scan cycle watchdogs, and I/O addresses.

---

## 10. PLC Tags and Data Types

The system relies on strict symbolic tag declarations defined in the PLC Tag Table:

| Tag Name | Suggested Address | Data Type | Initial Value | Purpose & Engineering Description |
| :--- | :--- | :--- | :--- | :--- |
| `Water_Level` | `%MD10` | `Real` | `60.0` | Simulated drum water level percentage ($0.0\% - 100.0\%$). |
| `Low_Level_Threshold` | `%MD14` | `Real` | `30.0` | Configurable low-water alarm trip setpoint ($30.0\%$). |
| `Low_Level_Alarm` | `%M0.0` | `Bool` | `FALSE` | Discrete alarm output: `TRUE` = Alarm Active, `FALSE` = Normal. |
| `Water_Level_Input_Invalid` | `%M0.1` | `Bool` | `FALSE` | Diagnostic flag: `TRUE` if `Water_Level` $< 0.0$ or $> 100.0$. |
| `Threshold_Configuration_Invalid` | `%M0.2` | `Bool` | `FALSE` | Diagnostic flag: `TRUE` if threshold $< 0.0$ or $> 100.0$. |

### Addressing Mechanics
- `%MD10` allocates a 32-bit (4-byte) Double Word in the M-memory area covering byte addresses `%MB10`, `%MB11`, `%MB12`, and `%MB13`.
- `%MD14` allocates the next available non-overlapping Double Word covering `%MB14`, `%MB15`, `%MB16`, and `%MB17`.
- `%M0.0`, `%M0.1`, and `%M0.2` allocate individual discrete bits in byte `%MB0`.

---

## 11. Ladder Logic Design

Ladder Diagram (LAD) represents Boolean logic as rungs connecting a positive left rail to a ground right rail.

### Network 1: Low Water-Level Detection & Alarm Assignment
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

The left rail supplies continuous logic high. When the `CMP <` block evaluates $IN1 < IN2$ as `TRUE`, power flows through the block to the coil `-( )`, energizing `Low_Level_Alarm`.

---

## 12. REAL Comparison Instructions

The comparator `CMP <` operates on 32-bit IEEE 754 floating-point values:
- **Sign Bit (1 bit):** Determines polarity.
- **Exponent (8 bits):** Biased by 127.
- **Mantissa (23 bits):** Significant fractional precision.

### Mathematical Behavior
The instruction evaluates:

$$\text{RLO} = \begin{cases} 1 & \text{if } \text{Water\_Level} < \text{Low\_Level\_Threshold} \\ 0 & \text{if } \text{Water\_Level} \ge \text{Low\_Level\_Threshold} \end{cases}$$

Because floating-point representation involves binary approximation, strict inequalities ($<$ or $>$) are robust, whereas exact equality tests ($==$) are prone to round-off failure.

---

## 13. Low-Level Alarm Operation

### Non-Latching Logic Rationale
In this core monitoring implementation, the alarm is intentionally non-latching:
1. **Dynamic Visibility:** Allows the test engineer to observe alarm activation and immediate de-activation as water level values are adjusted in simulation.
2. **Distinction from Safety Trips:** In industrial plants, advisory warning alarms often clear automatically when the process parameter re-enters the normal band, whereas emergency shutdown trips (which de-energize fuel valves) must latch until manual operator reset.

---

## 14. Program Execution and PLC Scan Cycle

During every scan cycle of the S7-1200:
1. **Input Scan:** Physical inputs are read (or simulated memory values are maintained in RAM).
2. **Logic Execution:** OB1 executes Network 1. The comparator evaluates `Water_Level < Low_Level_Threshold`.
3. **Output Scan:** The assignment coil writes the resulting Boolean state to `%M0.0`.
4. **Execution Time:** The cycle completes in $< 1\text{ ms}$, ensuring near-instantaneous response.

---

## 15. Simulation Methodology

Testing is conducted using **Siemens S7-PLCSIM V17** with a dedicated **Watch Table** (`Watch_Table_Boiler_Level`):
1. The user downloads the compiled hardware and software configuration into PLCSIM.
2. The virtual CPU is placed into `RUN` mode.
3. The engineer uses the Watch Table to modify `"Water_Level"` and `"Low_Level_Threshold"`.
4. Online monitoring (`👓▶`) visualizes live power flow and confirms alarm bit transitions.

---

## 16. Test Cases

The test matrix covers 10 primary operational and boundary conditions:

| Test ID | Water_Level | Threshold | Mathematical Expression | Expected Alarm |
| :---: | :---: | :---: | :---: | :---: |
| **TC-01** | 80.0 | 30.0 | $80.0 < 30.0 \rightarrow \text{FALSE}$ | `FALSE` |
| **TC-02** | 60.0 | 30.0 | $60.0 < 30.0 \rightarrow \text{FALSE}$ | `FALSE` |
| **TC-03** | 30.0 | 30.0 | $30.0 < 30.0 \rightarrow \text{FALSE}$ | `FALSE` |
| **TC-04** | 29.9 | 30.0 | $29.9 < 30.0 \rightarrow \text{TRUE}$ | `TRUE` |
| **TC-05** | 20.0 | 30.0 | $20.0 < 30.0 \rightarrow \text{TRUE}$ | `TRUE` |
| **TC-06** | 0.0 | 30.0 | $0.0 < 30.0 \rightarrow \text{TRUE}$ | `TRUE` |
| **TC-07** | 45.0 | 30.0 | $45.0 < 30.0 \rightarrow \text{FALSE}$ | `FALSE` (Auto-clears) |
| **TC-08** | 25.0 | 40.0 | $25.0 < 40.0 \rightarrow \text{TRUE}$ | `TRUE` |
| **TC-09** | 50.0 | 40.0 | $50.0 < 40.0 \rightarrow \text{FALSE}$ | `FALSE` |
| **TC-10** | 20.0 | 20.0 | $20.0 < 20.0 \rightarrow \text{FALSE}$ | `FALSE` |

---

## 17. Expected Results and Boundary Analysis

### Equal to Threshold Analysis
In **TC-03** and **TC-10**, the measured level is exactly equal to the configured threshold. Because the operator is strictly less than ($<$), the condition evaluates to `FALSE`, and the alarm remains clear.

### Recovery Analysis
In **TC-07**, after being tripped at `0.0%`, restoring the level to `45.0%` causes the alarm to immediately transition from `TRUE` back to `FALSE`, confirming proper non-latching operation.

---

## 18. Troubleshooting

Common failure modes and corrective actions:
- **Red compilation error on comparator:** Check that instruction data type is set to `Real` (not `DInt`).
- **Memory corruption / NaN values:** Check for overlapping memory tags (`%MD10` and `%MD12`); re-address to `%MD10` and `%MD14`.
- **Inverted alarm behavior:** Verify `Water_Level` is on $IN1$ and `Low_Level_Threshold` is on $IN2$.

---

## 19. Industrial Applications

In real-world thermal power and chemical process facilities:
- **Drum Level Indication:** Level signals feed multi-color graphical bar displays on control room operator consoles.
- **Multi-Tier Alarming:** Standard plants utilize Low Advisory Alarm ($30\%$), Low-Low Warning Alarm ($20\%$), and Low-Low-Low Emergency Trip ($10\%$).
- **Three-Element Control:** Feedwater valves are modulated using drum level, steam flow, and feedwater flow.

---

## 20. Limitations of the Simulation

1. **No Process Dynamics:** S7-PLCSIM simulates the PLC CPU, not boiler physics. Level values do not change dynamically with boiling, firing rate, or feedwater inflow.
2. **No Physical I/O Noise:** Field analog transmitters experience electrical noise, signal drift, and 4–20 mA loop impedance effects not present in RAM simulation.
3. **No Redundancy:** Real boilers utilize 2-out-of-3 (2oo3) transmitter voting for safety shutdowns.

---

## 21. Future Enhancements

1. **Analog Scaling:** Integrate `NORM_X` and `SCALE_X` to convert raw analog input `%IW64` ($0 - 27648$) to engineering units.
2. **Hysteresis / Deadband:** Add a 2.0% reset deadband to prevent alarm chatter near setpoint boundaries.
3. **HMI / SCADA Dashboard:** Build a Siemens WinCC Unified HMI screen with bar indicators and alarm banners.
4. **Feedwater Pump Simulation:** Add simulated pump start/stop commands and motor run feedback interlocks.

---

## 22. Conclusion

This project successfully establishes a complete, technically rigorous, educational boiler drum water-level monitoring and alarm system in Siemens TIA Portal V17. By adhering strictly to Siemens LAD conventions, memory alignment rules, and IEEE 754 floating-point comparison principles, the design achieves deterministic performance, verifiable test results, and clear modularity for future industrial expansion.

---

## 23. Glossary of Technical Terms

- **ASME:** American Society of Mechanical Engineers.
- **BOOL:** Boolean data type (1 bit, TRUE or FALSE).
- **BPCS:** Basic Process Control System.
- **Deadband / Hysteresis:** The difference between trip and reset setpoints to prevent chattering.
- **IEEE 754:** Technical standard for floating-point arithmetic.
- **LAD (KOP):** Ladder Diagram programming language (IEC 61131-3).
- **NFPA:** National Fire Protection Association.
- **NORM_X:** Siemens instruction to normalize an integer to a $0.0 - 1.0$ floating-point ratio.
- **OB1:** Main cyclic Organization Block in SIMATIC controllers.
- **PII / PIQ:** Process Image Input / Process Image Output.
- **PLC:** Programmable Logic Controller.
- **PLCSIM:** Siemens software emulator for SIMATIC controllers.
- **PROFINET:** Industrial Ethernet communication standard developed by Siemens / PI.
- **REAL:** 32-bit single-precision floating-point data type.
- **RLO:** Result of Logic Operation (power flow state).
- **SCALE_X:** Siemens instruction to scale a normalized $0.0 - 1.0$ float to engineering units.
- **SCADA:** Supervisory Control and Data Acquisition.
- **SIS / SIL:** Safety-Instrumented System / Safety Integrity Level (IEC 61508 / 61511).
- **TIA Portal:** Totally Integrated Automation Portal (Siemens engineering framework).
- **Watch Table:** TIA Portal tool used to monitor and force variable values in PLC memory during commissioning.
