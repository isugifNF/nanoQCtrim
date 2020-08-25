#! /usr/bin/env bash
# Auth: Andrew Severin <severin@iastate.edu>
# Date:
# Desc: Generate a markdown file from nanoComp results

set -e
set -u

# === Usage Statement
function usage() {
cat << '_HELP' >&2
USAGE: bash nanoCompMDGenerator.sh <nano_folder>
  Given a folder containing nanocomp html files, generate the markdown report

_HELP
}

if [[ $# -lt 1 ]]; then
    usage;
    exit 0
fi

# Exit early if folder (directory) doesn't exist
if [[ ! -d "$1" ]]; then
    usage;
    echo "Error: Can't find folder \"$1\""  >&2
    echo "  First argument must be a folder containing the nanoComp html files" >&2
    exit 0
fi

# === Main Program
# first argument is the folder to organize and generate a markdown file of its contents

## Organize Folder
  cd $1

  rm *.html


  ### create folders for png and pdf and organize

  mkdir -p ../nanoplots/$1
  mv *png ../nanoplots/$1
  mv *log ../nanoplots/$1

  ### Create markdown file

  echo "# $1 NanoComp summary of all raw data\n" > $1.md

  cat NanoStats.txt  | md >> $1.md

  cat <<MDFile >> $1.md

## BarPlot of N50 values for each sample
  ![NanoComp_N50](nanoplots/$1/NanoComp_N50.png)

## Violin Plots of Read Lengths for each sample
  ![NanoComp_lengths](nanoplots/$1/NanoComp_lengths.png)
  ![NanoComp_log_length](nanoplots/$1/NanoComp_log_length.png)
## Total number of reads for each sample
  ![NanoComp_number_of_reads](nanoplots/$1/NanoComp_number_of_reads.png)
## Average base quality for each sample
  ![NanoComp_quals](nanoplots/$1/NanoComp_quals.png)
## Total gigabases per sample
  ![NanoComp_total_throughput](nanoplots/$1/NanoComp_total_throughput.png)

MDFile

cd -

# === list generated markdown report
ls -hltr $1/$1.md
