Add-Type -AssemblyName System.Drawing

$width = 1100
$height = 850
$bmp = New-Object System.Drawing.Bitmap($width, $height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

# Colors
$cBg = [System.Drawing.Color]::FromArgb(15, 23, 42)
$cHeader = [System.Drawing.Color]::FromArgb(2, 132, 199)
$cCardBg = [System.Drawing.Color]::FromArgb(30, 41, 59)
$cPlcBg = [System.Drawing.Color]::FromArgb(12, 35, 64)
$cTextWhite = [System.Drawing.Color]::FromArgb(255, 255, 255)
$cTextCyan = [System.Drawing.Color]::FromArgb(56, 189, 248)
$cTextAmber = [System.Drawing.Color]::FromArgb(251, 191, 36)
$cTextRed = [System.Drawing.Color]::FromArgb(248, 113, 113)
$cTextGray = [System.Drawing.Color]::FromArgb(148, 163, 184)
$cBorderSlate = [System.Drawing.Color]::FromArgb(71, 85, 105)
$cBorderCyan = [System.Drawing.Color]::FromArgb(2, 132, 199)
$cBorderAmber = [System.Drawing.Color]::FromArgb(217, 119, 6)
$cBorderRed = [System.Drawing.Color]::FromArgb(239, 68, 68)
$cFutureBg = [System.Drawing.Color]::FromArgb(25, 14, 43)
$cPurple = [System.Drawing.Color]::FromArgb(168, 85, 247)

# Background
$g.Clear($cBg)

# Fonts
$fontTitle = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$fontSub = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
$fontCardTitle = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$fontBoxTitle = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fontCode = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Bold)
$fontCodeSmall = New-Object System.Drawing.Font("Consolas", 8, [System.Drawing.FontStyle]::Bold)
$fontCodeLarge = New-Object System.Drawing.Font("Consolas", 18, [System.Drawing.FontStyle]::Bold)
$fontSmall = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$fontBadge = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)

# Pens & Brushes
$penBorderCyan = New-Object System.Drawing.Pen($cBorderCyan, 2)
$penBorderSlate = New-Object System.Drawing.Pen($cBorderSlate, 1.5)
$penBorderAmber = New-Object System.Drawing.Pen($cBorderAmber, 2)
$penBorderRed = New-Object System.Drawing.Pen($cBorderRed, 2)
$penArrowCyan = New-Object System.Drawing.Pen($cTextCyan, 2.5)
$penArrowCyan.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
$penArrowAmber = New-Object System.Drawing.Pen($cTextAmber, 2.5)
$penArrowAmber.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
$penArrowRed = New-Object System.Drawing.Pen($cTextRed, 2.5)
$penArrowRed.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
$penArrowPurple = New-Object System.Drawing.Pen($cPurple, 2)
$penArrowPurple.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
$penArrowPurple.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor

# StringFormat Center
$sfCenter = New-Object System.Drawing.StringFormat
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

# Header Banner
$g.FillRectangle((New-Object System.Drawing.SolidBrush($cHeader)), 30, 25, 1040, 75)
$g.DrawString("BOILER PROCESS MONITORING & CONTROL SYSTEM", $fontTitle, (New-Object System.Drawing.SolidBrush($cTextWhite)), 50, 35)
$g.DrawString("Educational Siemens TIA Portal V17 & S7-PLCSIM Architecture | SIMATIC S7-1200 Ladder Diagram", $fontSub, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(186, 230, 253))), 50, 68)

# Simulation Badge
$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(12, 74, 110))), 910, 42, 140, 38)
$g.DrawRectangle($penBorderCyan, 910, 42, 140, 38)
$g.DrawString("SIMULATION ONLY", $fontBadge, (New-Object System.Drawing.SolidBrush($cTextCyan)), (New-Object System.Drawing.RectangleF(910, 42, 140, 38)), $sfCenter)

# --- 1. SIMULATION STIMULUS (LEFT) ---
$g.FillRectangle((New-Object System.Drawing.SolidBrush($cCardBg)), 30, 125, 280, 420)
$g.DrawRectangle($penBorderSlate, 30, 125, 280, 420)
$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(51, 65, 85))), 30, 125, 280, 40)
$g.DrawString("1. SIMULATION STIMULUS", $fontCardTitle, (New-Object System.Drawing.SolidBrush($cTextGray)), (New-Object System.Drawing.RectangleF(30, 125, 280, 40)), $sfCenter)

# Input Box: Water_Level
$g.FillRectangle((New-Object System.Drawing.SolidBrush($cBg)), 50, 195, 240, 110)
$g.DrawRectangle($penBorderCyan, 50, 195, 240, 110)
$g.DrawString("Simulated Water-Level Input", $fontBoxTitle, (New-Object System.Drawing.SolidBrush($cTextCyan)), (New-Object System.Drawing.RectangleF(50, 205, 240, 22)), $sfCenter)
$g.DrawString("TIA Portal Watch Table / PLCSIM", $fontSmall, (New-Object System.Drawing.SolidBrush($cTextGray)), (New-Object System.Drawing.RectangleF(50, 230, 240, 18)), $sfCenter)
$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 23, 42))), 70, 255, 200, 32)
$g.DrawRectangle($penBorderSlate, 70, 255, 200, 32)
$g.DrawString("Modify: 0.0 - 100.0%", $fontCode, (New-Object System.Drawing.SolidBrush($cTextCyan)), (New-Object System.Drawing.RectangleF(70, 255, 200, 32)), $sfCenter)

# Input Box: Low Threshold
$g.FillRectangle((New-Object System.Drawing.SolidBrush($cBg)), 50, 340, 240, 110)
$g.DrawRectangle($penBorderAmber, 50, 340, 240, 110)
$g.DrawString("Configurable Low Threshold", $fontBoxTitle, (New-Object System.Drawing.SolidBrush($cTextAmber)), (New-Object System.Drawing.RectangleF(50, 350, 240, 22)), $sfCenter)
$g.DrawString("Operator Setpoint Input", $fontSmall, (New-Object System.Drawing.SolidBrush($cTextGray)), (New-Object System.Drawing.RectangleF(50, 375, 240, 18)), $sfCenter)
$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 23, 42))), 70, 400, 200, 32)
$g.DrawRectangle($penBorderSlate, 70, 400, 200, 32)
$g.DrawString("Default: 30.0%", $fontCode, (New-Object System.Drawing.SolidBrush($cTextAmber)), (New-Object System.Drawing.RectangleF(70, 400, 200, 32)), $sfCenter)

# Boundary note
$g.DrawString("No Physical Level Transmitter`nManual Value Modification in RAM", $fontSmall, (New-Object System.Drawing.SolidBrush($cTextGray)), (New-Object System.Drawing.RectangleF(50, 480, 240, 45)), $sfCenter)

# Connectors Left to Center
$g.DrawLine($penArrowCyan, 290, 250, 370, 250)
$g.DrawLine($penArrowAmber, 290, 395, 370, 395)

# --- 2. S7-1200 PLC RUNTIME [OB1] (CENTER) ---
$g.FillRectangle((New-Object System.Drawing.SolidBrush($cPlcBg)), 370, 125, 370, 420)
$g.DrawRectangle($penBorderCyan, 370, 125, 370, 420)
$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(3, 105, 161))), 370, 125, 370, 40)
$g.DrawString("2. SIMATIC S7-1200 PLC RUNTIME [OB1]", $fontCardTitle, (New-Object System.Drawing.SolidBrush($cTextWhite)), (New-Object System.Drawing.RectangleF(370, 125, 370, 40)), $sfCenter)

# PLC Tag: Water_Level
$g.FillRectangle((New-Object System.Drawing.SolidBrush($cBg)), 390, 215, 130, 70)
$g.DrawRectangle($penBorderCyan, 390, 215, 130, 70)
$g.DrawString("PLC Tag", $fontSmall, (New-Object System.Drawing.SolidBrush($cTextWhite)), (New-Object System.Drawing.RectangleF(390, 220, 130, 16)), $sfCenter)
$g.DrawString("""Water_Level""", $fontCode, (New-Object System.Drawing.SolidBrush($cTextCyan)), (New-Object System.Drawing.RectangleF(390, 238, 130, 20)), $sfCenter)
$g.DrawString("%MD10 | REAL", $fontSmall, (New-Object System.Drawing.SolidBrush($cTextGray)), (New-Object System.Drawing.RectangleF(390, 260, 130, 16)), $sfCenter)

# PLC Tag: Low_Level_Threshold
$g.FillRectangle((New-Object System.Drawing.SolidBrush($cBg)), 390, 360, 130, 70)
$g.DrawRectangle($penBorderAmber, 390, 360, 130, 70)
$g.DrawString("PLC Tag", $fontSmall, (New-Object System.Drawing.SolidBrush($cTextWhite)), (New-Object System.Drawing.RectangleF(390, 365, 130, 16)), $sfCenter)
$g.DrawString("""Low_Level_Threshold""", $fontCodeSmall, (New-Object System.Drawing.SolidBrush($cTextAmber)), (New-Object System.Drawing.RectangleF(390, 383, 130, 20)), $sfCenter)
$g.DrawString("%MD14 | REAL", $fontSmall, (New-Object System.Drawing.SolidBrush($cTextGray)), (New-Object System.Drawing.RectangleF(390, 405, 130, 16)), $sfCenter)

# CMP < Instruction Box
$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(7, 89, 133))), 560, 250, 160, 165)
$g.DrawRectangle($penBorderCyan, 560, 250, 160, 165)
$g.DrawString("CMP <", $fontCardTitle, (New-Object System.Drawing.SolidBrush($cTextWhite)), (New-Object System.Drawing.RectangleF(560, 255, 160, 22)), $sfCenter)
$g.DrawString("REAL Comparison", $fontSmall, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(186, 230, 253))), (New-Object System.Drawing.RectangleF(560, 277, 160, 18)), $sfCenter)
$g.DrawLine($penBorderCyan, 560, 298, 720, 298)
$g.DrawString("IN1: Water_Level", $fontCode, (New-Object System.Drawing.SolidBrush($cTextCyan)), 570, 310)
$g.DrawString("IN2: Threshold", $fontCode, (New-Object System.Drawing.SolidBrush($cTextAmber)), 570, 345)
$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(8, 47, 73))), 575, 378, 130, 25)
$g.DrawString("Condition: IN1 < IN2", $fontSmall, (New-Object System.Drawing.SolidBrush($cTextCyan)), (New-Object System.Drawing.RectangleF(575, 378, 130, 25)), $sfCenter)

# Internal Connectors
$g.DrawLine($penBorderCyan, 520, 250, 540, 250)
$g.DrawLine($penBorderCyan, 540, 250, 540, 320)
$g.DrawLine($penBorderCyan, 540, 320, 560, 320)

$g.DrawLine($penBorderAmber, 520, 395, 540, 395)
$g.DrawLine($penBorderAmber, 540, 395, 540, 355)
$g.DrawLine($penBorderAmber, 540, 355, 560, 355)

# Cyclic Scan note
$g.DrawString("Cyclic Scan Cycle: Read Inputs -> Execute OB1 -> Update Outputs (~1-5 ms)", $fontSmall, (New-Object System.Drawing.SolidBrush($cTextCyan)), (New-Object System.Drawing.RectangleF(380, 485, 350, 35)), $sfCenter)

# Connector Center to Right
$g.DrawLine($penArrowCyan, 720, 335, 800, 335)
$g.DrawString("RLO Flow", $fontSmall, (New-Object System.Drawing.SolidBrush($cTextCyan)), 735, 315)

# --- 3. PROCESS ALARM OUTPUT (RIGHT) ---
$g.FillRectangle((New-Object System.Drawing.SolidBrush($cCardBg)), 800, 125, 270, 420)
$g.DrawRectangle($penBorderSlate, 800, 125, 270, 420)
$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(51, 65, 85))), 800, 125, 270, 40)
$g.DrawString("3. PROCESS ALARM OUTPUT", $fontCardTitle, (New-Object System.Drawing.SolidBrush($cTextGray)), (New-Object System.Drawing.RectangleF(800, 125, 270, 40)), $sfCenter)

# Ladder Assignment Coil
$g.FillRectangle((New-Object System.Drawing.SolidBrush($cBg)), 825, 215, 220, 95)
$g.DrawRectangle($penBorderRed, 825, 215, 220, 95)
$g.DrawString("Ladder Output Coil", $fontBoxTitle, (New-Object System.Drawing.SolidBrush($cTextRed)), (New-Object System.Drawing.RectangleF(825, 225, 220, 20)), $sfCenter)
$g.DrawString("-(  )-", $fontCodeLarge, (New-Object System.Drawing.SolidBrush($cTextWhite)), (New-Object System.Drawing.RectangleF(825, 248, 220, 30)), $sfCenter)
$g.DrawString("Non-Latching Assignment", $fontSmall, (New-Object System.Drawing.SolidBrush($cTextGray)), (New-Object System.Drawing.RectangleF(825, 282, 220, 20)), $sfCenter)

# Connector Coil to Tag
$g.DrawLine($penArrowRed, 935, 310, 935, 340)

# Alarm Tag Box
$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(153, 27, 27))), 825, 340, 220, 110)
$g.DrawRectangle($penBorderRed, 825, 340, 220, 110)
$g.DrawString("PLC Boolean Alarm Tag", $fontSmall, (New-Object System.Drawing.SolidBrush($cTextWhite)), (New-Object System.Drawing.RectangleF(825, 348, 220, 18)), $sfCenter)
$g.DrawString("""Low_Level_Alarm""", $fontCode, (New-Object System.Drawing.SolidBrush($cTextAmber)), (New-Object System.Drawing.RectangleF(825, 370, 220, 22)), $sfCenter)
$g.DrawString("Address: %M0.0 | BOOL", $fontSmall, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(254, 202, 202))), (New-Object System.Drawing.RectangleF(825, 395, 220, 18)), $sfCenter)
$g.DrawString("TRUE = ACTIVE | FALSE = CLEAR", $fontBadge, (New-Object System.Drawing.SolidBrush($cTextWhite)), (New-Object System.Drawing.RectangleF(825, 418, 220, 20)), $sfCenter)

# Non-latching Note
$g.DrawString("Auto-Reset Behavior:`nAlarm resets automatically when`nWater_Level >= Low_Level_Threshold", $fontSmall, (New-Object System.Drawing.SolidBrush($cTextGray)), (New-Object System.Drawing.RectangleF(815, 475, 240, 50)), $sfCenter)

# --- 4. FUTURE EXTENSIONS & SCADA INTEGRATION (BOTTOM) ---
$g.FillRectangle((New-Object System.Drawing.SolidBrush($cFutureBg)), 30, 575, 1040, 245)
$penDashedPurple = New-Object System.Drawing.Pen($cPurple, 2)
$penDashedPurple.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
$g.DrawRectangle($penDashedPurple, 30, 575, 1040, 245)

$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(59, 7, 100))), 30, 575, 1040, 36)
$g.DrawString("4. OPTIONAL FUTURE EXTENSIONS & INDUSTRIAL INTEGRATION (CONCEPTUAL ROADMAP)", $fontCardTitle, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(216, 180, 254))), (New-Object System.Drawing.RectangleF(30, 575, 1040, 36)), $sfCenter)

# Extension A: Validation Tier
$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 16, 53))), 50, 625, 310, 180)
$g.DrawRectangle((New-Object System.Drawing.Pen($cPurple, 1)), 50, 625, 310, 180)
$g.DrawString("A. Input Validation Tier", $fontBoxTitle, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(233, 213, 255))), 65, 638)
$g.DrawString("Boundary Diagnostics (0.0 - 100.0%):`n- Water_Level_Input_Invalid (%M0.1)`n- Threshold_Configuration_Invalid (%M0.2)`n`nPrevents undetected sensor clipping`nand invalid configuration entries.", $fontSmall, (New-Object System.Drawing.SolidBrush($cTextGray)), 65, 670)

# Extension B: HMI / SCADA Integration
$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 16, 53))), 395, 625, 310, 180)
$g.DrawRectangle((New-Object System.Drawing.Pen($cPurple, 1)), 395, 625, 310, 180)
$g.DrawString("B. HMI / SCADA Visualization", $fontBoxTitle, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(233, 213, 255))), 410, 638)
$g.DrawString("PROFINET / S7 Communication:`n- Real-time Graphic Drum Level Gauge`n- Flashing High-Priority Alarm Banner`n- Setpoint Input Field with Security Roles`n- Historical Trend Logging (WinCC / SCADA)", $fontSmall, (New-Object System.Drawing.SolidBrush($cTextGray)), 410, 670)

# Extension C: Feedwater Control
$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 16, 53))), 740, 625, 310, 180)
$g.DrawRectangle((New-Object System.Drawing.Pen($cPurple, 1)), 740, 625, 310, 180)
$g.DrawString("C. Closed-Loop Feedwater Control", $fontBoxTitle, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(233, 213, 255))), 755, 638)
$g.DrawString("Pump Sequencing & Burner Interlocks:`n- On/Off or Modulating PID Valve Control`n- Pump Run Feedback & Fail-to-Start Alarm`n- Low-Low Level Burner Cutoff (SIL/SIS)`n`n(Requires physical SIL safety certification)", $fontSmall, (New-Object System.Drawing.SolidBrush($cTextGray)), 755, 670)

# Arrow PLC to Extensions
$g.DrawLine($penArrowPurple, 555, 545, 555, 575)

# Save Bitmap
$outputPath = "d:\PROJECT\Boiler_Process_Monitoring\diagrams\System_Architecture.png"
$bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
Write-Output "Successfully generated System_Architecture.png ($width x $height)"
