# Test Execution Checklist & Verification Protocol

**Project:** Boiler Process Monitoring and Control System  
**Software:** Siemens TIA Portal V17 & S7-PLCSIM V17  
**Target Hardware:** SIMATIC S7-1200 CPU 1214C DC/DC/DC (Simulation)  
**Document Revision:** 1.0  
**Status:** Ready for Physical/Simulated Execution  

---

## 1. Test Setup Prerequisites

Before beginning verification in S7-PLCSIM, verify each item below:

- [ ] **Hardware Configuration Compiled:** Device configuration compiled without errors (`0 Errors, 0 Warnings`).
- [ ] **Software Logic Compiled:** Main [OB1] and tag tables compiled with clean status (`0 Errors, 0 Warnings`).
- [ ] **PLCSIM Started:** S7-PLCSIM V17 instance launched and running.
- [ ] **Program Downloaded:** Logic loaded into PLCSIM without transfer errors.
- [ ] **CPU Mode Set to RUN:** CPU LED indicates solid green `RUN` (no orange stop or red error).
- [ ] **Watch Table Created:** "Watch_Table_Boiler_Level" created containing:
  - `"Water_Level"` (Display Format: Floating point / Real)
  - `"Low_Level_Threshold"` (Display Format: Floating point / Real)
  - `"Low_Level_Alarm"` (Display Format: Boolean)
  - *(Extended)* `"Water_Level_Input_Invalid"` (Display Format: Boolean)
  - *(Extended)* `"Threshold_Configuration_Invalid"` (Display Format: Boolean)
- [ ] **Monitoring Active:** Clicked glasses icon with play button (**Monitor all**) in Watch Table and OB1 online view.

---

## 2. Test Execution Matrix

Execute each test case in sequence. Enter the specified values into the **Modify value** column of the Watch Table, execute the modification (**Modify now** / `Flash icon with lighting`), and observe the **Monitor value** column. Record the actual observed state.

| Test ID | Sequence / Action Description | Water_Level Input | Threshold Setting | Mathematical Logic | Expected Low_Level_Alarm | Actual Observed in PLCSIM | Execution Status (Pass/Fail) | Verified By & Timestamp |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **TC-01** | High normal operating level | `80.0` | `30.0` | $80.0 < 30.0 \rightarrow \text{FALSE}$ | `FALSE` | [ ] `FALSE`<br>[ ] `TRUE` | [ ] Pending<br>[ ] PASS<br>[ ] FAIL | __________________ |
| **TC-02** | Standard mid-range level | `60.0` | `30.0` | $60.0 < 30.0 \rightarrow \text{FALSE}$ | `FALSE` | [ ] `FALSE`<br>[ ] `TRUE` | [ ] Pending<br>[ ] PASS<br>[ ] FAIL | __________________ |
| **TC-03** | **Boundary Test:** Level strictly equal to threshold | `30.0` | `30.0` | $30.0 < 30.0 \rightarrow \text{FALSE}$ | `FALSE` | [ ] `FALSE`<br>[ ] `TRUE` | [ ] Pending<br>[ ] PASS<br>[ ] FAIL | __________________ |
| **TC-04** | **Sub-threshold Trip:** Level drops 0.1% below threshold | `29.9` | `30.0` | $29.9 < 30.0 \rightarrow \text{TRUE}$ | `TRUE` | [ ] `FALSE`<br>[ ] `TRUE` | [ ] Pending<br>[ ] PASS<br>[ ] FAIL | __________________ |
| **TC-05** | Standard low-level alarm condition | `20.0` | `30.0` | $20.0 < 30.0 \rightarrow \text{TRUE}$ | `TRUE` | [ ] `FALSE`<br>[ ] `TRUE` | [ ] Pending<br>[ ] PASS<br>[ ] FAIL | __________________ |
| **TC-06** | Worst-case low condition (dry drum) | `0.0` | `30.0` | $0.0 < 30.0 \rightarrow \text{TRUE}$ | `TRUE` | [ ] `FALSE`<br>[ ] `TRUE` | [ ] Pending<br>[ ] PASS<br>[ ] FAIL | __________________ |
| **TC-07** | **Recovery Verification:** Water level restored above threshold | `45.0` | `30.0` | $45.0 < 30.0 \rightarrow \text{FALSE}$ | `FALSE` (Auto-clears) | [ ] `FALSE`<br>[ ] `TRUE` | [ ] Pending<br>[ ] PASS<br>[ ] FAIL | __________________ |
| **TC-08** | Dynamic threshold adjustment: Threshold raised to 40.0% | `25.0` | `40.0` | $25.0 < 40.0 \rightarrow \text{TRUE}$ | `TRUE` | [ ] `FALSE`<br>[ ] `TRUE` | [ ] Pending<br>[ ] PASS<br>[ ] FAIL | __________________ |
| **TC-09** | Dynamic threshold adjustment: Safe level with 40.0% threshold | `50.0` | `40.0` | $50.0 < 40.0 \rightarrow \text{FALSE}$ | `FALSE` | [ ] `FALSE`<br>[ ] `TRUE` | [ ] Pending<br>[ ] PASS<br>[ ] FAIL | __________________ |
| **TC-10** | **Boundary Test:** Threshold lowered to 20.0%, level equal | `20.0` | `20.0` | $20.0 < 20.0 \rightarrow \text{FALSE}$ | `FALSE` | [ ] `FALSE`<br>[ ] `TRUE` | [ ] Pending<br>[ ] PASS<br>[ ] FAIL | __________________ |

---

## 3. Extended Logic Verification (Optional Validation Tier)

If you implemented Network 2 and Network 3 (Range Validation), execute the following diagnostic tests:

| Test ID | Sequence / Action Description | Water_Level | Low_Level_Threshold | Diagnostic Flag Expected | Actual Observed | Execution Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: |
| **TC-EXT-01** | Negative input value simulation | `-5.0` | `30.0` | `Water_Level_Input_Invalid = TRUE` | [ ] TRUE &nbsp; [ ] FALSE | [ ] PASS &nbsp; [ ] FAIL |
| **TC-EXT-02** | Over-range input value simulation | `105.0` | `30.0` | `Water_Level_Input_Invalid = TRUE` | [ ] TRUE &nbsp; [ ] FALSE | [ ] PASS &nbsp; [ ] FAIL |
| **TC-EXT-03** | Normal in-bounds input | `55.0` | `30.0` | `Water_Level_Input_Invalid = FALSE` | [ ] TRUE &nbsp; [ ] FALSE | [ ] PASS &nbsp; [ ] FAIL |
| **TC-EXT-04** | Invalid threshold setpoint configuration | `50.0` | `120.0` | `Threshold_Configuration_Invalid = TRUE`| [ ] TRUE &nbsp; [ ] FALSE | [ ] PASS &nbsp; [ ] FAIL |

---

## 4. Key Functional Behaviors to Confirm

During testing, specifically verify these three critical behaviors:

1. **Non-Latching Operation:**
   - When transitioning from **TC-06** (`0.0%`, Alarm Active) to **TC-07** (`45.0%`, Alarm Inactive), verify that `Low_Level_Alarm` transitions from `TRUE` to `FALSE` immediately on the next PLC scan cycle without requiring an explicit operator acknowledge or reset button.
   - *Technical reason:* The coil `-( )` is an assignment instruction. When power flow is FALSE, the coil actively writes `0` (FALSE) to `%M0.0`.

2. **Strict Less-Than Inequality:**
   - In **TC-03** (`30.0%` vs `30.0%`), verify that the alarm remains `FALSE`.
   - *Technical reason:* The instruction used is `<` (`CMP <`), NOT `<=`. The condition is only satisfied when the input is strictly lower than the threshold.

3. **Floating-Point Representation:**
   - Verify that small fractional differences operate accurately without rounding errors (e.g., `29.9%` triggers alarm, `30.0%` does not).

---

## 5. Test Sign-Off & Execution Summary

- **Total Test Cases Planned:** 10 core + 4 extended
- **Total Test Cases Executed:** [ &nbsp;&nbsp;&nbsp;&nbsp; ]
- **Total Test Cases Passed:** [ &nbsp;&nbsp;&nbsp;&nbsp; ]
- **Total Test Cases Failed:** [ &nbsp;&nbsp;&nbsp;&nbsp; ]
- **Testing Engineer Name:** ______________________________________
- **Signature / Date:** ______________________________________
- **Final Verdict:** [ ] ACCEPTED FOR EDUCATIONAL DEMONSTRATION &nbsp;&nbsp; [ ] REVISION REQUIRED
