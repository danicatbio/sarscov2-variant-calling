# SARS-CoV-2 — Pipeline manual de variant calling (Illumina, amplicón)

Pipeline **reference-based** de secuenciación de SARS-CoV-2 ejecutado paso a paso (sin
automatizar), desde las lecturas crudas hasta la lista de variantes. Proyecto de
aprendizaje del Máster en Bioinformática (Universitat de València), reproduciendo a mano
el flujo de un análisis de genómica viral para entender **el porqué de cada paso**.

> Nota: los datos crudos (FASTQ, SAM, BAM) no se incluyen en el repositorio por tamaño
> (ver `.gitignore`). El script `scripts/pipeline.sh` los descarga y regenera.

## Flujo

```
descarga (ENA) → QC (FastQC/MultiQC) → recorte (fastp) → mapeo (bwa mem)
   → BAM ordenado + indexado (samtools) → cobertura (samtools coverage)
   → variant calling (FreeBayes) → VCF filtrado (bcftools)
```

## Datos

- **Muestra:** `ERR5743893` (European Nucleotide Archive), Illumina MiSeq, paired-end.
- **Referencia:** Wuhan-Hu-1, `MN908947.3` (~29,9 kb).
- Protocolo de amplicones (ARTIC), típico de vigilancia genómica de SARS-CoV-2.

## Herramientas

`sra-tools` · `FastQC` · `MultiQC` · `fastp` · `bwa` · `samtools` · `FreeBayes` ·
`bcftools` · `IGV`. Entorno gestionado con conda/mamba (bioconda).

## Cómo reproducirlo

```bash
# Requiere un entorno conda con las herramientas anteriores
bash scripts/pipeline.sh
```

El script está comentado paso a paso y usa rutas relativas; ajústalas a tu equipo.

## Resultados (muestra ERR5743893)

- **Cobertura:** breadth 90,7 % del genoma con ≥1 lectura; profundidad media ~1.896×
  (muy desigual, típico de amplicones). Las zonas sin cubrir (sobre todo el extremo 3')
  salen como `N` en el consenso.
- **Variantes:** 21 tras filtrar por `QUAL>20 && AF=1` (75 registros sin filtrar) frente a
  la referencia. Incluyen **C241T** y **C3037T**, mutaciones que definen linaje.
- Visualización de los alineamientos y las variantes en IGV.

## Qué aprendí

- Estructura del FASTQ, calidad Phred (`Q = ASCII − 33`) y su lectura en FastQC.
- Por qué la calidad cae al final de las lecturas (*phasing* de Illumina).
- Mapeo, formatos SAM/BAM y la cadena CIGAR; la diferencia entre **profundidad** y
  **amplitud (breadth)** de cobertura.
- Variant calling y, sobre todo, que **el recuento de variantes depende del filtro**:
  no es un número absoluto, hay que declarar el criterio.

## Contexto

Inspirado en el curso *Bioinformatics for Biologists* (Wellcome Connecting Science,
FutureLearn). Este repositorio es mi reimplementación manual y documentada del flujo.

---
Daniel Catalán · Máster en Bioinformática (UV) · github.com/danicatbio
