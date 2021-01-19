#! /usr/bin/env nextflow

/*************************************
 nextflow nanoQCtrim
 *************************************/

nanoplot_container = 'quay.io/biocontainers/nanoplot:1.32.0--py_0'
downpore_container = 'quay.io/biocontainers/downpore:0.3.3--h375a9b1_0'

 def helpMessage() {
     log.info isuGIFHeader()
     log.info """
      Usage:
      The typical command for running the pipeline is as follows:
      nextflow run isugifNF/nanoQCtrim --fastqs "/Path/to/rawdata/folder/*.fastq" -profile condo

      Mandatory arguments:

      --fastqs                      fastq files to run nanoplot on. (/data/*.fastq)

      Optional arguments:
      --outdir                      Output directory to place final BLAST output
      --threads                      Number of CPUs to use during the NanoPlot job [16]
      --queueSize                    Maximum number of jobs to be queued [18]
      --account                      Some HPCs require you supply an account name for tracking usage.  You can supply that here.
      --help                         This usage statement.
     """
}

     // Show help message
     if (params.help) {
         helpMessage()
         exit 0
     }


//fastq_reads_qc = Channel
//                   .fromPath(params.fastqs)
//                   .map { file -> tuple(file.simpleName, file) }

//fastq_reads_trim = Channel
//                   .fromPath(params.fastqs)
//                   .map { file -> tuple(file.simpleName, file) }

Channel
  .fromPath(params.fastqs)
  .map { file -> tuple(file.simpleName, file) }
  .into { fastq_reads_qc; fastq_reads_trim }

process runNanoPlot {

  container = "$nanoplot_container"

  publishDir "${params.outdir}/nanoplots/", mode: 'copy', pattern: '*/*.png'
  publishDir "${params.outdir}/pdf", mode: 'copy', pattern: '*/*.pdf'
  publishDir "${params.outdir}/nanoplots/log", mode: 'copy', pattern: '*/*.log'
  publishDir "${params.outdir}/nanoplots/", mode: 'copy', pattern: '*/*.md'
  publishDir "${params.outdir}/nanoplots/", mode: 'copy', pattern: '*/*.txt'

  input:
  set val(label), file(fastq) from fastq_reads_qc


  output:
  file("*/*.png") into nanoplot_png
  file("*/*.pdf") into nanoplot_pdf
  file("*/*.log") into nanoplot_log
  file("*/*.md") into nanoplot_md
  file("*/*.txt") into nanoplot_md2

  script:

  """
  NanoPlot -t ${params.threads} --huge --verbose --store -o ${label} -p ${label}_  -f png --loglength --dpi 300 --plots {'kde','hex','dot'} --title ${label}" Nanopore Sequence" --N50 --fastq_rich ${fastq}
  NanoPlot -t ${params.threads} --huge --verbose --store -o ${label} -p ${label}_ -f pdf --loglength --plots {'kde','hex','dot'} --title ${label}" Nanopore Sequence" --N50 --pickle ${label}/${label}_NanoPlot-data.pickle

  ## Run Markdown generator
  nanoPlotMDGenerator.sh ${label}

  """

}


process getAdapters {
// a separate process was required to run wget as wget would not run successfully in the downpore container

publishDir "${params.outdir}/adapters", mode: 'copy', pattern: 'adapters_*.fasta'
publishDir "${params.outdir}", mode: 'copy', pattern: 'downpore'

output:
//file("downpore") into downpore_ch
file("adapters_front.fasta") into adapters_front_ch
file("adapters_back.fasta") into adapters_back_ch

script:

"""
 # Download downpore
 # wget https://github.com/jteutenberg/downpore/releases/download/0.3.3/downpore.gz
 # gunzip downpore.gz
 # chmod 755 downpore
 # export PATH=`pwd`:$PATH

 # Download Adapters
  wget https://github.com/jteutenberg/downpore/raw/master/data/adapters_front.fasta
  wget https://github.com/jteutenberg/downpore/raw/master/data/adapters_back.fasta
"""

}


process runDownPore {

  container = "$downpore_container"


  publishDir "${params.outdir}/trimmedReads", mode: 'copy', pattern: '*_adaptersRemoved.fastq'


  input:
  set val(label), file(fastq) from fastq_reads_trim
  file front from adapters_front_ch.val
  file back from adapters_back_ch.val

  output:
  file("*_adaptersRemoved.fastq") into trimmed_reads


  script:
  """


  downpore trim -v 2 -i ${fastq} -f ${front} -b ${back}  --num_workers ${params.threads} > ${label}_adaptersRemoved.fastq
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
