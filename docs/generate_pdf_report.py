"""
Pure Python PDF Generator for Project Report
Generates a valid, multi-page PDF document conforming to Adobe PDF 1.4 specification
without requiring third-party libraries (reportlab, fpdf, etc.).
"""

import os
import sys

def create_pdf(output_path):
    # PDF Object management
    objects = []
    def add_object(content):
        objects.append(content)
        return len(objects) # 1-based obj id

    # Pages definition
    pages_text = [
        # PAGE 1: TITLE & COVER PAGE
        [
            ("BT", "/F2 24 Tf 50 720 Td (BOILER PROCESS MONITORING & CONTROL SYSTEM) Tj ET"),
            ("BT", "/F1 14 Tf 50 690 Td (Using Siemens TIA Portal V17 and Ladder Logic) Tj ET"),
            ("BT", "/F1 11 Tf 50 660 Td (Engineering Project Dossier & Educational Reference Model) Tj ET"),
            ("BT", "/F2 12 Tf 50 580 Td (PROJECT METADATA) Tj ET"),
            ("BT", "/F1 10 Tf 50 555 Td (Platform: Siemens TIA Portal V17 | SIMATIC S7-1200 | S7-PLCSIM V17) Tj ET"),
            ("BT", "/F1 10 Tf 50 535 Td (Language: Ladder Diagram [LAD / KOP] - IEC 61131-3) Tj ET"),
            ("BT", "/F1 10 Tf 50 515 Td (Target Controller: CPU 1214C DC/DC/DC - 6ES7 214-1AG40-0XB0 - FW V4.5) Tj ET"),
            ("BT", "/F1 10 Tf 50 495 Td (Scope: Deterministic Boiler Drum Level Monitoring & Alarm Annunciation) Tj ET"),
            ("BT", "/F1 10 Tf 50 475 Td (Status: Complete Engineering Specification & Simulation Model) Tj ET"),
            ("BT", "/F2 12 Tf 50 400 Td (EXECUTIVE ABSTRACT) Tj ET"),
            ("BT", "/F1 10 Tf 50 375 Td (This project establishes an educational, simulated PLC-based boiler drum water-level) Tj ET"),
            ("BT", "/F1 10 Tf 50 360 Td (monitoring and alarm system engineered in Siemens TIA Portal V17.) Tj ET"),
            ("BT", "/F1 10 Tf 50 340 Td (A simulated drum water level variable [Water_Level, REAL, 0.0% to 100.0%] is cyclically) Tj ET"),
            ("BT", "/F1 10 Tf 50 325 Td (compared against a configurable low-level trip threshold [Low_Level_Threshold, REAL, 30.0%]) Tj ET"),
            ("BT", "/F1 10 Tf 50 310 Td (using a Siemens CMP < comparator instruction in Main [OB1].) Tj ET"),
            ("BT", "/F1 10 Tf 50 290 Td (When the water level drops strictly below the threshold, a non-latching Boolean alarm) Tj ET"),
            ("BT", "/F1 10 Tf 50 275 Td ([Low_Level_Alarm, BOOL] activates. The alarm automatically clears upon level recovery.) Tj ET"),
            ("BT", "/F1 10 Tf 50 255 Td (A supervisory diagnostic tier flags out-of-range sensor and setpoint values. The full) Tj ET"),
            ("BT", "/F1 10 Tf 50 240 Td (design is verified through a 10-point test matrix in S7-PLCSIM with Watch Tables.) Tj ET"),
            ("BT", "/F1 9 Tf 50 80 Td (Document Page 1 | Siemens TIA Portal V17 Reference Specification) Tj ET"),
        ],
        # PAGE 2: TAG ARCHITECTURE & COMPARISON LOGIC
        [
            ("BT", "/F2 16 Tf 50 740 Td (1. PLC TAG ARCHITECTURE & MEMORY MAPPING) Tj ET"),
            ("BT", "/F1 10 Tf 50 715 Td (The controller utilizes symbolic addressing mapped to deterministic S7-1200 memory offsets:) Tj ET"),
            ("BT", "/F2 10 Tf 50 685 Td (Tag Name             Address   Type    Initial Value   Functional Purpose) Tj ET"),
            ("BT", "/F1 9 Tf 50 665 Td (Water_Level          %MD10     Real    60.0            Simulated drum water level [0.0% - 100.0%]) Tj ET"),
            ("BT", "/F1 9 Tf 50 645 Td (Low_Level_Threshold %MD14     Real    30.0            Configurable low water alarm trip setpoint) Tj ET"),
            ("BT", "/F1 9 Tf 50 625 Td (Low_Level_Alarm     %M0.0     Bool    FALSE           Discrete low water alarm output indicator) Tj ET"),
            ("BT", "/F1 9 Tf 50 605 Td (Water_Level_Invalid %M0.1     Bool    FALSE           [Extended] Diagnostic flag for level out-of-bounds) Tj ET"),
            ("BT", "/F1 9 Tf 50 585 Td (Threshold_Invalid   %M0.2     Bool    FALSE           [Extended] Diagnostic flag for threshold out-of-bounds) Tj ET"),
            ("BT", "/F2 11 Tf 50 545 Td (Critical Memory Rule: 4-Byte Allocation for REAL Variables) Tj ET"),
            ("BT", "/F1 10 Tf 50 525 Td (A REAL data type occupies 32 bits [4 contiguous bytes] conforming to IEEE 754.) Tj ET"),
            ("BT", "/F1 10 Tf 50 510 Td (%MD10 spans bytes %MB10, %MB11, %MB12, %MB13. The next available address is %MD14.) Tj ET"),
            ("BT", "/F1 10 Tf 50 495 Td (Allocating %MD12 would overlap bytes 12 and 13, causing severe data corruption.) Tj ET"),
            ("BT", "/F2 16 Tf 50 450 Td (2. LADDER DIAGRAM [LAD] NETWORK SPECIFICATION) Tj ET"),
            ("BT", "/F2 11 Tf 50 425 Td (Network 1: Low Water-Level Detection & Alarm Assignment) Tj ET"),
            ("BT", "/F1 10 Tf 50 405 Td (Ladder Rung Representation:) Tj ET"),
            ("BT", "/F1 9 Tf 50 380 Td (  Left Rail ----------------[ CMP < ]-------------------( )---------------- Right Rail) Tj ET"),
            ("BT", "/F1 9 Tf 50 365 Td (                            |  Real  |             Low_Level_Alarm) Tj ET"),
            ("BT", "/F1 9 Tf 50 350 Td (    Water_Level ---------->| IN1    |                 %M0.0) Tj ET"),
            ("BT", "/F1 9 Tf 50 335 Td (    Low_Level_Threshold -->| IN2    |) Tj ET"),
            ("BT", "/F1 10 Tf 50 300 Td (Evaluation Mechanics:) Tj ET"),
            ("BT", "/F1 10 Tf 50 280 Td (- When Water_Level < Low_Level_Threshold evaluates to TRUE, power flow passes to coil.) Tj ET"),
            ("BT", "/F1 10 Tf 50 265 Td (- The coil -( )- writes 1 [TRUE] to %M0.0.) Tj ET"),
            ("BT", "/F1 10 Tf 50 250 Td (- When Water_Level >= Low_Level_Threshold evaluates to FALSE, power flow is interrupted.) Tj ET"),
            ("BT", "/F1 10 Tf 50 235 Td (- The standard coil -( )- writes 0 [FALSE] to %M0.0, automatically clearing the alarm.) Tj ET"),
            ("BT", "/F1 9 Tf 50 80 Td (Document Page 2 | Siemens TIA Portal V17 Reference Specification) Tj ET"),
        ],
        # PAGE 3: VERIFICATION TEST PLAN & INTERVIEW DEFENSE
        [
            ("BT", "/F2 16 Tf 50 740 Td (3. VERIFICATION TEST MATRIX & RESULTS) Tj ET"),
            ("BT", "/F1 10 Tf 50 715 Td (The logic is verified across 10 deterministic test cases in Siemens S7-PLCSIM:) Tj ET"),
            ("BT", "/F2 9 Tf 50 685 Td (Test ID   Water_Level   Threshold   Logic Expression         Expected Alarm   Behavior Category) Tj ET"),
            ("BT", "/F1 9 Tf 50 665 Td (TC-01     80.0%         30.0%       80.0 < 30.0 -> FALSE     FALSE            High Normal Operating Level) Tj ET"),
            ("BT", "/F1 9 Tf 50 645 Td (TC-02     60.0%         30.0%       60.0 < 30.0 -> FALSE     FALSE            Mid-Range Operating Level) Tj ET"),
            ("BT", "/F1 9 Tf 50 625 Td (TC-03     30.0%         30.0%       30.0 < 30.0 -> FALSE     FALSE            Boundary: Level == Threshold) Tj ET"),
            ("BT", "/F1 9 Tf 50 605 Td (TC-04     29.9%         30.0%       29.9 < 30.0 -> TRUE      TRUE             Boundary: 0.1% Sub-threshold) Tj ET"),
            ("BT", "/F1 9 Tf 50 585 Td (TC-05     20.0%         30.0%       20.0 < 30.0 -> TRUE      TRUE             Standard Low-Level Trip) Tj ET"),
            ("BT", "/F1 9 Tf 50 565 Td (TC-06      0.0%         30.0%        0.0 < 30.0 -> TRUE      TRUE             Dry Drum Condition) Tj ET"),
            ("BT", "/F1 9 Tf 50 545 Td (TC-07     45.0%         30.0%       45.0 < 30.0 -> FALSE     FALSE            Recovery Test [Auto-clears]) Tj ET"),
            ("BT", "/F1 9 Tf 50 525 Td (TC-08     25.0%         40.0%       25.0 < 40.0 -> TRUE      TRUE             Dynamic Setpoint Adjustment) Tj ET"),
            ("BT", "/F1 9 Tf 50 505 Td (TC-09     50.0%         40.0%       50.0 < 40.0 -> FALSE     FALSE            Dynamic Setpoint Safe Level) Tj ET"),
            ("BT", "/F1 9 Tf 50 485 Td (TC-10     20.0%         20.0%       20.0 < 20.0 -> FALSE     FALSE            Boundary: Setpoint == Level) Tj ET"),
            ("BT", "/F2 16 Tf 50 435 Td (4. INTERVIEW HIGHLIGHTS & RESUME INTEGRITY) Tj ET"),
            ("BT", "/F2 10 Tf 50 410 Td (Key Interview Defense Points:) Tj ET"),
            ("BT", "/F1 9 Tf 50 390 Td (1. Why REAL instead of INT? Analog process values are continuous decimals. INT would) Tj ET"),
            ("BT", "/F1 9 Tf 50 375 Td (   truncate 29.9% to 29 or 30, eliminating sub-percentage precision near critical limits.) Tj ET"),
            ("BT", "/F1 9 Tf 50 355 Td (2. Equal-to-threshold behavior: CMP < strictly evaluates inequality. 30.0 < 30.0 is FALSE.) Tj ET"),
            ("BT", "/F1 9 Tf 50 335 Td (3. Non-latching vs Latching: Advisory alarms automatically clear when condition clears.) Tj ET"),
            ("BT", "/F1 9 Tf 50 320 Td (   Emergency shutdown trips [which cut fuel] must latch until manual operator reset.) Tj ET"),
            ("BT", "/F1 9 Tf 50 300 Td (4. Scope & Honesty: This project is an educational PLC simulation. It does not claim) Tj ET"),
            ("BT", "/F1 9 Tf 50 285 Td (   physical sensor wiring or certified safety-instrumented system [SIS] deployment.) Tj ET"),
            ("BT", "/F1 9 Tf 50 80 Td (Document Page 3 | Siemens TIA Portal V17 Reference Specification) Tj ET"),
        ]
    ]

    # Generate streams for each page
    stream_objs = []
    for page in pages_text:
        content_lines = []
        for line in page:
            content_lines.append(f"{line[0]} {line[1]}")
        stream_body = "\n".join(content_lines)
        stream_bytes = stream_body.encode('latin1')
        stream_objs.append((len(stream_bytes), stream_bytes))

    # Construct objects
    # 1: Catalog
    # 2: Outlines
    # 3: Pages
    # 4: Font Helvetica
    # 5: Font Helvetica-Bold
    # For each page:
    # Page obj, Content stream obj

    catalog_id = 1
    outlines_id = 2
    pages_id = 3
    font1_id = 4
    font2_id = 5

    page_obj_ids = []
    content_obj_ids = []

    current_id = 5
    for _ in pages_text:
        current_id += 1
        page_obj_ids.append(current_id)
        current_id += 1
        content_obj_ids.append(current_id)

    # Catalog
    obj1 = f"{catalog_id} 0 obj\n<< /Type /Catalog /Pages {pages_id} 0 R /Outlines {outlines_id} 0 R >>\nendobj\n"
    # Outlines
    obj2 = f"{outlines_id} 0 obj\n<< /Type /Outlines /Count 0 >>\nendobj\n"
    # Pages
    kids_str = " ".join([f"{pid} 0 R" for pid in page_obj_ids])
    obj3 = f"{pages_id} 0 obj\n<< /Type /Pages /Kids [{kids_str}] /Count {len(page_obj_ids)} >>\nendobj\n"
    # Fonts
    obj4 = f"{font1_id} 0 obj\n<< /Type /Font /Subtype /Type1 /Name /F1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>\nendobj\n"
    obj5 = f"{font2_id} 0 obj\n<< /Type /Font /Subtype /Type1 /Name /F2 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>\nendobj\n"

    all_objs = [obj1, obj2, obj3, obj4, obj5]

    for idx, pid in enumerate(page_obj_ids):
        cid = content_obj_ids[idx]
        p_obj = (f"{pid} 0 obj\n<< /Type /Page /Parent {pages_id} 0 R /MediaBox [0 0 612 792] "
                 f"/Contents {cid} 0 R /Resources << /Font << /F1 {font1_id} 0 R /F2 {font2_id} 0 R >> >> >>\nendobj\n")
        all_objs.append(p_obj)

        length, sbytes = stream_objs[idx]
        c_obj = (f"{cid} 0 obj\n<< /Length {length} >>\nstream\n{sbytes.decode('latin1')}\nendstream\nendobj\n")
        all_objs.append(c_obj)

    # Write PDF file and compute xref
    with open(output_path, "wb") as f:
        f.write(b"%PDF-1.4\n")
        offsets = [0]
        offset = len(b"%PDF-1.4\n")

        for obj in all_objs:
            offsets.append(offset)
            b = obj.encode('latin1')
            f.write(b)
            offset += len(b)

        xref_offset = offset
        f.write(b"xref\n")
        f.write(f"0 {len(offsets)}\n".encode('latin1'))
        f.write(b"0000000000 65535 f \n")
        for off in offsets[1:]:
            f.write(f"{off:010d} 00000 n \n".encode('latin1'))

        f.write(b"trailer\n")
        f.write(f"<< /Size {len(offsets)} /Root {catalog_id} 0 R >>\n".encode('latin1'))
        f.write(b"startxref\n")
        f.write(f"{xref_offset}\n".encode('latin1'))
        f.write(b"%%EOF\n")

    print(f"Successfully generated PDF report: {output_path}")

if __name__ == "__main__":
    out_file = os.path.join(os.path.dirname(__file__), "Project_Report.pdf")
    create_pdf(out_file)
