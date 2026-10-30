# Diagnostic & Troubleshooting Guide

**Project:** Boiler Process Monitoring and Control System  
**Platform:** Siemens TIA Portal V17 & S7-PLCSIM V17  
**Scope:** Engineering Troubleshooting Protocols & Root-Cause Resolution  

---

## 1. Troubleshooting Quick Reference Matrix

| Symptom / Error Message | Probable Root Cause | Resolution Protocol |
| :--- | :--- | :--- |
| **"Data type Real does not match DInt"** | Comparison box instruction type remains set to default `DInt` or `<Auto>`. | Click the bottom dropdown of the `CMP <` box in OB1 and explicitly select `Real`. Recompile. |
| **"Tag 'Water_Level' is not defined"** | Tag name typo or tag defined in another CPU / uncompiled tag table. | Open `PLC tags` $\rightarrow$ `Default tag table`. Confirm exact spelling and case sensitivity. |
| **Alarm stays ON constantly** | 1. Operands inverted ($IN1 = \text{Threshold}$, $IN2 = \text{Level}$).<br>2. Latching coil `-(S)-` used instead of `-( )-`. | 1. Ensure `Water_Level` is connected to $IN1$ and `Low_Level_Threshold` to $IN2$.<br>2. Replace SET coil with assignment coil `-( )-`. |
| **Alarm never activates** | 1. CPU in `STOP` mode.<br>2. Monitoring (`👓▶`) not active.<br>3. Overlapping memory tag corrupting values. | 1. Check virtual CPU LED; switch to `RUN`.<br>2. Click `Monitoring on/off`.<br>3. Verify `%MD10` and `%MD14` addresses do not collide. |
| **Water_Level shows `1.#QNAN` or `0.0`** | Byte overlap in M-memory (e.g., using `%MD10` and `%MD12`). | Ensure memory tags are spaced 4 bytes apart: `%MD10`, `%MD14`, `%MD18`. |
| **Watch Table values revert immediately** | Another logic network is cyclically writing to `%MD10` (e.g. unconditioned move or analog scaling). | In simulation mode, ensure no logic writes to `%MD10` so manual overrides persist. |
| **"Simulation cannot be started"** | 1. S7-PLCSIM V17 not installed.<br>2. Antivirus blocking virtual Ethernet driver. | 1. Verify S7-PLCSIM V17 is installed in Control Panel.<br>2. Run TIA Portal as Administrator. |
| **"Cannot reach target device" in PLCSIM** | PG/PC interface misconfigured in download dialog. | Set PG/PC interface type to `PN/IE` and select `Siemens PLCSIM Virtual Ethernet Adapter`. |

---

## 2. In-Depth Diagnostic Scenarios

### Scenario A: Floating-Point Memory Overlap (%MD10 vs %MD12)
- **The Problem:** An engineer declares `Water_Level` at `%MD10` and `Low_Level_Threshold` at `%MD12`.
- **Technical Explanation:**
  - In Siemens architecture:
    - `%MD10` consists of byte `%MB10`, `%MB11`, `%MB12`, and `%MB13`.
    - `%MD12` consists of byte `%MB12`, `%MB13`, `%MB14`, and `%MB15`.
  - Notice that bytes `%MB12` and `%MB13` are shared by both tags!
  - Modifying `Low_Level_Threshold` overwrites the lower mantissa bits of `Water_Level`, corrupting the floating-point representation into garbage numbers or `NaN` (Not a Number).
- **Correct Configuration:**
  - `Water_Level`: `%MD10` (Bytes 10, 11, 12, 13)
  - `Low_Level_Threshold`: `%MD14` (Bytes 14, 15, 16, 17)
  - Spacing = 4 bytes minimum.

---

### Scenario B: Comparator Operands Inversion
- **The Problem:** The alarm activates when water level is 80%, but turns off when water level drops to 10%.
- **Technical Explanation:**
  - The comparator was configured with:
    - $IN1 = \text{Low\_Level\_Threshold}$ (`30.0`)
    - $IN2 = \text{Water\_Level}$ (`80.0`)
  - Evaluated condition: $30.0 < 80.0 \rightarrow \text{TRUE}$ (Alarm trips!).
  - When level drops: $30.0 < 10.0 \rightarrow \text{FALSE}$ (Alarm turns off!).
- **Resolution:** Always keep Process Variable ($PV$) on $IN1$ and Setpoint ($SP$) on $IN2$:
  $$\text{Condition: } PV < SP \implies \text{Water\_Level} < \text{Low\_Level\_Threshold}$$

---

### Scenario C: S7-PLCSIM Download and Communication Failures
- **The Problem:** TIA Portal reports `Failed to establish connection to target device` when clicking Download.
- **Systematic Resolution Procedure:**
  1. Open Windows **Task Manager**.
  2. Locate `Siemens.Simatic.PlcSim.V17.exe`. If it is hanging or unresponsive, end the task.
  3. In TIA Portal, select menu `Online` $\rightarrow$ `Accessible devices`.
  4. Select `PN/IE` and `Siemens PLCSIM Virtual Ethernet Adapter`.
  5. Check if `PLC_1` appears with IP `192.168.0.1`.
  6. If the adapter is missing, open Windows Device Manager $\rightarrow$ Network Adapters $\rightarrow$ verify `Siemens PLCSIM Virtual Adapter` is enabled.
  7. Relaunch simulation from TIA Portal via `Ctrl + Shift + X`.

---

### Scenario D: Watch Table Modification vs Forcing
- **Understanding the Difference:**
  - **Modify Value (`⚡`):** Writes the value into RAM at the specific execution point (start or end of scan). Logic in OB1 can overwrite this value if another instruction targets the same tag.
  - **Force (`F`):** Dedicated hardware maintenance feature that permanently pins a physical I/O address regardless of user program logic.
  - *Recommendation:* For simulated `%M` tags, always use **Modify value** in the Watch Table. Do not use Force, as forcing is reserved for physical I/O and leaves a yellow warning LED on the CPU.
