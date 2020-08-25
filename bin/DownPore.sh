#!/bin/bash

numThreads=30

## Download DownPore

wget https://github.com/jteutenberg/downpore/releases/download/0.3.3/downpore.gz
gunzip downpore.gz
chmod 755 downpore

## add to path

export PATH=`pwd`:$PATH

## Grab the adapter files

wget https://github.com/jteutenberg/downpore/raw/master/data/adapters_front.fasta
wget https://github.com/jteutenberg/downpore/raw/master/data/adapters_back.fasta

## Run Downpore

downpore trim -i $1 -f adapters_front.fasta -b adapters_back.fasta --himem true --num_workers ${numThreads} > ${1%%.*}_adaptersRemoved.fastq
