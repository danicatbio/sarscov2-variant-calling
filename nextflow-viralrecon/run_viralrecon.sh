#!/usr/bin/env bash
# =============================================================================
# Análisis en lote de 5 genomas de SARS-CoV-2 con nf-core/viralrecon
# (pipeline de la comunidad nf-core, ejecutado con Nextflow + Docker)
#
# Hace de forma automatizada y en paralelo lo mismo que el pipeline manual
# (scripts/pipeline.sh), pero para varias muestras a la vez:
#   QC (fastp) -> mapeo (bowtie2) -> recorte de primers de amplicón (iVar)
#   -> variantes -> genoma consenso -> informe MultiQC.
#
# Requisitos: Nextflow, Docker (demonio arrancado) y un samplesheet.csv.
# En WSL, arrancar Docker antes:  sudo service docker start
# =============================================================================

# Nota sobre versiones (imprescindible para que no falle):
#   NXF_VER=23.10.1 -> fija una versión de Nextflow compatible con viralrecon 2.6.0
#   -r 2.6.0        -> fija la versión del pipeline
#   (y Java 17: 'mamba install openjdk=17' si Nextflow se queja de "class file version")

NXF_VER=23.10.1 nextflow run nf-core/viralrecon -r 2.6.0 -profile docker \
  --max_memory '6.GB' --max_cpus 8 \
  --input samplesheet.csv \
  --outdir results/viralrecon \
  --platform illumina \
  --protocol amplicon \
  --genome 'MN908947.3' \
  --primer_set artic \
  --primer_set_version 3 \
  --skip_kraken2 \
  --skip_assembly \
  --skip_pangolin \
  --skip_nextclade \
  --skip_asciigenome \
  -resume

# --max_memory / --max_cpus: ajustar a los recursos de la máquina.
#   Aquí, para un WSL con ~7,6 GiB de RAM: tope de 6 GB por proceso.
# --protocol amplicon + --primer_set artic v3: recorta los cebadores ARTIC.
# --skip_*: se saltan pasos pesados (host removal, ensamblado, asignación de linaje)
#   para ir más rápido en un portátil.
# -resume: si algo falla, al relanzar continúa desde donde se quedó.
