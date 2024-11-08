#!/bin/bash

## Set flags
print_usage() {
  echo "Usage: hpc_multismash [-c <config_file_path>] [-n dry mode]"
}

OPTSTRING=":c:n"

while getopts "${OPTSTRING}" flags; do
  case "${flags}" in
  		c)
			config_file_path=${OPTARG}
			;;
		n)
			dry_mode=TRUE
			;;
		:)	
			echo "Option -${OPTARG} requires an argument"
			print_usage
			exit 1
			;;
		?)
			echo "Invalid option: -${OPTARG}"
			print_usage
			exit 1
			;;
  esac
done
shift $((OPTIND-1))

## Load Conda virtual env
echo "$(date -R): Loading conda env \"antismash\""
eval "$(conda shell.bash hook)"
source activate /home/ethan/miniconda3/envs/antismash

## Set global params
# mem=$(awk '/MemFree/ { printf "%.0f \n", $2/1024/1024 }' /proc/meminfo)
# cpus=$(nproc --all)
# dir=$(pwd)

## Set script specific params
# input_paths=$1

## Main 
if [[ ${dry_mode} == TRUE ]]; then
	multismash "${config_file_path}" -n
else
	multismash "${config_file_path}"
fi

## Total time elapsed
if (( SECONDS > 86400 )) ; then
	((days=SECONDS/86400))
	((hours=(SECONDS%86400)/3600))
	((minutes=((SECONDS%86400)%3600)/60))
	((seconds=((SECONDS%86400)%3600)%60))
	echo -e "$(date -R): Completed in $days day(s), $hours hour(s), $minutes minute(s) and $seconds second(s)\n"
elif (( SECONDS > 3600 )) ; then
	((hours=SECONDS/3600))
	((minutes=(SECONDS%3600)/60))
	((seconds=(SECONDS%3600)%60))
    echo -e "$(date -R): Completed in $hours hour(s), $minutes minute(s) and $seconds second(s)\n"
elif (( SECONDS > 60 )) ; then
	((minutes=(SECONDS%3600)/60))
	((seconds=(SECONDS%3600)%60))
    echo -e "$(date -R): Completed in $minutes minute(s) and $seconds second(s)\n"
else
    echo -e "$(date -R): Completed in $SECONDS seconds\n"
fi
