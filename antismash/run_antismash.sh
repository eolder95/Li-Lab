#!/bin/bash

## Init flags
run_mode='full'

print_usage() {
  printf "Usage: run_antismash [-m <minimal|upgrade|full>] [-i <input_paths>]"
}

while getopts ':m:i:' flags; do
  case "${flags}" in
  	m) 
				run_mode=${OPTARG}
				;;
		i)
				input_paths=${OPTARG}
				;;
		*)
				print_usage
				exit 1
				;;
  esac
done
shift $((OPTIND-1))

if [ -z "${run_mode}" ] || [ -z "${input_paths}" ]; then
	print_usage
	exit 1
fi

## Load Conda virtual env
echo "$(date -R): Loading conda env \"antismash\""
eval "$(conda shell.bash hook)"
source activate /home/ethan/miniconda3/envs/antismash

## Set global params
# mem=$(awk '/MemFree/ { printf "%.0f \n", $2/1024/1024 }' /proc/meminfo)
cpus=$(( "$(nproc --all)" - 1))
dir=$(pwd -P)

## Set script specific params
# results_path=./${sample_name}_as6_out
# logfile_path=$results_path/${sample_name}_as6.log

antismash_minimal () {
## Run antismash v6 with file path input and minimal features (BGC calling only)
	sample_path=$1
	sample_name=$(basename "${sample_path}")
	output_dir=${dir}/${sample_name}_minimal_as6_out

	echo "$(date -R): Running antismash on ${sample_name}"

	antismash \
		--cpus ${cpus} \
		--output-dir "${output_dir}" \
		--logfile "${output_dir}/${sample_name}_log.txt" \
		--genefinding-tool prodigal \
		--minimal \
		--enable-genefunctions \
		--enable-lanthipeptides \
		--enable-html \
		--verbose \
		--debug \
		"${sample_path}" 1>&2

	echo "$(date -R): Done"
}

antismash_upgrade () {
## Run antismash v6 on minimal results upgrading to expanded results
	sample_path=$1
	sample_name=$(basename "${sample_path}")
	output_dir=${dir}/${sample_name}_minimal_as6_out

	echo "$(date -R): Running antismash on ${sample_name}"

	antismash \
		--reuse-results "${output_dir}/${sample_name%.*}.json" \
		--logfile "${output_dir}/${sample_name}_upgrade_log.txt" \
		--output-dir "${output_dir}" \
		--cpus ${cpus} \
		--genefinding-tool prodigal \
		--clusterhmmer \
		--cc-mibig \
		--cb-general \
		--verbose \
		--debug 1>&2

	echo "$(date -R): Done"
}

antismash_full () {
## Run antismash v6 with file path input and full features
	sample_path=$1
	sample_name=$(basename "${sample_path}")
	output_dir=${dir}/${sample_name}_as6_out

	echo "$(date -R): Running antismash on ${sample_name}"

	antismash \
		--cpus ${cpus} \
		--clusterhmmer \
		--tigrfam \
		--asf \
		--cc-mibig \
		--cb-general \
		--cb-subclusters \
		--cb-knownclusters \
		--pfam2go \
		--rre \
		--smcog-trees \
		--output-dir "${output_dir}" \
		--genefinding-tool prodigal \
		--logfile "${output_dir}/${sample_name}_log.txt" \
		--verbose \
		--debug \
		"${sample_path}" 1>&2

	echo "$(date -R): Done"
}

## Main function
while read -r line; do
	if [[ ${run_mode} == "minimal" ]]; then
		echo "$(date -R): Running antismash in minimal mode"
		antismash_minimal "${line}"
	elif [[ ${run_mode} == "upgrade" ]]; then
		echo "$(date -R): Running antismash in upgrade mode (minimal + clusterblast)"
		antismash_upgrade "${line}"
	else
		echo "$(date -R): Running antismash in full mode"
		antismash_full "${line}"
	fi
done < "${input_paths}"


## Sample time elapsed; Requires "SAMPLE_START=$SECONDS" above
SAMPLE_END=$SECONDS
SAMPLE_TIME=$(( SAMPLE_END - SAMPLE_START ))

if (( SAMPLE_TIME > 86400 )) ; then
	((days=SAMPLE_TIME/86400))
	((hours=(SAMPLE_TIME%86400)/3600))
	((minutes=((SAMPLE_TIME%86400)%3600)/60))
	((seconds=((SAMPLE_TIME%86400)%3600)%60))
	echo -e "$(date -R): Sample completed in $days day(s), $hours hour(s), $minutes minute(s) and $seconds second(s)\n"
elif (( SAMPLE_TIME > 3600 )) ; then
	((hours=SAMPLE_TIME/3600))
	((minutes=(SAMPLE_TIME%3600)/60))
	((seconds=(SAMPLE_TIME%3600)%60))
	echo -e "$(date -R): Sample completed in $hours hour(s), $minutes minute(s) and $seconds second(s)\n"
elif (( SAMPLE_TIME > 60 )) ; then
	((minutes=(SAMPLE_TIME%3600)/60))
	((seconds=(SAMPLE_TIME%3600)%60))
	echo -e "$(date -R): Sample completed in $minutes minute(s) and $seconds second(s)\n"
else
	echo -e "$(date -R): Sample completed in ${SAMPLE_TIME} seconds\n"
fi

echo -e "$(date -R): Done"

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

######################################################################
##########                      Notes                       ##########
######################################################################

# ########### antiSMASH 6.1.1 #############

# usage: antismash [--taxon {bacteria,fungi}] [--output-dir OUTPUT_DIR]
#                  [--output-basename OUTPUT_BASENAME] [--reuse-results PATH] [--limit LIMIT]
#                  [--minlength MINLENGTH] [--start START] [--end END] [--databases PATH]
#                  [--write-config-file PATH] [--without-fimo]
#                  [--executable-paths EXECUTABLE=PATH,EXECUTABLE2=PATH2,...] [--allow-long-headers]
#                  [-v] [-d] [--logfile PATH] [--list-plugins] [--check-prereqs]
#                  [--limit-to-record RECORD_ID] [-V] [--profiling] [--skip-sanitisation]
#                  [--skip-zip-file] [--minimal] [--enable-genefunctions] [--enable-lanthipeptides]
#                  [--enable-lassopeptides] [--enable-nrps-pks] [--enable-sactipeptides]
#                  [--enable-t2pks] [--enable-thiopeptides] [--enable-tta] [--enable-html]
#                  [--fullhmmer] [--fullhmmer-pfamdb-version FULLHMMER_PFAMDB_VERSION]
#                  [--hmmdetection-strictness {strict,relaxed,loose}] [--sideload JSON]
#                  [--sideload-simple ACCESSION:START-END] [--sideload-by-cds LOCUS1,LOCUS2,...]
#                  [--sideload-size-by-cds NUCLEOTIDES] [--cassis] [--clusterhmmer]
#                  [--clusterhmmer-pfamdb-version CLUSTERHMMER_PFAMDB_VERSION] [--tigrfam] [--asf]
#                  [--cc-mibig] [--cc-custom-dbs FILE1,FILE2,...] [--cb-general] [--cb-subclusters]
#                  [--cb-knownclusters] [--cb-nclusters count] [--cb-min-homology-scale LIMIT]
#                  [--pfam2go] [--rre] [--rre-cutoff RRE_CUTOFF] [--rre-minlength RRE_MIN_LENGTH]
#                  [--smcog-trees] [--tta-threshold TTA_THRESHOLD] [--html-title HTML_TITLE]
#                  [--html-description HTML_DESCRIPTION] [--html-start-compact]
#                  [--genefinding-tool {glimmerhmm,prodigal,prodigal-m,none,error}]
#                  [--genefinding-gff3 GFF3_FILE] [-h] [--help-showall] [-c CPUS]
#                  [SEQUENCE [SEQUENCE ...]]


# arguments:
#   SEQUENCE  GenBank/EMBL/FASTA file(s) containing DNA.

# --------
# Options
# --------
# -h, --help              Show this help text.
# --help-showall          Show full lists of arguments on this help text.
# -c CPUS, --cpus CPUS    How many CPUs to use in parallel. (default: 4)

# Basic analysis options:

#   --taxon {bacteria,fungi}
#                         Taxonomic classification of input sequence. (default: bacteria)

# Additional analysis:

#   --fullhmmer           Run a whole-genome HMMer analysis.
#   --cassis              Motif based prediction of SM gene cluster regions.
#   --clusterhmmer        Run a cluster-limited HMMer analysis.
#   --tigrfam             Annotate clusters using TIGRFam profiles.
#   --asf                 Run active site finder analysis.
#   --cc-mibig            Run a comparison against the MIBiG dataset
#   --cb-general          Compare identified clusters against a database of antiSMASH-predicted
#                         clusters.
#   --cb-subclusters      Compare identified clusters against known subclusters responsible for
#                         synthesising precursors.
#   --cb-knownclusters    Compare identified clusters against known gene clusters from the MIBiG
#                         database.
#   --pfam2go             Run Pfam to Gene Ontology mapping module.
#   --rre                 Run RREFinder precision mode on all RiPP gene clusters.
#   --smcog-trees         Generate phylogenetic trees of sec. met. cluster orthologous groups.
#   --tta-threshold TTA_THRESHOLD
#                         Lowest GC content to annotate TTA codons at (default: 0.65).

# Output options:

#   --output-dir OUTPUT_DIR
#                         Directory to write results to.
#   --output-basename OUTPUT_BASENAME
#                         Base filename to use for output files within the output directory.
#   --html-title HTML_TITLE
#                         Custom title for the HTML output page (default is input filename).
#   --html-description HTML_DESCRIPTION
#                         Custom description to add to the output.
#   --html-start-compact  Use compact view by default for overview page.

# Advanced options:

#   --reuse-results PATH  Use the previous results from the specified json datafile
#   --limit LIMIT         Only process the first <limit> records (default: -1). -1 to disable
#   --minlength MINLENGTH
#                         Only process sequences larger than <minlength> (default: 1000).
#   --start START         Start analysis at nucleotide specified.
#   --end END             End analysis at nucleotide specified
#   --databases PATH      Root directory of the databases (default:
#                         /home/ethan/miniconda3/envs/antismash_6/lib/python3.8/site-
#                         packages/antismash/databases).
#   --write-config-file PATH
#                         Write a config file to the supplied path
#   --without-fimo        Run without FIMO (lowers accuracy of RiPP precursor predictions)
#   --executable-paths EXECUTABLE=PATH,EXECUTABLE2=PATH2,...
#                         A comma separated list of executable name->path pairs to override any on
#                         the system path.E.g. diamond=/alternate/path/to/diamond,hmmpfam2=hmm2pfam
#   --allow-long-headers  Prevents long headers from being renamed
#   --hmmdetection-strictness {strict,relaxed,loose}
#                         Defines which level of strictness to use for HMM-based cluster detection,
#                         (default: relaxed).
#   --sideload JSON       Sideload annotations from the JSON file in the given paths. Multiple files
#                         can be provided, separated by a comma.
#   --sideload-simple ACCESSION:START-END
#                         Sideload a single subregion in record ACCESSION from START to END.
#                         Positions are expected to be 0-indexed, with START inclusive and END
#                         exclusive.
#   --sideload-by-cds LOCUS1,LOCUS2,...
#                         Sideload a subregion around each CDS with the given locus tags.
#   --sideload-size-by-cds NUCLEOTIDES
#                         Additional padding, in nucleotides, of subregions to create for sideloaded
#                         subregions by CDS. (default: 20000)

# Debugging & Logging options:

#   -v, --verbose         Print verbose status information to stderr.
#   -d, --debug           Print debugging information to stderr.
#   --logfile PATH        Also write logging output to a file.
#   --list-plugins        List all available sec. met. detection modules.
#   --check-prereqs       Just check if all prerequisites are met.
#   --limit-to-record RECORD_ID
#                         Limit analysis to the record with ID record_id
#   -V, --version         Display the version number and exit.
#   --profiling           Generate a profiling report, disables multiprocess python.
#   --skip-sanitisation   Skip input record sanitisation. Use with care.
#   --skip-zip-file       Do not create a zip of the output

# Debugging options for cluster-specific analyses:

#   --minimal             Only run core detection modules, no analysis modules unless explicitly
#                         enabled
#   --enable-genefunctions
#                         Enable Gene function annotations (default: enabled, unless --minimal is
#                         specified)
#   --enable-lanthipeptides
#                         Enable Lanthipeptides (default: enabled, unless --minimal is specified)
#   --enable-lassopeptides
#                         Enable lassopeptide precursor prediction (default: enabled, unless
#                         --minimal is specified)
#   --enable-nrps-pks     Enable NRPS/PKS analysis (default: enabled, unless --minimal is specified)
#   --enable-sactipeptides
#                         Enable sactipeptide detection (default: enabled, unless --minimal is
#                         specified)
#   --enable-t2pks        Enable type II PKS analysis (default: enabled, unless --minimal is
#                         specified)
#   --enable-thiopeptides
#                         Enable Thiopeptides (default: enabled, unless --minimal is specified)
#   --enable-tta          Enable TTA detection (default: enabled, unless --minimal is specified)
#   --enable-html         Enable HTML output (default: enabled, unless --minimal is specified)

# Full HMMer options:

#   --fullhmmer-pfamdb-version FULLHMMER_PFAMDB_VERSION
#                         PFAM database version number (e.g. 27.0) (default: latest).

# Cluster HMMer options:

#   --clusterhmmer-pfamdb-version CLUSTERHMMER_PFAMDB_VERSION
#                         PFAM database version number (e.g. 27.0) (default: latest).

# TIGRFam options:

# ClusterCompare options:

#   --cc-custom-dbs FILE1,FILE2,...
#                         A comma separated list of database config files to run with

# ClusterBlast options:

#   --cb-nclusters count  Number of clusters from ClusterBlast to display, cannot be greater than 50.
#                         (default: 10)
#   --cb-min-homology-scale LIMIT
#                         A minimum scaling factor for the query BGC in ClusterBlast results. Valid
#                         range: 0.0 - 1.0. Warning: some homologous genes may no longer be visible!
#                         (default: 0.0)

# NRPS/PKS options:

# RREfinder options:

#   --rre-cutoff RRE_CUTOFF
#                         Bitscore cutoff for RRE pHMM detection (default: 25.0).
#   --rre-minlength RRE_MIN_LENGTH
#                         Minimum amino acid length of RRE domains (default: 50).

# Gene finding options (ignored when ORFs are annotated):

#   --genefinding-tool {glimmerhmm,prodigal,prodigal-m,none,error}
#                         Specify algorithm used for gene finding: GlimmerHMM, Prodigal, Prodigal
#                         Metagenomic/Anonymous mode, or none. The 'error' option will raise an error
#                         if genefinding is attempted. The 'none' option will not run genefinding.
#                         (default: error).
#   --genefinding-gff3 GFF3_FILE
#                         Specify GFF3 file to extract features from.
