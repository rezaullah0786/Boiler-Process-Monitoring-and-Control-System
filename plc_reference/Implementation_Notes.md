# Technical Implementation Notes: Siemens S7-1200 & TIA Portal V17

**Engineering Reference Document**  
**Project:** Boiler Process Monitoring and Control System  
**Hardware Platform:** Siemens SIMATIC S7-1200 Series (CPU 1214C DC/DC/DC, Part No: 6ES7 214-1AG40-0XB0)  
**Engineering Software:** Siemens TIA Portal V17 (Totally Integrated Automation Portal)  

---

## 1. Hardware Architecture & CPU Selection

The **SIMATIC S7-1200** was selected as the reference platform for this project due to its widespread adoption in small-to-medium process skids, educational laboratories, and utility control packages.

### CPU Specifications
- **Model:** CPU 1214C DC/DC/DC
- **Work Memory:** 100 KB integrated work memory (Code & Data)
- **Load Memory:** 4 MB integrated load memory
- **Retentive Memory:** 10 KB retentive memory
- **Onboard I/O:** 14 digital inputs (24V DC), 10 digital outputs (24V DC transistor), 2 analog inputs (0–10V DC, 10-bit resolution).
- **Communication:** Integrated PROFINET port (RJ45, 10/100 Mbps) supporting S7 Communication, Open User Communication (TCP/IP, UDP), Modbus TCP, and PROFINET IO Controller/Device.
- **Firmware Version:** V4.5 (fully supported in TIA Portal V17; backward-compatible with V4.2+).

---

## 2. Memory Organization & Addressing Strategies

Siemens S7-1200 PLCs support two primary memory addressing models: **Direct Absolute Addressing** (M, I, Q) and **Optimized Symbolic Data Blocks (DB)**.

### A. Bit Memory (%M Area) - Used in Beginner Model
For beginner educational purposes, this project defines tags in the global bit memory (`%M`) area:
- `%MD10` (`Water_Level`): 4-byte double word (Bytes 10, 11, 12, 13) interpreted as IEEE 754 32-bit single-precision float.
- `%MD14` (`Low_Level_Threshold`): 4-byte double word (Bytes 14, 15, 16, 17) interpreted as float.
- `%M0.0` (`Low_Level_Alarm`): Single discrete memory bit in Byte 0.
- `%M0.1` (`Water_Level_Input_Invalid`): Single bit in Byte 0.
- `%M0.2` (`Threshold_Configuration_Invalid`): Single bit in Byte 0.

> [!WARNING]
> **Byte Overlap Hazard:** A common beginner error is addressing tags consecutively by word increments (e.g., `%MD10` and `%MD12`). Because a `REAL` requires 4 bytes (32 bits), `%MD10` spans bytes 10 to 13. Allocating `%MD12` overlaps bytes 12 and 13, causing severe data corruption whenever either variable is modified. Always advance addresses by at least 4 bytes (`%MD10`, `%MD14`, `%MD18`).

### B. Global Data Blocks with Optimized Access - Industrial Best Practice
In modern industrial S7-1200/1500 development, direct `%M` memory is avoided in favor of **Optimized Data Blocks**:
- **Symbolic-Only:** Variables do not have fixed byte offsets (%DB1.DBD0). The compiler automatically arranges variables in RAM to maximize 32-bit CPU memory alignment and access speed.
- **Type Safety:** Eliminates accidental byte overlap.
- **Retentivity:** Individual tags can be configured as **Retain** (preserving setpoints through power loss) without allocating large blocks of retentive marker memory.

---

## 3. Data Types & IEEE 754 Floating-Point Representation

### The `REAL` Data Type
The water level and threshold variables utilize the `REAL` data type:
- **Bit Length:** 32 bits.
- **Standard:** ANSI/IEEE Std 754-1985.
- **Structure:**
  - Bit 31: Sign bit ($0 = \text{positive}, 1 = \text{negative}$).
  - Bits 30–23: Biased exponent (8 bits, bias = 127).
  - Bits 22–0: Fractional mantissa (23 bits, normalized with an implicit leading 1).
- **Range:** $\pm 1.175495 \times 10^{-38}$ to $\pm 3.402823 \times 10^{+38}$.

### Why `REAL` is Essential for Process Variables
1. **Fractional Precision:** Analog instruments represent continuous physical phenomena. An integer (`INT`) cannot distinguish between `29.9%` and `30.0%`, leading to quantization error and coarse trip points.
2. **Standardization with Engineering Units:** Process transmitters transmit normalized values that map to floating-point engineering units (e.g., $0.0\% - 100.0\%$, $0.0 - 500.0\text{ mm}$, or $0.0 - 10.0\text{ bar}$).
3. **Comparison Behavior:** Equality comparisons (`CMP ==`) are dangerous with `REAL` values due to internal binary rounding (e.g., `0.1` cannot be represented with infinite precision in binary). Using strict inequality (`CMP <`) avoids indeterminate states near boundary edges.

---

## 4. PLC Scan Cycle Execution & Determinism

The SIMATIC S7-1200 executes code cyclically according to strict deterministic sequence:

```text
 ┌────────────────────────────────────────────────────────┐
 │ 1. Internal OS Tasks & Diagnostics                      │
 └───────────────────────────┬────────────────────────────┘
                             ▼
 ┌────────────────────────────────────────────────────────┐
 │ 2. Process Image Input (PII) Update                    │
 │    Physical input terminal states copied into RAM PII  │
 └───────────────────────────┬────────────────────────────┘
                             ▼
 ┌────────────────────────────────────────────────────────┐
 │ 3. User Program Execution (Main OB1)                   │
 │    - Network 1: Water_Level < Low_Level_Threshold      │
 │    - Output Low_Level_Alarm coil evaluated             │
 │    - Networks 2 & 3: Range diagnostics evaluated       │
 └───────────────────────────┬────────────────────────────┘
                             ▼
 ┌────────────────────────────────────────────────────────┐
 │ 4. Communication Processing                            │
 │    Handle TIA Portal Watch Table / PLCSIM / HMI queries│
 └───────────────────────────┬────────────────────────────┘
                             ▼
 ┌────────────────────────────────────────────────────────┐
 │ 5. Process Image Output (PIQ) Update                   │
 │    Coil states written from RAM PIQ to physical relays │
 └───────────────────────────┬────────────────────────────┘
                             │
                             └───► Loops back to Step 1
```

### Scan Cycle Implications for the Alarm Logic
- **Scan Time:** In an S7-1200 CPU executing this lightweight logic, the scan time is typically **sub-millisecond (< 1 ms)**.
- **Continuous Evaluation:** The comparison `Water_Level < Low_Level_Threshold` is re-evaluated hundreds of times per second.
- **Atomic Assignment:** When the water level returns to a safe level ($\ge 30.0\%$), the RLO becomes FALSE. The coil `-( )` immediately executes an active write of `0` to `%M0.0`. There is no "stuck" state or delay in resetting.

---

## 5. Simulation Environment: S7-PLCSIM V17 Capabilities & Boundaries

Siemens **S7-PLCSIM V17** is an emulation tool running on the Windows host that emulates the S7-1200 CPU firmware kernel:
- **What PLCSIM Does:** Emulates instruction execution, timers, counters, memory areas, math functions, and OB execution identical to physical silicon.
- **What PLCSIM Does Not Do:** Does not generate physical process physics (e.g., boiler heat transfer, steam generation, water evaporation). In this project, process values are manually injected or driven via Watch Tables.
- **Networking:** PLCSIM communicates with TIA Portal through a virtual soft-bus (Simulated S7-1200 / PROFINET interface). No physical Ethernet cables or network cards are required.
