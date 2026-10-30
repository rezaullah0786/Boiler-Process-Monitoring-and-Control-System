# Siemens TIA Portal V17: Step-by-Step Implementation Guide

**Project:** Boiler Process Monitoring and Control System  
**Software Version:** Siemens Totally Integrated Automation (TIA) Portal V17  
**Simulator:** S7-PLCSIM V17  
**Target Controller:** SIMATIC S7-1200 (CPU 1214C DC/DC/DC, 6ES7 214-1AG40-0XB0, FW V4.5)  

---

## Guide Overview

This guide walks through every step required to build, configure, program, simulate, and verify the boiler drum level monitoring logic in Siemens TIA Portal V17. Follow each step in chronological order.

---

### Step 1: Open Siemens TIA Portal V17
- **What to click or configure:**  
  Double-click the desktop shortcut **Totally Integrated Automation Portal V17** (or search Windows Start for `TIA Portal V17`). Wait for the splash screen to initialize the Siemens engineering runtime.
- **Why the step is necessary:**  
  TIA Portal is the unified engineering software framework that integrates PLC programming (STEP 7 Professional), HMI engineering (WinCC), drive parameterization (Startdrive), and simulation interfaces.
- **Expected result:**  
  The TIA Portal **Portal View** opens with the start page offering options: *Open existing project*, *Create new project*, or *Migrate project*.
- **Common mistakes & troubleshooting:**  
  *Mistake:* Launching S7-PLCSIM first instead of TIA Portal. Always start TIA Portal first; PLCSIM can be invoked directly from within the engineering project.

---

### Step 2: Create a New Project
- **What to click or configure:**  
  1. Click **Create new project** in the left navigation menu.
  2. In the **Project name** field, enter: `Boiler_Process_Monitoring`.
  3. In the **Path** field, choose your target storage directory (e.g., `D:\PROJECT\Siemens_Projects`).
  4. In the **Author** field, enter your name.
  5. In the **Comment** field, enter: `Educational Boiler Drum Water-Level Monitoring System in LAD`.
  6. Click the blue **Create** button.
- **Why the step is necessary:**  
  Creates the project directory hierarchy, database, and hardware repository files (`.ap17` project bundle).
- **Expected result:**  
  The project is generated. At the bottom left, click **Project view** to switch to the full engineering workspace.
- **Common mistakes & troubleshooting:**  
  *Mistake:* Storing projects on network drives or paths with non-ASCII characters, which can cause project lockups or compilation errors. Store projects on a fast local drive.

---

### Step 3: Add a Compatible S7-1200 CPU
- **What to click or configure:**  
  1. In the Project tree (left pane), double-click **Add new device**.
  2. In the dialog, select the **Controllers** tile.
  3. Expand the folder tree: `SIMATIC S7-1200` $\rightarrow$ `CPU` $\rightarrow$ `CPU 1214C DC/DC/DC` $\rightarrow$ `6ES7 214-1AG40-0XB0`.
  4. In the version dropdown on the right side, select **V4.5** (or highest firmware compatible with your V17 installation).
  5. Leave the device name as `PLC_1` (or rename to `PLC_Boiler`).
  6. Click **OK**.
- **Why the step is necessary:**  
  Defines the virtual hardware platform, system memory limits, I/O mapping, and instruction set supported by the target controller.
- **Expected result:**  
  The **Device view** opens, displaying a graphical 2D rack layout with the CPU 1214C module seated in slot 1.
- **Common mistakes & troubleshooting:**  
  *Mistake:* Selecting an S7-1500 or S7-300 instead. The S7-1200 has specific memory structures and instruction timings modeled in this guide.

---

### Step 4: Configure the Device
- **What to click or configure:**  
  1. Double-click the CPU in the rack to highlight it and open the **Properties** tab in the bottom inspector window.
  2. Navigate to `General` $\rightarrow$ `PROFINET interface [X1]` $\rightarrow$ `Ethernet addresses`.
  3. Ensure **Set IP address in the project** is selected:
     - IP Address: `192.168.0.1`
     - Subnet mask: `255.255.255.0`
  4. In `System and clock memory`:
     - Enable **Enable the use of system memory byte** (assign to `%MB1`).
     - Enable **Enable the use of clock memory byte** (assign to `%MB2`).
- **Why the step is necessary:**  
  Assigns the virtual network address for PLCSIM communications and enables useful diagnostic and heartbeat clock bits.
- **Expected result:**  
  Hardware configuration is stored in the project database without syntax or address conflicts.
- **Common mistakes & troubleshooting:**  
  *Mistake:* Assigning clock memory to `%MB0`, which would overwrite our discrete alarm bit `%M0.0`. Ensure clock memory is `%MB2` or higher.

---

### Step 5: Open the PLC Programming Environment
- **What to click or configure:**  
  1. In the Project tree on the left, expand `PLC_1 [CPU 1214C DC/DC/DC]`.
  2. Expand the `Program blocks` folder.
- **Why the step is necessary:**  
  Navigates to the software block repository containing the executable code routines.
- **Expected result:**  
  You will see `Main [OB1]` listed under `Program blocks`.
- **Common mistakes & troubleshooting:**  
  *Mistake:* Looking under *PLC tags* for logic blocks. Blocks and tags have distinct project folders.

---

### Step 6: Open Main [OB1]
- **What to click or configure:**  
  Double-click `Main [OB1]`.
- **Why the step is necessary:**  
  `Main [OB1]` is the cyclical organization block that the CPU operating system calls repeatedly during runtime.
- **Expected result:**  
  The ladder editor opens in the center workspace showing empty Network 1 flanked by the left and right power rails.
- **Common mistakes & troubleshooting:**  
  *Mistake:* Creating a Function (FC) without calling it from OB1. Any code written in an uncalled block will never execute. Placing the core logic directly in OB1 guarantees execution.

---

### Step 7: Select Ladder Diagram (LAD)
- **What to click or configure:**  
  If OB1 was created with another language (like FBD or SCL), right-click `Main [OB1]` in the project tree, select **Properties**, go to **General** $\rightarrow$ **Language**, and ensure **LAD** (Ladder Logic) is selected.
- **Why the step is necessary:**  
  LAD is the standard graphical format required for this project and is the most easily interpretable format for interview and shop-floor demonstrations.
- **Expected result:**  
  The OB1 editor displays rung networks with power rails and the LAD instruction toolbar active above the canvas.
- **Common mistakes & troubleshooting:**  
  *Mistake:* S7-1200 OB1 defaults to LAD in English installations. If your language is German (KOP), the functionality is identical.

---

### Step 8: Create PLC Tags in the Tag Table
- **What to click or configure:**  
  1. In the Project tree under `PLC_1`, expand `PLC tags`.
  2. Double-click `Default tag table` (or `Add new tag table` $\rightarrow$ name it `Boiler_Tags`).
  3. Enter the following rows exactly:
     - Name: `Water_Level` | Data Type: `Real` | Address: `%MD10` | Comment: `Simulated drum level (0-100%)`
     - Name: `Low_Level_Threshold` | Data Type: `Real` | Address: `%MD14` | Comment: `Low-level trip setpoint (default 30.0%)`
     - Name: `Low_Level_Alarm` | Data Type: `Bool` | Address: `%M0.0` | Comment: `Low drum water level alarm active`
     - *(Extended)* `Water_Level_Input_Invalid` | Data Type: `Bool` | Address: `%M0.1` | Comment: `Level input out of range`
     - *(Extended)* `Threshold_Configuration_Invalid` | Data Type: `Bool` | Address: `%M0.2` | Comment: `Threshold out of range`
- **Why the step is necessary:**  
  Symbolic tags decouple raw memory addresses from business logic, ensuring readability and self-documenting code.
- **Expected result:**  
  All tags appear in black text with yellow tag symbols indicating valid declarations.
- **Common mistakes & troubleshooting:**  
  *Mistake:* Overlapping `%MD10` and `%MD12`. Remember: `Real` requires 4 bytes. The next address must be `%MD14`.

---

### Step 9: Add a REAL Comparison Instruction in Network 1
- **What to click or configure:**  
  1. Switch back to `Main [OB1]`.
  2. Click on the horizontal rung in **Network 1**.
  3. In the **Instructions** task card on the right pane, expand `Basic instructions` $\rightarrow$ `Comparator operations`.
  4. Locate the instruction **CMP <** (Less than) and drag-and-drop it onto the rung in Network 1 (or double-click it while the rung cursor is active).
- **Why the step is necessary:**  
  The comparator evaluates whether the incoming level has dropped below the safety limit.
- **Expected result:**  
  A comparison box appears on the rung with input pins `IN1`, `IN2`, and a data type selector at the bottom.
- **Common mistakes & troubleshooting:**  
  *Mistake:* Selecting `CMP <=` (Less than or equal) instead of `CMP <`. We specifically require strict less than.

---

### Step 10: Configure the Comparison Operands
- **What to click or configure:**  
  1. Click the bottom dropdown of the `CMP <` box (which may show `<Auto>` or `??`) and select **Real**.
  2. Click the text box above `IN1`, type `"Water_Level"`, and press `Enter` (or select it from the autocompletion popup).
  3. Click the text box above `IN2`, type `"Low_Level_Threshold"`, and press `Enter`.
- **Why the step is necessary:**  
  Defines the mathematical operation: $\text{Water\_Level} < \text{Low\_Level\_Threshold}$ using 32-bit floating-point precision.
- **Expected result:**  
  The box displays `CMP <` with `Real` at the bottom, `"Water_Level"` on top, and `"Low_Level_Threshold"` beneath it.
- **Common mistakes & troubleshooting:**  
  *Mistake:* Swapping `IN1` and `IN2`. Swapping them inverses the safety logic.

---

### Step 11: Connect the Comparison Result to the Alarm Logic
- **What to click or configure:**  
  1. In the favorite toolbar above the network (or from `Basic instructions` $\rightarrow$ `Bit logic operations`), click the standard assignment coil icon: `-( )`.
  2. Place it on the right side of the comparison box on the same rung.
  3. Click the red question marks `<???>` above the coil, type `"Low_Level_Alarm"`, and press `Enter`.
- **Why the step is necessary:**  
  Directs the Boolean result of the comparison into the `%M0.0` memory bit.
- **Expected result:**  
  A complete rung connecting the left rail through `CMP <` to the coil `-( Low_Level_Alarm )-` and terminating at the right rail.
- **Common mistakes & troubleshooting:**  
  *Mistake:* Accidentally choosing a SET coil `-( S )-`. Use the regular assignment coil `-( )-` to ensure non-latching auto-clearing behavior.

---

### Step 12: Compile the PLC Program
- **What to click or configure:**  
  1. In the Project tree, click `PLC_1` to highlight the CPU.
  2. Click the **Compile** icon on the top main toolbar (icon with two blue down arrows over a document) or press `Ctrl + B`.
  3. Alternatively, right-click `PLC_1` $\rightarrow$ **Compile** $\rightarrow$ **Hardware and software (only changes)**.
- **Why the step is necessary:**  
  Validates all tag addresses, block connections, syntax rules, and generates runnable machine code.
- **Expected result:**  
  The bottom **Info** $\rightarrow$ **Compile** tab displays:  
  `Compiling finished (errors: 0; warnings: 0)`.
- **Common mistakes & troubleshooting:**  
  *Mistake:* Compilation error: `Data type Real does not match...` Check that the comparison box is set to `Real` and both tags are declared as `Real`.

---

### Step 13: Resolve Compilation Errors
- **What to click or configure:**  
  If the compile tab shows red error icons:
  1. Double-click the error message line in the compile output window.
  2. TIA Portal navigates directly to the offending block or tag definition.
  3. Correct the tag spelling or data type mismatch as indicated.
  4. Recompile with `Ctrl + B`.
- **Why the step is necessary:**  
  A project cannot be downloaded to a physical PLC or PLCSIM simulator if any compiler errors exist.
- **Expected result:**  
  Clean compilation banner with 0 errors.

---

### Step 14: Configure Simulation Using Siemens S7-PLCSIM
- **What to click or configure:**  
  1. Highlight `PLC_1` in the Project tree.
  2. Click the **Start simulation** icon on the main toolbar (icon showing a computer screen with two gears) or press `Ctrl + Shift + X`.
  3. A prompt appears: *Starting simulation will disable all other online interfaces.* Click **OK**.
- **Why the step is necessary:**  
  Launches the S7-PLCSIM V17 emulator instance and establishes a virtual network link.
- **Expected result:**  
  The S7-PLCSIM window opens displaying a virtual CPU rack. In TIA Portal, the **Extended download to device** dialog appears automatically.
- **Common mistakes & troubleshooting:**  
  *Mistake:* "S7-PLCSIM is not installed" prompt. Ensure S7-PLCSIM V17 is installed alongside TIA Portal V17. If not present, install from your Siemens installation media.

---

### Step 15: Download/Load the Program into the Simulator
- **What to click or configure:**  
  1. In the **Extended download to device** dialog:
     - PG/PC interface type: `PN/IE`
     - PG/PC interface: `Siemens PLCSIM Virtual Ethernet Adapter` (or `PLCSIM`)
     - Connection to interface/subnet: `PN/IE_1`
  2. Click **Start search**.
  3. When the simulated CPU appears in the target devices list (IP `192.168.0.1`), select it and click **Load**.
  4. In the **Load preview** dialog, verify checkboxes and click **Load**.
  5. In the **Load results** dialog, under *Action*, select **Start module** (to transition CPU to RUN).
  6. Click **Finish**.
- **Why the step is necessary:**  
  Transfers the compiled hardware parameters, DBs, and OB1 logic into the virtual CPU's load and work memory.
- **Expected result:**  
  The simulated CPU's virtual `RUN/STOP` LED turns solid **green** (`RUN`).
- **Common mistakes & troubleshooting:**  
  *Mistake:* Leaving CPU in `STOP` mode. If the LED is orange, click the **RUN** button on the PLCSIM compact panel.

---

### Step 16: Enter Test Values for Water_Level via Watch Table
- **What to click or configure:**  
  1. In the Project tree under `PLC_1`, expand `Watch and force tables`.
  2. Double-click `Add new watch table` $\rightarrow$ name it `Watch_Table_Boiler_Level`.
  3. Add the following rows:
     - Row 1: `"Water_Level"` | Display format: `Floating point`
     - Row 2: `"Low_Level_Threshold"` | Display format: `Floating point`
     - Row 3: `"Low_Level_Alarm"` | Display format: `Boolean`
  4. In the **Modify value** column for `"Low_Level_Threshold"`, type `30.0`.
  5. In the **Modify value** column for `"Water_Level"`, type `60.0`.
  6. Click the **Modify all selected values now** button (icon with two lightning bolts / flashes: `⚡⚡`).
- **Why the step is necessary:**  
  Because physical transmitters are absent, the Watch Table allows live injection of floating-point values directly into PLC RAM.
- **Expected result:**  
  The **Monitor value** column updates to show `60.0` for `Water_Level` and `30.0` for `Low_Level_Threshold`.
- **Common mistakes & troubleshooting:**  
  *Mistake:* Entering an integer (`60`) without a decimal point. TIA Portal accepts `60` and converts it, but typing `60.0` confirms floating-point intent.

---

### Step 17: Monitor the Program Online
- **What to click or configure:**  
  1. Click the **Monitoring on/off** icon (glasses with green play triangle `👓▶`) on the Watch Table toolbar.
  2. Double-click `Main [OB1]` and click the **Monitoring on/off** icon in the OB1 toolbar.
- **Why the step is necessary:**  
  Enables real-time animated visual feedback of power flow and variable values directly on the Ladder rungs.
- **Expected result:**  
  The ladder rungs turn green/dashed. Live floating-point numbers appear above the operand tags.
- **Common mistakes & troubleshooting:**  
  *Mistake:* Forgetting to turn on monitoring. Without clicking `👓▶`, values remain static and will not reflect simulated state changes.

---

### Step 18: Observe Low_Level_Alarm State Transitions
- **What to click or configure:**  
  1. In the Watch Table, set `"Water_Level"` modify value to `20.0`.
  2. Click **Modify now** (`⚡`).
  3. Observe Network 1 in OB1 and the Watch Table monitor column.
- **Why the step is necessary:**  
  Verifies that dropping the level below the threshold trips the alarm.
- **Expected result:**  
  - Comparison $20.0 < 30.0$ evaluates to `TRUE`.
  - The rung in OB1 turns solid green from left to right.
  - Coil `-( Low_Level_Alarm )-` illuminates green.
  - Watch Table displays `"Low_Level_Alarm"` monitor value as `TRUE` (`1`).

---

### Step 19: Test Normal, Boundary, and Recovery Conditions
- **What to click or configure:**  
  Execute the full test sequence from the test plan:
  1. Test Case 3: Set `Water_Level = 30.0`. Modify now $\rightarrow$ verify Alarm is `FALSE`.
  2. Test Case 4: Set `Water_Level = 29.9`. Modify now $\rightarrow$ verify Alarm is `TRUE`.
  3. Test Case 7 (Recovery): Set `Water_Level = 45.0`. Modify now $\rightarrow$ verify Alarm automatically resets to `FALSE`.
- **Why the step is necessary:**  
  Proves that edge cases and automatic de-energization work correctly without residual latching.
- **Expected result:**  
  All 10 test cases match their mathematical predictions.

---

### Step 20: Save the Project
- **What to click or configure:**  
  1. Click the **Save project** floppy disk icon on the main toolbar (or press `Ctrl + S`).
  2. In the menu, select **Project** $\rightarrow$ **Archive...** to create a compressed single-file `.zap17` backup if needed.
- **Why the step is necessary:**  
  Persists all tag definitions, network configurations, watch tables, and device settings to disk.
- **Expected result:**  
  Status bar confirms `Project saved successfully`.
- **Common mistakes & troubleshooting:**  
  *Mistake:* Closing TIA Portal without saving or archiving. Always archive `.zap17` before submitting projects for engineering review.
