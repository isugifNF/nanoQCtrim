#! /usr/bin/env bash
# Auth: Andrew Severin <severin@iastate.edu>
# Date:
# Desc: Run nanoplot 1.30.1 singularity image on a given FASTQ file

set -e
set -u

# === Usage Statement
function usage() {
cat << '_HELP' >&2
USAGE: bash runNanoPlot.sh <nanopore.fastq> <some_label>
  Given a fastq file of nanopore sequences, run nanoplot in a singularity image
  Will also need a label (can be anything) for the output

_HELP
}

if [[ $# -lt 2 ]]; then
    usage;
    exit 0
fi

# Exit early if fastq file doesn't exist
if [[ ! -f "$1" ]]; then
    usage;
    echo "Error: Can't find FASTQ file \"$1\""  >&2
    echo "  First argument must be the nanopore fastq file." >&2
    exit 0
fi

# === Main Program
export fastq=$1
export label=$2

singularity exec --bind $PWD nanoplot_1.30.1--py_0.sif NanoPlot -t 36 --huge --verbose --store -o ${label} -p ${label}_  -f png --loglength --dpi 300 --plots {'kde','hex','dot'} --title ${label}" Nanopore Sequence" --N50 --fastq_rich ${fastq}
singularity exec --bind $PWD nanoplot_1.30.1--py_0.sif NanoPlot -t 36 --huge --verbose --store -o ${label} -p ${label}_ -f pdf --loglength --plots {'kde','hex','dot'} --title ${label}" Nanopore Sequence" --N50 --pickle ${label}/${label}_NanoPlot-data.pickle

# == list the generated file/folder here?
# ls -dhltr <folder here>
# ls -dhltr <file here>
