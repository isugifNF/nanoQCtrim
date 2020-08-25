#! /usr/bin/env nextflow

/*************************************
 nextflow nanoQCtrim
 *************************************/

nanoplot_container = 'quay.io/biocontainers/nanoplot:1.32.0--py_0'


 def helpMessage() {
     log.info isuGIFHeader()
     log.info """
      Usage:
      The typical command for running the pipeline is as follows:
      nextflow run isugifNF/parallelNF --input 'command to list input files' --script 'command to run on each input file'

      Mandatory arguments:

      --fastqs                      fastq files to run nanoplot on. (/data/*.fastq)

      Optional arguments:
      --outdir                      Output directory to place final BLAST output
      --threads                      Number of CPUs to use during the NanoPlot job [16]
      --help                         This usage statement.
     """
}

     // Show help message
     if (params.help) {
         helpMessage()
         exit 0
     }


fastq_reads_qc = Channel
                   .fromPath(params.fastqs)
                   .map { file -> tuple(file.simpleName, file) }


process runNanoPlot {

  container = "$nanoplot_container"

  publishDir "${params.outdir}/nanoplot/png", mode: 'copy', pattern: '*/*.png'
  publishDir "${params.outdir}/nanoplot/pdf", mode: 'copy', pattern: '*/*.pdf'
  publishDir "${params.outdir}/nanoplot/pdf", mode: 'copy', pattern: '*/*.log'
  publishDir "${params.outdir}/nanoplot/pdf", mode: 'copy', pattern: '*/*.md'


  input:
  set val(label), file(fastq) from fastq_reads_qc


  output:
  file("*/*.png") into nanoplot_png
  file("*/*.pdf") into nanoplot_pdf
  file("*/*.log") into nanoplot_log
  file("*/*.md") into nanoplot_md

  script:

  """
  NanoPlot -t ${params.threads} --huge --verbose --store -o ${label} -p ${label}_  -f png --loglength --dpi 300 --plots {'kde','hex','dot'} --title ${label}" Nanopore Sequence" --N50 --fastq_rich ${fastq}
  NanoPlot -t ${params.threads} --huge --verbose --store -o ${label} -p ${label}_ -f pdf --loglength --plots {'kde','hex','dot'} --title ${label}" Nanopore Sequence" --N50 --pickle ${label}/${label}_NanoPlot-data.pickle

  ## create markdown
  echo "# ${label} NanoPlot summary of raw data" > ${label}.md
  perl -pe 's/   +/ /g' $${label}_NanoStats.txt | perl -pe 's/: /:\t/g' | md >> ${label}_NanoStats.md

  cat <<MDFile >> ${label}_NanoStats.md

  ## Histogram of Number of Reads vs Read Length

  ![${label}_HistogramReadlength](nanoplots/${label}/${label}_HistogramReadlength.png)
  ![${label}_LogTransformed_HistogramReadlength](nanoplots/${label}/${label}_LogTransformed_HistogramReadlength.png)

  ## Histogram of Number of bases by read length
  ![${label}_Weighted_HistogramReadlength](nanoplots/${label}/${label}_Weighted_HistogramReadlength.png)
  ![${label}_Weighted_LogTransformed_HistogramReadlength](nanoplots/${label}/${label}_Weighted_LogTransformed_HistogramReadlength.png)


  ## Scatterplots of Average Quality vs Read Length

  These data are plotted as a dotplot, hexplot and kdeplot.  The first plot is raw read length.  The second plot is log normalized read length.

  ### Dotplot Average Quality vs Read Length
  ![${label}_LengthvsQualityScatterPlot_dot](nanoplots/${label}/${label}_LengthvsQualityScatterPlot_dot.png)
  ![${label}_LengthvsQualityScatterPlot_loglength_dot](nanoplots/${label}/${label}_LengthvsQualityScatterPlot_loglength_dot.png)

  ### Hexplot Average Quality vs Read Length

  ![${label}_LengthvsQualityScatterPlot_hex](nanoplots/${label}/${label}_LengthvsQualityScatterPlot_hex.png)
  ![${label}_LengthvsQualityScatterPlot_loglength_hex](nanoplots/${label}/${label}_LengthvsQualityScatterPlot_loglength_hex.png)

  ### KDEplot Average Quality vs Read Length

  ![${label}_LengthvsQualityScatterPlot_kde](nanoplots/${label}/${label}_LengthvsQualityScatterPlot_kde.png)
  ![${label}_LengthvsQualityScatterPlot_loglength_kde](nanoplots/${label}/${label}_LengthvsQualityScatterPlot_loglength_kde.png)

  ## DotPlot of Yield by Read Length

  ![${label}_Yield_By_Length](nanoplots/${label}/${label}_Yield_By_Length.png)

  ## Active Pores over Time

  ![${label}_ActivePores_Over_Time](nanoplots/${label}/${label}_ActivePores_Over_Time.png)

  ## Reads per channel

  ![${label}_ActivityMap_ReadsPerChannel](nanoplots/${label}/${label}_ActivityMap_ReadsPerChannel.png)

  ## Cummulative Yield Plot in Gigabases

  ![${label}_CumulativeYieldPlot_Gigabases](nanoplots/${label}/${label}_CumulativeYieldPlot_Gigabases.png)

  ## CumulativeYieldPlot in number of reads

  ![${label}_CumulativeYieldPlot_NumberOfReads](nanoplots/${label}/${label}_CumulativeYieldPlot_NumberOfRe

  ## Number of Reads over time

  ![${label}_NumberOfReads_Over_Time](nanoplots/${label}/${label}_NumberOfReads_Over_Time.png)

  ## Time vs Read Length Violin Plot

  ![${label}_TimeLengthViolinPlot](nanoplots/${label}/${label}_TimeLengthViolinPlot.png)

  ## Time vs log(Read Length) Violin Plot

  ![${label}_TimeLogLengthViolinPlot](nanoplots/${label}/${label}_TimeLogLengthViolinPlot.png)

  ## Time vs Read Quality Violin Plot

  ![${label}_TimeQualityViolinPlot](nanoplots/${label}/${label}_TimeQualityViolinPlot.png)

  MDFile
  """

}




    def isuGIFHeader() {
        // Log colors ANSI codes
        c_reset = params.monochrome_logs ? '' : "\033[0m";
        c_dim = params.monochrome_logs ? '' : "\033[2m";
        c_black = params.monochrome_logs ? '' : "\033[1;90m";
        c_green = params.monochrome_logs ? '' : "\033[1;92m";
        c_yellow = params.monochrome_logs ? '' : "\033[1;93m";
        c_blue = params.monochrome_logs ? '' : "\033[1;94m";
        c_purple = params.monochrome_logs ? '' : "\033[1;95m";
        c_cyan = params.monochrome_logs ? '' : "\033[1;96m";
        c_white = params.monochrome_logs ? '' : "\033[1;97m";
        c_red = params.monochrome_logs ? '' :  "\033[1;91m";

        return """    -${c_dim}--------------------------------------------------${c_reset}-
        ${c_white}                                ${c_red   }\\\\------${c_yellow}---//       ${c_reset}
        ${c_white}  ___  ___        _   ___  ___  ${c_red   }  \\\\---${c_yellow}--//        ${c_reset}
        ${c_white}   |  (___  |  | / _   |   |_   ${c_red   }    \\-${c_yellow}//         ${c_reset}
        ${c_white}  _|_  ___) |__| \\_/  _|_  |    ${c_red  }    ${c_yellow}//${c_red  } \\        ${c_reset}
        ${c_white}                                ${c_red   }  ${c_yellow}//---${c_red  }--\\\\       ${c_reset}
        ${c_white}                                ${c_red   }${c_yellow}//------${c_red  }---\\\\       ${c_reset}
        ${c_cyan}  isugifNF/nanoQCtrim  v${workflow.manifest.version}       ${c_reset}
        -${c_dim}--------------------------------------------------${c_reset}-
        """.stripIndent()
    }
