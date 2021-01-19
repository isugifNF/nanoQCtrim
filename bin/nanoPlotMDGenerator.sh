#! /usr/bin/env bash
# Auth: Andrew Severin <severin@iastate.edu>
# Date:
# Desc: Generate the read length and quality markdown report


# === Usage Statement
function usage() {
cat << '_HELP' >&2
USAGE: bash nanoPlotMDGenerator.sh <nano_folder>
  Given a folder containing nanocomp html files, generate the read length and quality markdown report

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


### Create markdown file
echo "# $1 NanoPlot summary of raw data"
echo "# $1 NanoPlot summary of raw data" > $1_NanoStats.txt.md

#perl -pe 's/   +/ /g' ${1}_NanoStats.txt | perl -pe 's/: /:\t/g' | md | perl -pe 's/\|--\|/\|--\|--\|/g' >> $1.md
perl -pe 's/   +/ /g' ${1}/${1}_NanoStats.txt | perl -pe 's/: /:\t/g' | md >> $1_NanoStats.txt.md

# useful one liner to create the links below
#for plot in `ls *png`; do echo '!'"[${plot%.*}](nanoplots/\$1/$plot)"; done

cat <<MDFile >> $1_NanoStats.md

## Histogram of Number of Reads vs Read Length

![$1_HistogramReadlength](nanoplots/$1/$1_HistogramReadlength.png)
![$1_LogTransformed_HistogramReadlength](nanoplots/$1/$1_LogTransformed_HistogramReadlength.png)

## Histogram of Number of bases by read length
![$1_Weighted_HistogramReadlength](nanoplots/$1/$1_Weighted_HistogramReadlength.png)
![$1_Weighted_LogTransformed_HistogramReadlength](nanoplots/$1/$1_Weighted_LogTransformed_HistogramReadlength.png)


## Scatterplots of Average Quality vs Read Length

These data are plotted as a dotplot, hexplot and kdeplot.  The first plot is raw read length.  The second plot is log normalized read length.

### Dotplot Average Quality vs Read Length
![$1_LengthvsQualityScatterPlot_dot](nanoplots/$1/$1_LengthvsQualityScatterPlot_dot.png)
![$1_LengthvsQualityScatterPlot_loglength_dot](nanoplots/$1/$1_LengthvsQualityScatterPlot_loglength_dot.png)

### Hexplot Average Quality vs Read Length

![$1_LengthvsQualityScatterPlot_hex](nanoplots/$1/$1_LengthvsQualityScatterPlot_hex.png)
![$1_LengthvsQualityScatterPlot_loglength_hex](nanoplots/$1/$1_LengthvsQualityScatterPlot_loglength_hex.png)

### KDEplot Average Quality vs Read Length

![$1_LengthvsQualityScatterPlot_kde](nanoplots/$1/$1_LengthvsQualityScatterPlot_kde.png)
![$1_LengthvsQualityScatterPlot_loglength_kde](nanoplots/$1/$1_LengthvsQualityScatterPlot_loglength_kde.png)

## DotPlot of Yield by Read Length

![$1_Yield_By_Length](nanoplots/$1/$1_Yield_By_Length.png)

## Active Pores over Time

![$1_ActivePores_Over_Time](nanoplots/$1/$1_ActivePores_Over_Time.png)

## Reads per channel

![$1_ActivityMap_ReadsPerChannel](nanoplots/$1/$1_ActivityMap_ReadsPerChannel.png)

## Cummulative Yield Plot in Gigabases

![$1_CumulativeYieldPlot_Gigabases](nanoplots/$1/$1_CumulativeYieldPlot_Gigabases.png)

## CumulativeYieldPlot in number of reads

![$1_CumulativeYieldPlot_NumberOfReads](nanoplots/$1/$1_CumulativeYieldPlot_NumberOfRe

## Number of Reads over time

![$1_NumberOfReads_Over_Time](nanoplots/$1/$1_NumberOfReads_Over_Time.png)

## Time vs Read Length Violin Plot

![$1_TimeLengthViolinPlot](nanoplots/$1/$1_TimeLengthViolinPlot.png)

## Time vs log(Read Length) Violin Plot

![$1_TimeLogLengthViolinPlot](nanoplots/$1/$1_TimeLogLengthViolinPlot.png)

## Time vs Read Quality Violin Plot

![$1_TimeQualityViolinPlot](nanoplots/$1/$1_TimeQualityViolinPlot.png)

MDFile

cd -
