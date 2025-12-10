* --- STEP 1: COMPONENT 1 (Subjective Quality) ---.
COMPUTE PSQI_Comp1 = Q6_Quality.
EXECUTE.

* --- STEP 2: COMPONENT 2 (Sleep Latency) ---.
* Score Q2 (Minutes).
RECODE Q2_LatencyMin (LOW THRU 15=0) (16 THRU 30=1) (31 THRU 60=2) (61 THRU HIGHEST=3) INTO temp_lat_score.
* Add Q5a.
COMPUTE temp_lat_sum = temp_lat_score + Q5a_30min.
* Assign Component 2 Score.
RECODE temp_lat_sum (0=0) (1 THRU 2=1) (3 THRU 4=2) (5 THRU HIGHEST=3) INTO PSQI_Comp2.
EXECUTE.

* --- STEP 3: COMPONENT 3 (Sleep Duration) ---.
RECODE Q4_SleepDur (7.0001 THRU HIGHEST=0) (6 THRU 7=1) (5 THRU 5.9999=2) (LOW THRU 4.9999=3) INTO PSQI_Comp3.
EXECUTE.

* --- STEP 4: COMPONENT 4 (Sleep Efficiency) ---.
* Calculate Hours in Bed (Handling midnight crossing).
IF (Q3_WakeTime >= Q1_BedTime) temp_bed_hrs = Q3_WakeTime - Q1_BedTime.
IF (Q3_WakeTime < Q1_BedTime) temp_bed_hrs = (Q3_WakeTime + 24) - Q1_BedTime.
* Calculate Efficiency %.
COMPUTE temp_efficiency = (Q4_SleepDur / temp_bed_hrs) * 100.
* Assign Score.
RECODE temp_efficiency (85 THRU HIGHEST=0) (75 THRU 84.99=1) (65 THRU 74.99=2) (LOW THRU 64.99=3) INTO PSQI_Comp4.
EXECUTE.

* --- STEP 5: COMPONENT 5 (Sleep Disturbance) ---.
COMPUTE temp_dist_sum = SUM(Q5b_WakeMid, Q5c_Bathroom, Q5d_Breathe, Q5e_Cough, Q5f_Cold, Q5g_Hot, Q5h_Dreams, Q5i_Pain, Q5j_Other).
RECODE temp_dist_sum (0=0) (1 THRU 9=1) (10 THRU 18=2) (19 THRU HIGHEST=3) INTO PSQI_Comp5.
EXECUTE.

* --- STEP 6: COMPONENT 6 (Medication Use) ---.
COMPUTE PSQI_Comp6 = Q7_Meds.
EXECUTE.

* --- STEP 7: COMPONENT 7 (Daytime Dysfunction) ---.
COMPUTE temp_day_sum = Q8_DayTrouble + Q9_Enthusiasm.
RECODE temp_day_sum (0=0) (1 THRU 2=1) (3 THRU 4=2) (5 THRU 6=3) INTO PSQI_Comp7.
EXECUTE.

* --- FINAL: GLOBAL SCORE ---.
COMPUTE PSQI_Global = SUM(PSQI_Comp1, PSQI_Comp2, PSQI_Comp3, PSQI_Comp4, PSQI_Comp5, PSQI_Comp6, PSQI_Comp7).
VARIABLE LABELS PSQI_Global "Pittsburgh Sleep Quality Index Global Score".
EXECUTE.

* --- CLEANUP (Optional) ---.
* DELETE VARIABLES temp_lat_score temp_lat_sum temp_bed_hrs temp_efficiency temp_dist_sum temp_day_sum.
