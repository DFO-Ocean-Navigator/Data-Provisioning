**Description**
`riopsWeighted.sh` is a script to conglomerate and normalize riops files into 3h averages so that `riopsMonthly.sh` can quickly make monthly averages. The input directories of `riopsWeighted.sh` should be any location where RIOPS files are being pulled down. The input directory of `riopsMonthly.sh` should be the output of `riopsWerighted.sh`. They should be run on the first of every month, or right after the last data from the previous month is pulled down.

These scripts can be easily modified to only look for a specific year by specifying "YYYY" at the beginning of the name pattern for the find commands near the beginning of both scripts.

Both these scripts depend on NCO tools. Navigator containers will have a conda environment named `nco-tools` that contain the necessary tools.

**Time estimates:**
Assuming 100% 48h instantaneous:
`riopsWerighed.sh`: ~8min per run (4 runs per day).
`riopsMonthly.sh`: ~2hours per 31 day month.