#!/bin/bash

#========================
#  SIMULCRO PIPELINE
#========================

# El siguiente script debeejecutarse dentro del entorno testim con las siguientes herramientas instaladas
# disponibles en el entorno rna-seq.yaml una vez finalizado el proceso.

#   - fastqc: conda install -y fastqc

#   - cutadapt: conda install -y cutadapt

#   - star: conda install -y star

#   - multiqc: conda install -y multiqc


# En primer lugar para facilitar la gestión del flujo de trabajo vamos aguardar una url con el directorio de trabajo.

  export WD=$(pwd)


# 1. DESCARGA DEL GENOMA

# Descargar genoma de E.coli en el repositorio desde NCBI.
# Preparar un directorio que contenga el genoma e indicar la ruta y el nombre con el que se van a guardar.
# Finalmente se descomprime el archivo .FASTA con el genoma y sin mantener el original.

    echo "Creating directory to genome..."
    mkdir -p res/genome
    echo

    echo "Dowloading E.coli genome..."
    wget -O $WD/res/genome/ecoli.fasta.gz ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz
    echo

    echo "Unzip E.coli genome..."
    gunzip res/genome/ecoli.fasta.gz
    echo

# 2. INDEXADO DEL GENOMA

# Se trasladará la orden de indexación en start del script analyse_sample.sh a este script ya que solo debe aplicarse una vez en este archivo (res/genome/ecoli.fasta)

    echo "Running STAR index..."
    mkdir -p res/genome/star_index
    STAR --runThreadN 4 --runMode genomeGenerate --genomeDir res/genome/star_index/ --genomeFastaFiles res/genome/ecoli.fasta --genomeSAindexNbases 9
    echo


# 3. FASTQC, TRIMMING Y ALINEAMIENTO

# Llamar al script analyse_sample.sh para cada una de las muestras del directorio data.
# Aportar el sample_id de cada muestra.

    for sid in $(ls data/*.fastq.gz | cut -d"_" -f1 | sed "s:data/::" | sort | uniq)
    do

       bash scripts/analyse_sample.sh $sid

    done


# 4. MULTIQC

# Crear el informe final con mulitqc de todas las muestras.

    echo "Creating final document..."
    multiqc -o out/multiqc $WD


# 5. GUARDAR ENTORNO DE trabajo

# Crear un directorio en el que se guardará la configuración del entorno testsim.

    mkdir envs
    conda env export > envs/rna-seq.yaml
