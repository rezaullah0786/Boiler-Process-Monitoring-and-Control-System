# Ladder Logic Design & Instruction Reference

**Project:** Boiler Process Monitoring and Control System  
**Software:** Siemens TIA Portal V17  
**Language:** Ladder Diagram (LAD / KOP)  
**Execution Context:** Main Organization Block [OB1]  

---

## 1. Fundamentals of Siemens Ladder Diagram (LAD)

Ladder Diagram (LAD) is an IEC 61131-3 graphical programming language modeled after traditional relay electrical schematics.

### Core LAD Concepts
- **Power Rails:**
  - **Left Power Rail:** Represents the positive power supply (+24V DC equivalent). It is the source of continuous logic flow (`TRUE` / `1`).
  - **Right Power Rail:** Represents ground (0V DC / return path).
- **Rungs / Networks:** Horizontal lines connecting instructions from the left rail towards the right rail.
- **Power Flow / RLO (Result of Logic Operation):** The logical state (`0` or `1`) transmitted from one instruction to the next along a rung. An instruction only evaluates its logic if power flow reaches its input pin.
- **Instruction Types:**
  - **Bit Logic Contacts:** Examine bit status (Normally Open `--| |--`, Normally Closed `--|/|--`).
  - **Box Instructions:** Complex operations such as arithmetic, timers, counters, and **comparators** (`[ CMP < ]`). Box instructions have input pins, execute an internal function, and output power flow based on the result.
  - **Coils:** Output instructions that store the RLO into a target bit memory or physical output (`-( )--`, `-(S)-`, `-(R)-`).

---

## 2. Network 1: Low Water-Level Detection & Alarm Assignment

### 2.1 Network Purpose
Network 1 provides continuous, real-time monitoring of the boiler drum water level. It evaluates whether the measured water level has fallen below the configured low safety limit and immediately asserts the low-water alarm.

### 2.2 Graphical Representation (LAD)

```text
====================================================================================================
NETWORK 1: Boiler Drum Low Water-Level Detection & Alarm Assignment
====================================================================================================

   Left Rail                                                              Right Rail
  +---------+                                                            +----------+
  |         |                                                            |          |
  |         |                 +----------+                               |          |
  |         +-----------------+  CMP <   +-------------------( )---------+          |
  |         |                 |   Real   |             "Low_Level_Alarm" |          |
  |         |                 |          |                   %M0.0       |          |
  |         |  "Water_Level" -+ IN1      |                               |          |
  |         |      %MD10      |          |                               |          |
  |         |                 |          |                               |          |
  |         |"Low_Level_Thresh"+ IN2     |                               |          |
  |         |      %MD14      +----------+                               |          |
  |         |                                                            |          |
  +---------+                                                            +----------+
```

### 2.3 Instruction Breakdown: `CMP <` (Real)

The Siemens comparison box `CMP <` performs an algebraic inequality comparison between two operands:

$$\text{Condition: } \text{IN1} < \text{IN2}$$

- **Instruction Name:** `CMP <` (Less-than comparator)
- **Data Type Selected:** `Real` (32-bit single-precision floating point, IEEE 754)
- **Input Pin 1 (`IN1`):** `Water_Level` (`%MD10`) — Process variable representing the simulated drum water level ($0.0\% - 100.0\%$).
- **Input Pin 2 (`IN2`):** `Low_Level_Threshold` (`%MD14`) — Setpoint representing the trip threshold ($30.0\%$).
- **Output:** Passes power flow (RLO = 1) to the right if and only if $\text{IN1} < \text{IN2}$.

### 2.4 Instruction Breakdown: Assignment Coil `-( )`

- **Instruction Name:** Assignment Coil (Standard Output Coil)
- **Operand:** `Low_Level_Alarm` (`%M0.0`)
- **Behavior:**
  - When power flow reaches the coil (RLO = 1), it writes `1` (`TRUE`) to `%M0.0`.
  - When power flow is blocked (RLO = 0), it writes `0` (`FALSE`) to `%M0.0`.

### 2.5 Non-Latching vs Latching Behavior

A critical engineering design decision in this project is the use of a **standard assignment coil `-( )`** rather than a latched Set/Reset pair (`-(S)-` / `-(R)-`):

| Feature | Standard Assignment Coil `-( )` (Implemented) | Latched Coil Pair `-(S)-` / `-(R)-` |
| :--- | :--- | :--- |
| **Logic Style** | Direct combinational mapping | Sequential / stateful latching |
| **Reset Mechanism** | **Automatic:** Resets to `FALSE` the exact scan cycle that the condition clears ($\ge 30.0\%$). | **Manual:** Remains `TRUE` forever until an explicit operator reset pushbutton is pressed. |
| **Testing Simplicity** | **High:** Instant verification by toggling `Water_Level` back and forth. | **Moderate:** Requires manipulating an auxiliary reset bit between tests. |
| **Suitability for This Stage** | **Ideal for educational core simulation** | Ideal for safety shutdown trips in physical boilers |

### 2.6 Boundary Analysis: Equal to Threshold ($30.0\%$)

A frequent interview and engineering question is:  
**"What happens when the water level is exactly 30.0% and the threshold is 30.0%?"**

- The mathematical formula evaluated is:
  $$\text{Condition: } 30.0 < 30.0$$
- In classical mathematics and IEEE 754 logic, $30.0 < 30.0$ is **strictly FALSE**.
- Therefore, the comparison box blocks power flow (RLO = 0).
- The coil `Low_Level_Alarm` is assigned `FALSE`.
- **Engineering Verdict:** The alarm only trips when the level drops below the setpoint (e.g., $29.999\%$). This is verified in Test Case 3 (`30.0` $\rightarrow$ `FALSE`) and Test Case 4 (`29.9` $\rightarrow$ `TRUE`).

---

## 3. Extended Networks: Input Range Validation

In industrial transmitters, an open-circuit wire fault produces an analog reading of $0\text{ mA}$ (which translates to $< 0.0\%$), while a short circuit produces $> 20\text{ mA}$ ($> 100.0\%$). The extended logic introduces supervisory diagnostics to detect abnormal simulation or field values.

### Network 2: Water Level Measurement Range Validation

```text
====================================================================================================
NETWORK 2: Water Level Measurement Out-of-Bounds Diagnostic Check
====================================================================================================

   Left Rail                                                              Right Rail
  +---------+                                                            +----------+
  |         +---+-----------------[ CMP < ]-----------------+------------+          |
  |         |   |                 |  Real  |                |     ( )    |          |
  |         |   |  "Water_Level" -+ IN1    |                | "Water_Level_         |
  |         |   |                 |        |                |  Input_Invalid"       |
  |         |   |           0.0  -+ IN2    |                |    %M0.1   |          |
  |         |   |                 +--------+                |            |          |
  |         |   |                                           |            |          |
  |         |   +-----------------[ CMP > ]-----------------+            |          |
  |         |                     |  Real  |                             |          |
  |         |      "Water_Level" -+ IN1    |                             |          |
  |         |                     |        |                             |          |
  |         |         100.0      -+ IN2    |                             |          |
  |         |                     +--------+                             |          |
  +---------+                                                            +----------+
```

- **Logic:** `Water_Level_Input_Invalid := (Water_Level < 0.0) OR (Water_Level > 100.0);`
- **Behavior:** If an operator enters `-10.0%` or `120.0%`, the diagnostic flag `%M0.1` activates immediately.
- **Critical Safety Rule:** The system **does not** clamp the invalid input to 0% or 100%. Silently clamping data hides sensor faults from operators.

### Network 3: Threshold Configuration Range Validation

```text
====================================================================================================
NETWORK 3: Low-Level Threshold Out-of-Bounds Diagnostic Check
====================================================================================================

   Left Rail                                                              Right Rail
  +---------+                                                            +----------+
  |         +---+-----------------[ CMP < ]-----------------+------------+          |
  |         |   |                 |  Real  |                |     ( )    |          |
  |         |   | "Low_Level_Thresh"+ IN1  |                | "Threshold_Config_    |
  |         |   |                 |        |                |  Invalid"  |          |
  |         |   |           0.0  -+ IN2    |                |    %M0.2   |          |
  |         |   |                 +--------+                |            |          |
  |         |   |                                           |            |          |
  |         |   +-----------------[ CMP > ]-----------------+            |          |
  |         |                     |  Real  |                             |          |
  |         |   "Low_Level_Thresh"+ IN1    |                             |          |
  |         |                     |        |                             |          |
  |         |         100.0      -+ IN2    |                             |          |
  |         |                     +--------+                             |          |
  +---------+                                                            +----------+
```

- **Logic:** `Threshold_Configuration_Invalid := (Low_Level_Threshold < 0.0) OR (Low_Level_Threshold > 100.0);`
- **Behavior:** Prevents an engineer or operator from setting a trip point that is physically unattainable (such as `150.0%` or `-20.0%`).

---

## 4. Single Network vs Multi-Network Architecture

Can Network 1 and the Alarm output be separated into two networks?

### Approach A: Single Unified Network (Implemented)
$$\text{CMP } < \longrightarrow \text{Assignment Coil}$$
- **Advantage:** Maximum clarity, minimal memory, instantaneous execution. One visual glance conveys the entire monitoring logic.
- **Recommendation:** Best for educational clarity and standard simple comparators.

### Approach B: Two Networks with Intermediary Memory Flag
- **Network 1:** $\text{CMP } < \longrightarrow \text{Intermediary\_Low\_Condition (\%M2.0)}$
- **Network 2:** $\text{Intermediary\_Low\_Condition} \longrightarrow \text{Low\_Level\_Alarm (\%M0.0)}$
- **When Useful:** If other parts of the program (e.g. pump start interlocks, emergency trip routines, SCADA event logs) also require the raw comparison result without re-evaluating the floating-point math multiple times.

---

## 5. Common Ladder Programming Mistakes & How to Prevent Them

1. **Inverted Operands:**  
   Placing `Low_Level_Threshold` on `IN1` and `Water_Level` on `IN2` yields $\text{Threshold} < \text{Water\_Level}$, which triggers the alarm on high level instead of low level.
2. **Incorrect Comparator Selected:**  
   Selecting `CMP >` or `CMP <=` instead of `CMP <`.
3. **Data Type Mismatch:**  
   Forgetting to change the data type from `DInt` to `Real`.
4. **Memory Tag Address Overlap:**  
   Allocating `%MD10` and `%MD12` instead of `%MD10` and `%MD14`.
5. **Using a SET `-(S)-` Coil Without a Corresponding RESET `-(R)-` Coil:**  
   Causes the alarm to latch ON permanently after the first sub-threshold event.
