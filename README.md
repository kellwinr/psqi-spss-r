# psqi-spss-r
PSQI score calculator using R in SPSS v30, test only not sure it will work or not

Below is a complete R script designed to run inside SPSS 30. It reads your active dataset, calculates all components and the global score, and generates a new dataset with these scores added.

### Prerequisites

SPSS 30 with R Essentials installed (usually included by default in v30).

Variable Naming: Your SPSS variables must match the names in the "Input Map" below, or you must rename the variables in the code.

Data Format:

Q5a to Q9 must be numeric (0=Not during past month, 1=Less than once a week, 2=Once or twice a week, 3=Three or more times).

Time Variables (Q1 & Q3): Must be numeric decimals (24-hour clock). Example: 10:30 PM should be 22.5, 7:00 AM should be 7.0.

The R Script for SPSS

Copy and paste the following code into a Syntax Editor window in SPSS and click Run.
