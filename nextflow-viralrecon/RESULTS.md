# Resultados — análisis en lote con nf-core/viralrecon

Cinco genomas de SARS-CoV-2 analizados en paralelo con `nf-core/viralrecon` (Nextflow +
Docker). Métricas extraídas del informe MultiQC ("Variant calling metrics").

| Muestra | Lecturas entrada | Mapeadas | Prof. mediana | % ≥1x | % ≥10x | SNPs | Indels | Ns/100 kb |
|---|---|---|---|---|---|---|---|---|
| SRR13500958 | 147 798 | 117 027 | 749× | 100 | 100 | 20 | 0 | **405** |
| ERR5181310 | 1 825 254 | 1 466 126 | 5 790× | 99 | 99 | 26 | 6 | 1 354 |
| ERR5405022 | 309 132 | 199 028 | 604× | 100 | 98 | 30 | 4 | 1 978 |
| ERR5556343 | 433 660 | 296 476 | 1 078× | 100 | 98 | 32 | 1 | 2 114 |
| ERR5743893 | 396 664 | 194 935 | 718× | 99 | 98 | 27 | 1 | 2 221 |

(ordenadas de más a menos completo por Ns/100 kb; menor = mejor)

## Interpretación

- **Todas las muestras dieron genomas casi completos** (≥98 % del genoma con profundidad
  fiable ≥10x). La métrica de calidad clave es **Ns per 100 kb**: los huecos del consenso.
  `Ns/100kb ÷ 1000` = % del genoma sin resolver (405 → 0,4 %; 2 221 → 2,2 %).
- **Profundidad ≠ completitud.** ERR5556343 tiene más profundidad mediana (1 078×) que
  SRR13500958 (749×) pero **5 veces más Ns** (2 114 vs 405). Lo que determina la
  completitud no es cuánta cobertura hay de media, sino **dónde** cae: los huecos vienen
  de amplicones que no amplificaron (dropouts), no de falta de lecturas.
- **El recuento de variantes depende del método.** Para ERR5743893, viralrecon (iVar)
  reporta 27 SNPs; el mismo dato con FreeBayes a mano dio 21 variantes filtradas (75 sin
  filtrar). No es un número absoluto: hay que declarar herramienta y filtro.

## Notas de ejecución (gotchas de versiones)

- Nextflow demasiado nuevo rechaza pipelines antiguos → se fija con `NXF_VER=23.10.1`.
- Java demasiado nuevo rompe Nextflow ("class file major version 69" = Java 25) →
  `mamba install openjdk=17`.
- El pipeline se ancla a su versión con `-r 2.6.0`.
- En WSL, el demonio de Docker no arranca solo: `sudo service docker start`.
