# North-China-Rainfall-2023

This repository contains the WRF model configuration, moisture-tracking setup, source-region mask-generation scripts, and plotting scripts used in the study:

**Land-Moisture Preconditioning and Oceanic Maintenance of the 2023 Extreme Rainfall over North China**

The corresponding source-region masks, shapefiles, processed datasets, and figure-source data used to support the manuscript are publicly archived on Zenodo.

**Zenodo dataset:**  
https://doi.org/10.5281/zenodo.22812836

## Overview

The study investigates the contribution of terrestrial and oceanic moisture sources to the 2023 extreme rainfall event over North China using the Weather Research and Forecasting (WRF) model and the WRF-WVTs moisture-tagging framework.

The moisture-tracking experiments were designed to quantify contributions from several terrestrial and oceanic source regions.

The complete raw WRF output is very large, with a total volume of approximately 2.6 TB. Therefore, the full `wrfout` archive is not stored on GitHub or Zenodo. Instead, the processed datasets and source materials used directly in the manuscript analyses and figures are publicly archived on Zenodo.

## Plotting scripts

The plotting/ directory contains the NCL scripts used to generate the manuscript figures.

The relationship between the manuscript figures, plotting methods, and source data is summarized below.

| Figure | Plotting method | Script / source data |
| --- | --- | --- |
| Figure 1 | NCL | `figure1.ncl` + shapefiles |
| Figure 2 | NCL | `figure2a.ncl`, `figure2b.ncl` + shapefiles |
| Figure 3 | Origin | Excel source data archived on Zenodo |
| Figure 4 | NCL | `figure4.ncl` |
| Figure 5 | NCL | `figure5.ncl` |
| Figure 6 | Origin | Excel source data archived on Zenodo |
| Figure 7 | NCL | `figure7.ncl` |
| Figure 8 | NCL | `figure8.ncl` + NetCDF source data |
| Figure 9 | NCL | `figure9.ncl` + CSV source data |
| Figure 10 | NCL | `figure10.ncl` + CSV source data |
| Figure 11 | NCL | `figure11.ncl` + CSV source data |

Figures 1, 2, 4, 5, 7, 8, 9, 10, and 11 were generated primarily using the NCAR Command Language (NCL).

Figures 3 and 6 were generated using Origin from the corresponding Excel source data.

## Figure source data

The datasets supporting the figures and quantitative analyses presented in the manuscript are publicly archived on Zenodo.

The archived materials include, where applicable:

- geographical shapefiles;
- Excel source data used for Origin-generated figures;
- NetCDF source data;
- CSV source data;
- processed WRF model fields;
- processed precipitation data;
- processed moisture-tracking data;
- WRF-WVTs source-region mask files; and
- other derived datasets used directly in the manuscript figures and analyses.

## Raw WRF output

The numerical experiments produced a very large volume of raw WRF output.

Six moisture-tagging experiments were performed, with multiple large wrfout files generated for each experiment.

The complete raw WRF output has a total data volume of approximately: 2.6 TB

Because of the very large storage and transfer requirements, the complete raw wrfout files are not archived in this GitHub repository or on Zenodo.

Instead, the processed datasets and figure-source data required to support the analyses, figures, and conclusions presented in the manuscript are publicly archived on Zenodo

Researchers who require access to the complete raw WRF output files for additional analyses may contact the author to discuss possible data transfer, subject to storage and transfer limitations.

## WRF-WVTs reference

Insua-Costa, D., & Miguez-Macho, G. (2018). A new moisture tagging capability in the Weather Research and Forecasting model: formulation, validation and application to the 2014 Great Lake-effect snowstorm. Earth System Dynamics, 9, 167–185.

https://doi.org/10.5194/esd-9-167-2018

## Contact

For questions regarding the repository, processed datasets, moisture-tracking setup, or requests concerning the complete raw WRF output:

Sun

Email:
1514777867@qq.com
