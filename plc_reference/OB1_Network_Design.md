# OB1 Network Design & Ladder Logic Specification

**Block Title:** Main Organization Block [OB1]  
**Target Environment:** Siemens TIA Portal V17  
**Target Hardware:** SIMATIC S7-1200 (CPU 1214C DC/DC/DC - 6ES7 214-1AG40-0XB0, FW V4.5)  
**Programming Language:** Ladder Diagram (LAD / KOP)  
**Execution Category:** Cyclic Program Cycle (Priority 1)  

---

## 1. Architectural Overview & Block Selection

In Siemens SIMATIC architectures, execution is organized through Blocks:
- **Organization Blocks (OB):** Interface between the operating system and the user program. **OB1** is executed cyclically by the PLC operating system as long as the CPU is in `RUN` mode.
- **Function Blocks (FB) & Instance Data Blocks (iDB):** Blocks that maintain stateful internal memory across cycles.
- **Functions (FC):** Stateless routines.

### Implementation Architecture Comparison

| Aspect | Beginner Implementation (Direct OB1) | Modular Implementation (FB + DB) |
| :--- | :--- | :--- |
| **Block Used** | `Main [OB1]` | `FB_BoilerMonitoring [FB1]` called from `OB1` |
| **Data Storage** | Global Bit Memory (`%M`) or Global DB | Dedicated Instance Data Block (`DB_BoilerMonitoring [DB1]`) |
| **Complexity** | Lowest — single screen, direct tag access | Moderate — requires understanding block parameters & DB instances |
| **Multi-instance Capability** | None — tightly coupled to global memory | High — one FB can monitor Boiler 1, Boiler 2, Boiler 3 independently |
| **Recommendation** | **Recommended for Initial Build** | Documented below for modular scaling |

---

## 2. Core Implementation: Network 1 Specification

### Network Header
- **Network Number:** Network 1
- **Network Title:** Low Water-Level Detection & Alarm Assignment
- **Network Comment:**
  ```text
  Cyclically compares the current simulated boiler drum water level (Water_Level)
  against the operator-configured trip threshold (Low_Level_Threshold).
  If Water_Level < Low_Level_Threshold is TRUE, the power flow energizes Low_Level_Alarm.
  If Water_Level >= Low_Level_Threshold is FALSE, power flow is interrupted,
  de-energizing Low_Level_Alarm (non-latching).
  ```

### Graphical Ladder Representation (TIA Portal LAD Layout)

```text
  Power Rail                                                                  Power Rail
  (Left)                                                                        (Right)
  ---|-------------------------[ CMP < ]--------------------------( )-------------|---
     |                         |  Real  |                   "Low_Level_Alarm"     |
     |                         |        |                         %M0.0           |
     |  "Water_Level" -------->| IN1    |                                         |
     |      %MD10              |        |                                         |
     |                         |        |                                         |
     |  "Low_Level_Threshold"->| IN2    |                                         |
     |      %MD14              +--------+                                         |
     |                                                                            |
```

### Technical Specification Table

| Element | Parameter / Name | Data Type | Address / Type | Functional Role |
| :--- | :--- | :--- | :--- | :--- |
| **Left Power Rail** | Incoming RLO | Logic Flow | System | Provides continuous logic high (Power) |
| **Instruction Box** | `CMP <` | Box (Comparator) | IEC / Siemens Native | Compares two floating point values: $IN1 < IN2$ |
| **Data Type Selector** | `Real` | Dropdown | 32-bit IEEE 754 | Configures instruction internal precision |
| **Box Input 1 (IN1)**| `Water_Level` | REAL | `%MD10` | Process variable: Current drum level (0.0% – 100.0%) |
| **Box Input 2 (IN2)**| `Low_Level_Threshold`| REAL | `%MD14` | Setpoint: Low-level trip threshold (Default 30.0%) |
| **Assignment Coil**  | `Low_Level_Alarm` | BOOL | `%M0.0` | Output indicator: TRUE = Alarm Active, FALSE = Clear |

### Detailed Execution Mechanics (Scan by Scan)

1. **Comparison Execution:**
   - At the beginning of Network 1, the PLC arithmetic unit loads the 32-bit floating-point value stored at `%MD10` (`Water_Level`).
   - It loads the 32-bit floating-point value stored at `%MD14` (`Low_Level_Threshold`).
   - It executes a binary floating-point subtraction / comparison flag check.
2. **Result of Logic Operation (RLO):**
   - If `Water_Level` is strictly less than `Low_Level_Threshold` (e.g. `29.9 < 30.0`), the internal comparison condition evaluates to `TRUE`.
   - The instruction box passes power flow (RLO = 1) to its output pin.
3. **Coil Energization:**
   - The assignment coil `-( )` receives RLO = 1 and writes bit `1` (`TRUE`) into `%M0.0` (`Low_Level_Alarm`).
4. **Automatic Reset (Non-Latching):**
   - On a subsequent scan, if `Water_Level` increases to `30.0` or higher, the comparison condition $30.0 < 30.0$ evaluates to `FALSE`.
   - The comparison box blocks power flow (RLO = 0).
   - In Siemens LAD, an assignment coil `-( )` is **not** a SET latch; when RLO = 0 reaches the coil, it explicitly writes bit `0` (`FALSE`) into `%M0.0`.
   - Thus, the alarm automatically clears without requiring an auxiliary reset circuit.

---

## 3. Extended Implementation: Range Validation Networks

In industrial automation, evaluating raw process inputs without boundary checking risks undetected failures (e.g., sensor wire disconnection or transmitter out-of-calibration). The Extended Version adds Networks 2 and 3 to flag anomalous values without clobbering the core comparison.

### Network 2: Water Level Measurement Input Range Validation
- **Network Title:** Water Level Input Out-of-Bounds Diagnostic Check
- **Network Comment:** Detects if the simulated water level falls outside the normalized 0.0% – 100.0% span.

```text
  ---|-------------------------[ CMP < ]--------------------------( )-------------|---
     |                         |  Real  |               "Water_Level_Input_Invalid"
     |  "Water_Level" -------->| IN1    |                         %M0.1
     |                         |        |
     |         0.0 ----------->| IN2    |
     |                         +--------+
     |
     |-------------------------[ CMP > ]--------------------------( )-------------|---
                               |  Real  |               "Water_Level_Input_Invalid"
        "Water_Level" -------->| IN1    |                         %M0.1
                               |        |
             100.0 ----------->| IN2    |
                               +--------+
```

*Note on Ladder OR Branching:* In TIA Portal, both comparison boxes can be placed in parallel (OR branch) driving a single coil `-( )`, as represented below:

```text
  ---|---+---------------------[ CMP < ]--------------------+-----( )-------------|---
     |   |                     |  Real  |                   |  "Water_Level_Input_Invalid"
     |   | "Water_Level" ----->| IN1    |                   |            %M0.1
     |   |         0.0 ------->| IN2    |                   |
     |   |                     +--------+                   |
     |   |                                                  |
     |   +---------------------[ CMP > ]--------------------+
     |                         |  Real  |                   |
     |   "Water_Level" ------->| IN1    |                   |
     |       100.0 ----------->| IN2    |                   |
     |                         +--------+                   |
```

### Network 3: Low-Level Threshold Configuration Range Validation
- **Network Title:** Low-Level Threshold Out-of-Bounds Diagnostic Check
- **Network Comment:** Validates that the operator setpoint is physically reachable between 0.0% and 100.0%.

```text
  ---|---+---------------------[ CMP < ]--------------------+-----( )-------------|---
     |   |                     |  Real  |                   | "Threshold_Config_Invalid"
     |   | "Low_Level_Thresh"->| IN1    |                   |            %M0.2
     |   |         0.0 ------->| IN2    |                   |
     |   |                     +--------+                   |
     |   |                                                  |
     |   +---------------------[ CMP > ]--------------------+
     |                         |  Real  |                   |
     |   "Low_Level_Thresh" -->| IN1    |                   |
     |       100.0 ----------->| IN2    |                   |
     |                         +--------+                   |
```

---

## 4. Alternative Modular Architecture: Function Block (FB) Design

For systems where multiple boiler drums or tanks exist, encapsulating the logic in a reusable Function Block (`FB_BoilerMonitoring`) is standard practice.

### FB Interface Declaration

```text
FUNCTION_BLOCK "FB_BoilerMonitoring"
{ S7_Optimized_Access := 'TRUE' }
VERSION : 0.1
   VAR_INPUT 
      rWaterLevel : Real;             // Current measured drum water level (%)
      rLowLevelThreshold : Real;      // Configured low-level trip threshold (%)
   END_VAR

   VAR_OUTPUT 
      bLowLevelAlarm : Bool;          // Active low water level alarm state
      bWaterLevelInvalid : Bool;      // Input water level out-of-range flag
      bThresholdInvalid : Bool;       // Threshold setpoint out-of-range flag
   END_VAR
```

### OB1 Calling Network (Call FB with Instance DB)

```text
  ---|--------------------[ "FB_BoilerMonitoring" ]----------------|---
     |                        "InstBoiler1_DB"                     |
     |                                                             |
     |  "Water_Level" -------> rWaterLevel         bLowLevelAlarm -> "Low_Level_Alarm"
     |                                                             |
     |  "Low_Level_Thresh" --> rLowLevelThreshold                  |
     |                                                             |
```

---

## 5. Critical Implementation Traps & How to Avoid Them

1. **Tag Overlap in M-Memory:**
   - In S7-1200, a `REAL` requires **4 bytes** (Double Word / DWord).
   - If `"Water_Level"` is assigned `%MD10`, it occupies `%MB10`, `%MB11`, `%MB12`, and `%MB13`.
   - Assigning `"Low_Level_Threshold"` to `%MD12` causes **memory collision**, corrupting both values.
   - Always advance by at least 4 bytes: `%MD10` $\rightarrow$ `%MD14` $\rightarrow$ `%MD18`.
2. **Instruction Type Dropdown:**
   - In TIA Portal, placing a comparison box defaults to `<Auto>` or `DInt`.
   - You **must** click the bottom dropdown of the comparison box and select `Real`. Failure to do so causes a red compilation error: `Data type Real does not match DInt`.
3. **Operand Reversal:**
   - Ensure `Water_Level` is wired to `IN1` and `Low_Level_Threshold` is wired to `IN2`.
   - If reversed ($30.0 < \text{Water\_Level}$), the alarm would trigger at high water levels instead of low water levels!
