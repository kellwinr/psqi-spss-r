* =========================================================================.
* PSQI CALCULATOR (R Integration for SPSS 30).
* IMPORTANT: Ensure your variables are named as defined in 'var_names' below.
* Time variables (bed_time, wake_time) must be numeric (0-24 hours).
* =========================================================================.

BEGIN PROGRAM R.

library(ibmSpssStatistics)

# --- 1. SETUP VARIABLE MAPPING ---
# CHANGE THESE VALUES to match your actual SPSS variable names if different.
var_names <- list(
  # Q1: Bed Time (Numeric 0-24, e.g., 23.5)
  bed_time = "Q1_BedTime", 
  # Q2: Minutes to fall asleep (Numeric minutes)
  latency_min = "Q2_LatencyMin",
  # Q3: Wake Time (Numeric 0-24, e.g., 7.0)
  wake_time = "Q3_WakeTime",
  # Q4: Actual hours of sleep (Numeric hours)
  sleep_dur = "Q4_SleepDur",
  # Q5a-j: Frequency of trouble (0-3 scale)
  q5a = "Q5a_30min",
  q5b = "Q5b_WakeMid",
  q5c = "Q5c_Bathroom",
  q5d = "Q5d_Breathe",
  q5e = "Q5e_Cough",
  q5f = "Q5f_Cold",
  q5g = "Q5g_Hot",
  q5h = "Q5h_Dreams",
  q5i = "Q5i_Pain",
  q5j = "Q5j_Other",
  # Q6: Sleep Quality (0=Very Good ... 3=Very Bad)
  # NOTE: Standard PSQI Q6 is reverse coded (Very Good=0). Ensure this matches.
  q6 = "Q6_Quality",
  # Q7: Meds (0-3)
  q7 = "Q7_Meds",
  # Q8: Trouble staying awake (0-3)
  q8 = "Q8_DayTrouble",
  # Q9: Problem with enthusiasm (0-3)
  q9 = "Q9_Enthusiasm"
)

# --- 2. LOAD DATA FROM SPSS ---
# We fetch the specific variables defined above
tryCatch({
  df <- spssdata.GetDataFromSPSS(variables = unlist(var_names))
}, error = function(e) {
  stop("Error: Could not find variables. Please check the variable names in the 'var_names' list.")
})

# Rename columns to generic names for easier calculation
names(df) <- names(var_names)

# --- 3. COMPONENT CALCULATIONS ---

# Component 1: Subjective Sleep Quality (Q6)
# Directly uses Q6 score (0-3)
df$psqi_comp1 <- df$q6

# Component 2: Sleep Latency
# Step 1: Recode Q2 (Minutes)
df$lat_score_q2 <- ifelse(df$latency_min <= 15, 0,
                   ifelse(df$latency_min <= 30, 1,
                   ifelse(df$latency_min <= 60, 2, 3)))
# Step 2: Add Q5a
df$lat_sum <- df$lat_score_q2 + df$q5a
# Step 3: Assign Component Score
df$psqi_comp2 <- ifelse(df$lat_sum == 0, 0,
                 ifelse(df$lat_sum <= 2, 1,
                 ifelse(df$lat_sum <= 4, 2, 3)))

# Component 3: Sleep Duration (Q4)
# >7 hrs = 0, 6-7 = 1, 5-6 = 2, <5 = 3
df$psqi_comp3 <- ifelse(df$sleep_dur > 7, 0,
                 ifelse(df$sleep_dur >= 6, 1,
                 ifelse(df$sleep_dur >= 5, 2, 3)))

# Component 4: Habitual Sleep Efficiency
# Step 1: Calculate Hours in Bed
# Logic: If Wake < Bed, add 24 to Wake (crossing midnight)
df$hrs_in_bed <- ifelse(df$wake_time < df$bed_time, 
                        (df$wake_time + 24) - df$bed_time, 
                        df$wake_time - df$bed_time)

# Step 2: Calculate Efficiency %
df$efficiency <- (df$sleep_dur / df$hrs_in_bed) * 100

# Step 3: Assign Score
# >85% = 0, 75-84% = 1, 65-74% = 2, <65% = 3
df$psqi_comp4 <- ifelse(df$efficiency > 85, 0,
                 ifelse(df$efficiency >= 75, 1,
                 ifelse(df$efficiency >= 65, 2, 3)))

# Component 5: Sleep Disturbances (Sum Q5b to Q5j)
df$dist_sum <- rowSums(df[,c("q5b","q5c","q5d","q5e","q5f","q5g","q5h","q5i","q5j")], na.rm=TRUE)
# Score: 0=0, 1-9=1, 10-18=2, 19-27=3
df$psqi_comp5 <- ifelse(df$dist_sum == 0, 0,
                 ifelse(df$dist_sum <= 9, 1,
                 ifelse(df$dist_sum <= 18, 2, 3)))

# Component 6: Use of Sleeping Medication (Q7)
df$psqi_comp6 <- df$q7

# Component 7: Daytime Dysfunction (Q8 + Q9)
df$day_sum <- df$q8 + df$q9
# Score: 0=0, 1-2=1, 3-4=2, 5-6=3
df$psqi_comp7 <- ifelse(df$day_sum == 0, 0,
                 ifelse(df$day_sum <= 2, 1,
                 ifelse(df$day_sum <= 4, 2, 3)))

# --- 4. GLOBAL SCORE ---
df$psqi_global <- df$psqi_comp1 + df$psqi_comp2 + df$psqi_comp3 + 
                  df$psqi_comp4 + df$psqi_comp5 + df$psqi_comp6 + df$psqi_comp7

# --- 5. EXPORT BACK TO SPSS ---

# Create a new dataset spec definition
dict_new <- spssdictionary.GetDictionaryFromSPSS()

# Define the new variables we want to add
new_vars_spec <- list(
  c("PSQI_Comp1", "Subjective Quality", 0, "F8.0", "nominal"),
  c("PSQI_Comp2", "Sleep Latency", 0, "F8.0", "nominal"),
  c("PSQI_Comp3", "Sleep Duration", 0, "F8.0", "nominal"),
  c("PSQI_Comp4", "Sleep Efficiency", 0, "F8.0", "nominal"),
  c("PSQI_Comp5", "Sleep Disturbance", 0, "F8.0", "nominal"),
  c("PSQI_Comp6", "Medication Use", 0, "F8.0", "nominal"),
  c("PSQI_Comp7", "Daytime Dysfunction", 0, "F8.0", "nominal"),
  c("PSQI_Global", "Global PSQI Score", 0, "F8.0", "scale")
)

# Add definitions to dictionary
for (v in new_vars_spec) {
  spssdictionary.SetDictionaryToSPSS("PSQI_Results", 
      data.frame(varName=v[1], varLabel=v[2], varType=as.integer(v[3]), varFormat=v[4], varMeasurementLevel=v[5]))
}

# Combine original data with new scores
# Note: This creates a NEW dataset tab named "PSQI_Results"
# We select only the new columns to append or the full set
output_df <- data.frame(
  df$psqi_comp1, df$psqi_comp2, df$psqi_comp3, df$psqi_comp4,
  df$psqi_comp5, df$psqi_comp6, df$psqi_comp7, df$psqi_global
)

spssdata.SetDataToSPSS("PSQI_Results", output_df)

spsspkg.EndProcedure()

END PROGRAM.
