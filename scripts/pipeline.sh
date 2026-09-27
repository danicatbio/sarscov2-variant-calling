#!/usr/bin/env bash
# =============================================================================
# Pipeline manual de variant calling — SARS-CoV-2 (Illumina, amplicón)
# De las lecturas crudas al VCF, paso a paso.
# Muestra de ejemplo: ERR5743893 · Referencia: Wuhan-Hu-1 (MN908947.3)
#
# Requiere un entorno conda con: sra-tools, fastqc, multiqc, fastp, bwa,
# samtools, freebayes, bcftools.  (mamba install ...)
# Uso:  bash scripts/pipeline.sh
# =============================================================================

set -euo pipefail   # corta el script si algo falla (buena práctica)

SAMPLE="ERR5743893"        # accession de la muestra en el ENA
REF="MN908947.fasta"       # genoma de referencia (Wuhan-Hu-1)
THREADS=4                  # hilos de CPU (ajusta a tu equipo)

mkdir -p data qc trimmed mapping variants

# -----------------------------------------------------------------------------
# 1. Descarga de las lecturas (paired-end). --split-3 separa R1/R2 y aparta
#    las lecturas huérfanas, dejando R1 y R2 sincronizados.
# -----------------------------------------------------------------------------
fastq-dump --split-3 --outdir data "$SAMPLE"

# -----------------------------------------------------------------------------
# 2. Descarga de la referencia (si no está) y su índice para bwa.
# -----------------------------------------------------------------------------
[ -f "$REF" ] || wget -O "$REF" \
  "https://www.ebi.ac.uk/ena/browser/api/fasta/MN908947.3?download=true"
bwa index "$REF"
samtools faidx "$REF"      # índice .fai (lo necesita IGV)

# -----------------------------------------------------------------------------
# 3. Control de calidad de las lecturas crudas.
# -----------------------------------------------------------------------------
fastqc -o qc data/${SAMPLE}_1.fastq data/${SAMPLE}_2.fastq

# -----------------------------------------------------------------------------
# 4. Recorte de adaptadores y de la cola de mala calidad (por el phasing).
# -----------------------------------------------------------------------------
fastp \
  -i data/${SAMPLE}_1.fastq -I data/${SAMPLE}_2.fastq \
  -o trimmed/${SAMPLE}_1.trim.fastq -O trimmed/${SAMPLE}_2.trim.fastq \
  --html qc/${SAMPLE}_fastp.html --json qc/${SAMPLE}_fastp.json

# -----------------------------------------------------------------------------
# 5. Mapeo contra la referencia -> SAM.
# -----------------------------------------------------------------------------
bwa mem -t "$THREADS" "$REF" \
  trimmed/${SAMPLE}_1.trim.fastq trimmed/${SAMPLE}_2.trim.fastq \
  > mapping/${SAMPLE}.sam

# -----------------------------------------------------------------------------
# 6. SAM -> BAM -> ordenar por posición -> indexar.
#    (ojo con la RAM: threads x -m; en WSL bajar si hace falta)
# -----------------------------------------------------------------------------
samtools view -@ "$THREADS" -b mapping/${SAMPLE}.sam > mapping/${SAMPLE}.bam
samtools sort  -@ "$THREADS" -m 512M \
  -o mapping/${SAMPLE}.sorted.bam mapping/${SAMPLE}.bam
samtools index mapping/${SAMPLE}.sorted.bam

# -----------------------------------------------------------------------------
# 7. Métricas de cobertura (breadth, profundidad media...).
# -----------------------------------------------------------------------------
samtools coverage mapping/${SAMPLE}.sorted.bam \
  | tee variants/${SAMPLE}_coverage.txt

# -----------------------------------------------------------------------------
# 8. Variant calling con FreeBayes -> VCF -> comprimir + indexar.
# -----------------------------------------------------------------------------
freebayes -f "$REF" mapping/${SAMPLE}.sorted.bam > variants/${SAMPLE}.vcf
bgzip -f variants/${SAMPLE}.vcf
tabix -p vcf variants/${SAMPLE}.vcf.gz

# -----------------------------------------------------------------------------
# 9. Filtrar variantes reales (alta confianza y fijadas) y contarlas.
#    El recuento DEPENDE del filtro: aquí QUAL>20 y AF=1.
# -----------------------------------------------------------------------------
bcftools view -i 'QUAL>20 && AF=1' variants/${SAMPLE}.vcf.gz \
  -Oz -o variants/${SAMPLE}.filtered.vcf.gz
tabix -p vcf variants/${SAMPLE}.filtered.vcf.gz

echo "Variantes filtradas (QUAL>20 && AF=1):"
bcftools view -H variants/${SAMPLE}.filtered.vcf.gz | wc -l

echo "Pipeline terminado. Resultados en variants/ ."
