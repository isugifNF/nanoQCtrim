# nanoQCtrim


```
----------------------------------------------------
                                    \\---------//       
      ___  ___        _   ___  ___    \\-----//        
       |  (___  |  | / _   |   |_       \-//         
      _|_  ___) |__| \_/  _|_  |        // \        
                                      //-----\\       
                                    //---------\\       
      isugifNF/nanoQCtrim  v1.0.0       
    ----------------------------------------------------
```

[Genome Informatics Facility](https://gif.biotech.iastate.edu/) | [![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A519.10.0-brightgreen.svg)](https://www.nextflow.io/)

---

### Introduction

**isugifNF/nanoQCtrim** is a nextflow pipeline to assess the nanopore read quality using [Nanoplot](https://github.com/wdecoster/NanoPlot) and trim adaptors using [downpore](https://github.com/jteutenberg/downpore).



### Installation and running

<details><summary>See usage statement</summary>

<pre>
```
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
```

</pre>
</details>


### Expected Output

* out_dir/nanoplot/fileName_combined
  * fileName_NanoStats.md -- NanoPlotQC summary in markdown format
  * many png files for each of the plots generated.
* out_dir/downpore/
  * fileName__adaptersRemoved.fastq -- Trimmed read output from downpore.



### Dependencies if running locally

Nextflow is written in groovy which requires java version 1.8 or greater (check version using `java -version`). But otherwise can be installed if you have a working linux command-line.

```
java -version
curl -s https://get.nextflow.io | bash

# Check to see if nextflow is created
ls -ltr nextflow
#> total 32
#> -rwx--x--x  1 username  staff    15K Aug 12 12:47 nextflow
```


### Credits

This workflow was built by Andrew Severin ([@isugif](https://github.com/isugif))


### Potential Errors

* #### ssh://git@github.com/isugifNF/assemblyStats.git: Auth fail

  This occurs if you have not set up github authorization on your remote machine yet.  See this [Introduction to Github](https://bioinformaticsworkbook.org/Appendix/github/introgithub#gsc.tab=0) Tutorial on how to set up an ssh key.
* #### WARN: Singularity cache directory has not been defined
  If you are planning on running this program more than once or more than one workflow it is best to set the NXF_SINGULARITY_CACHEDIR to a common location
  ```
  export NXF_SINGULARITY_CACHEDIR=/location/of/singularity/container/folder
  ```
  Place that in your `.bashrc` file.
