# SARS-CoV-2 — Variant calling: pipeline manual + análisis automatizado

Dos formas de hacer el mismo análisis de genómica viral (SARS-CoV-2, Illumina, amplicón),
de las lecturas crudas a las variantes:

1. **Pipeline manual, paso a paso** (`scripts/pipeline.sh`) — una muestra, ejecutando cada
   herramienta a mano para entender el porqué de cada paso.
2. **Análisis automatizado en lote** (`nextflow-viralrecon/`) — cinco muestras a la vez con
   el pipeline de la comunidad `nf-core/viralrecon` (Nextflow + Docker).

Proyecto de aprendizaje del Máster en Bioinformática (Universitat de València).

> Los datos crudos (FASTQ, BAM, salidas de viralrecon) no se incluyen por tamaño
> (ver `.gitignore`); los scripts los descargan y regeneran.

## Parte 1 — Pipeline manual (`scripts/pipeline.sh`)

```
descarga (ENA) → QC (FastQC) → recorte (fastp) → mapeo (bwa mem)
   → BAM ordenado + indexado (samtools) → cobertura → variant calling (FreeBayes)
   → VCF filtrado (bcftools)
```

- **Muestra:** `ERR5743893` (ENA), Illumina MiSeq paired-end. **Referencia:** Wuhan-Hu-1
  (`MN908947.3`).
- **Resultados:** breadth 90,7 % (≥1x), profundidad media ~1 896×, **21 variantes** tras
  filtrar `QUAL>20 && AF=1` (75 sin filtrar) frente a la referencia. Incluyen C241T y
  C3037T (mutaciones de linaje).
- Herramientas: `sra-tools` · `FastQC` · `fastp` · `bwa` · `samtools` · `FreeBayes` ·
  `bcftools` · `IGV`.

## Parte 2 — Automatizado con nf-core/viralrecon (`nextflow-viralrecon/`)

El mismo análisis, pero para **5 genomas en paralelo**, con el pipeline
[`nf-core/viralrecon`](https://nf-co.re/viralrecon) (Nextflow + Docker). Incluye el comando
usado (`run_viralrecon.sh`), un `samplesheet.example.csv` y la tabla de resultados con la
interpretación en [`RESULTS.md`](nextflow-viralrecon/RESULTS.md).

Los 5 genomas salieron casi completos (≥98 % a ≥10x). Detalle y lecciones en RESULTS.md.

## Qué aprendí

- Estructura del FASTQ, calidad Phred (`Q = ASCII − 33`) y su lectura en FastQC.
- Por qué la calidad cae al final de las lecturas (*phasing* de Illumina).
- Mapeo, formatos SAM/BAM y la cadena CIGAR; la diferencia entre **profundidad** y
  **amplitud (breadth)** de cobertura, y que la profundidad alta no garantiza completitud.
- Variant calling y que **el recuento de variantes depende del filtro/método**, no es
  absoluto.
- Del comando a mano al pipeline reproducible: **Nextflow / nf-core**, contenedores
  (Docker), ajuste de recursos y resolución de conflictos de versiones.

## Contexto

Inspirado en el curso *Bioinformatics for Biologists* (Wellcome Connecting Science,
FutureLearn). Reimplementación propia, manual y documentada, más el uso del pipeline
comunitario nf-core/viralrecon para el análisis en lote.

---
Daniel Catalán · Máster en Bioinformática (UV) · github.com/danicatbio
