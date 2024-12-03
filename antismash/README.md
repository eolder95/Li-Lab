# Local antiSMASH
## Description
This script will run antiSMASH v6 on a set of input genomes. The script includes three modes: `minimal`, `full`, and `upgrade` which can be set using the flag `-m`. An input file containing a list of absolute paths to each input genome must be provided using the flag `-i`.

## Installation
From this directory containing the `run_antismash.sh` script and the folder example_data, follow the following instructions:
1. Create a conda environment using `conda create -n antismash antismash`
2. Activate conda environment using `conda activate antismash`
3. Run test data using `run_antismash.sh -m full -i example_data/example_input.txt`

## Modes
In `minimal` mode, antiSMASH will be run using BGC detection and identification only without running the in depth analysis modules. This is intended to be used for quick turnaround when analyzing many genomes at the same time.

In `full` mode, antiSMASH will be run using all analysis modules. This will take the longest amount of time and computational resources so should be used sparingly on a local computer.

In `upgrade` mode, antiSMASH will **REUSE** previous results obtained in `minimal` mode and re-analyze them including all analysis modules, as if they had been run using `full` mode. This is intended to be used after analyzing multiple genomes in `minimal` mode.
