# PSQI Calculator for SPSS 30 (Dual Version)

![SPSS Version](https://img.shields.io/badge/SPSS-v30-blue)
![Build](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-green)

This repository contains two distinct SPSS Syntax scripts (`.sps`) designed to automatically calculate the **Pittsburgh Sleep Quality Index (PSQI)**. Both scripts calculate the 7 sub-components and the final Global Score according to the original scoring algorithms established by Buysse et al. (1989).

## 📂 Included Versions

| Version | File Type | Description | Best For |
| :--- | :--- | :--- | :--- |
| **v1: R Integration** | `.r` (with R) | Uses R vectorization inside SPSS. Creates a new clean dataset tab. | Standard datasets (<500k rows), clean output. |
| **v2: Native Syntax** | `.sps` (Pure) | Uses standard `COMPUTE` and `RECODE` commands. No R required. | **Massive** datasets (>1M rows) or systems without R installed. |

---

## ⚙️ Prerequisites

* **IBM SPSS Statistics 30** (or compatible older versions).
* **For Version 1 only:** SPSS "R Essentials" plugin (usually installed by default in v30).
* **For Version 2:** No plugins required.

---

## 📋 Data Preparation (Critical)

Before running either script, your SPSS dataset **must** match the following variable names and formats. 

### 1. Variable Naming Convention
Rename your variables in the **Variable View** to match these exact names, or edit the `.sps` file to match your data.

| Variable Name | Description | Format / Values |
| :--- | :--- | :--- |
| `Q1_BedTime` | Bed Time | **Numeric Decimal** (0-24). E.g., 10:30 PM = `22.5` |
| `Q2_LatencyMin` | Minutes to fall asleep | Numeric (Minutes) |
| `Q3_WakeTime` | Wake Up Time | **Numeric Decimal** (0-24). E.g., 7:00 AM = `7.0` |
| `Q4_SleepDur` | Actual Hours Slept | Numeric (Hours) |
| `Q5a_30min` | Trouble: 30min to sleep | Scale 0-3 |
| `Q5b_WakeMid` | Trouble: Wake in middle of night | Scale 0-3 |
| `Q5c_Bathroom` | Trouble: Bathroom | Scale 0-3 |
| `Q5d_Breathe` | Trouble: Breathing | Scale 0-3 |
| `Q5e_Cough` | Trouble: Coughing | Scale 0-3 |
| `Q5f_Cold` | Trouble: Cold | Scale 0-3 |
| `Q5g_Hot` | Trouble: Hot | Scale 0-3 |
| `Q5h_Dreams` | Trouble: Bad Dreams | Scale 0-3 |
| `Q5i_Pain` | Trouble: Pain | Scale 0-3 |
| `Q5j_Other` | Trouble: Other reason | Scale 0-3 |
| `Q6_Quality` | Subjective Quality | Scale 0-3 (**NOTE:** 0=Very Good, 3=Very Bad) |
| `Q7_Meds` | Sleep Meds | Scale 0-3 |
| `Q8_DayTrouble` | Trouble staying awake | Scale 0-3 |
| `Q9_Enthusiasm` | Problem with enthusiasm | Scale 0-3 |

> **⚠️ Time Format Warning:** Q1 and Q3 must be **numeric** (decimal hours), not String or Date/Time format. 
> * Correct: `23.5`
> * Incorrect: `"11:30 PM"` or `23:30:00`

---

## 🚀 How to Run

### Option A: Using Version 1 (R Integration)
1.  Open your data file (`.sav`) in SPSS.
2.  Go to **File > New > Syntax**.
3.  Paste the code from `PSQI_Calculator_R.sps`.
4.  Click **Run** (Green Arrow).
5.  **Result:** A *new* dataset tab named `PSQI_Results` will open containing the calculated scores.

### Option B: Using Version 2 (Native Syntax)
1.  Open your data file (`.sav`) in SPSS.
2.  Go to **File > New > Syntax**.
3.  Paste the code from `PSQI_Calculator_Native.sps`.
4.  Click **Run** (Green Arrow).
5.  **Result:** The new variables (`PSQI_Comp1`... `PSQI_Global`) are appended directly to the end of your *current* dataset.

---

## 📊 Output Variables

Both scripts generate the following variables:

* **PSQI_Comp1**: Subjective Sleep Quality
* **PSQI_Comp2**: Sleep Latency
* **PSQI_Comp3**: Sleep Duration
* **PSQI_Comp4**: Habitual Sleep Efficiency
* **PSQI_Comp5**: Sleep Disturbances
* **PSQI_Comp6**: Use of Sleeping Medication
* **PSQI_Comp7**: Daytime Dysfunction
* **PSQI_Global**: Total PSQI Score (Sum of components)

---

## 🛠 Troubleshooting

* **Error: "Object not found" (R Version):** * This means your Variable View names do not match the `var_names` list in the script. Check spelling and capitalization.
* **Negative Sleep Efficiency:**
    * Check `Q1_BedTime`. If a participant went to bed at 1 AM, ensure it is entered as `25` or `1` (depending on how you handle next-day logic), but standard 24h notation (`1.0`) usually works best with the logic provided.
* **Empty Output:**
    * Ensure your inputs (`Q5a`... `Q9`) are numeric `0, 1, 2, 3`. If they are strings ("Once a week"), the math will fail. Recode them into numbers first.

---

## 📚 References

The scoring algorithms used in these scripts are based on the original PSQI methodology:

> Buysse, D. J., Reynolds, C. F., Monk, T. H., Berman, S. R., & Kupfer, D. J. (1989). The Pittsburgh Sleep Quality Index: A new instrument for psychiatric practice and research. *Psychiatry Research*, 28(2), 193-213. https://doi.org/10.1016/0165-1781(89)90047-4
