# North-China-Rainfall-2023

This repository contains the WRF model configuration, moisture-tracking setup, source-region mask-generation scripts, and plotting scripts used in the study:

**Land-Moisture Preconditioning and Oceanic Maintenance of the 2023 Extreme Rainfall over North China**

The corresponding source-region masks, shapefiles, processed datasets, and figure-source data used to support the manuscript are publicly archived on Zenodo.

**Zenodo dataset:**  
https://doi.org/10.5281/zenodo.22812836


## Overview

The study investigates the contribution of terrestrial and oceanic moisture sources to the 2023 extreme rainfall event over North China using the Weather Research and Forecasting (WRF) model and the WRF-WVTs moisture-tagging framework.

The moisture-tracking experiments were designed to quantify contributions from several terrestrial and oceanic source regions.

Six moisture-tagging experiments were conducted for:

- All
- Bay of Bengal
- India
- South China
- South China Sea
- Western Pacific

The complete raw WRF output is very large, with a total volume of approximately 2.6 TB. Therefore, the full `wrfout` archive is not stored on GitHub or Zenodo. Instead, the processed datasets and source materials used directly in the manuscript analyses and figures are publicly archived on Zenodo.


## Repository structure

```text
North-China-Rainfall-2023/
│
├── WRF_configuration/
│   ├── namelist.input
│   └── README.md
│
├── analysis/
│   └── README.md
│
├── moisture_tracking/
│   ├── source_regions/
│   ├── 3Dsource.py
│   ├── trmask3Dn.py
│   └── README.md
│
├── plotting/
│   ├── figure1.ncl
│   ├── figure2a.ncl
│   ├── figure2b.ncl
│   ├── figure4.ncl
│   ├── figure5.ncl
│   ├── figure7.ncl
│   ├── figure8.ncl
│   ├── figure9.ncl
│   ├── figure10.ncl
│   ├── figure11.ncl
│   └── README.md
│
└── README.md
WRF configuration

The Weather Research and Forecasting (WRF) model was used for the numerical simulations.

The WRF_configuration/ directory contains the WRF configuration used in this study, including:

namelist.input

The file records the model-domain, physics, time-stepping, and other WRF settings used in the simulations.

Users attempting to reproduce the simulations should modify local paths and environment-specific settings as required.

Moisture tracking

Moisture-source attribution was performed using the WRF-WVTs moisture-tagging framework coupled with WRF.

WRF-WVTs repository:

https://github.com/damianinsua/WRF-WVTs

The moisture_tracking/ directory contains the source-region information and scripts used to construct the moisture-tagging masks.

Source regions

The moisture-source regions considered in this study include:

All
Bay of Bengal
India
South China
South China Sea
Western Pacific

The geographical definitions of the source regions are provided through the corresponding shapefiles.

Mask-generation scripts

The following scripts were used to map the geographical source regions onto the WRF model grid:

3Dsource.py
trmask3Dn.py

These scripts were used to generate the WRF-WVTs source-region mask files required for the moisture-tagging experiments.

WRF-WVTs source masks

Each moisture-tagging experiment used a source-region mask file named:

trmask_d01

Six trmask_d01 files were generated, corresponding to the six moisture-source experiments.

Because these mask files are relatively large, they are not stored directly in this GitHub repository.

They are publicly archived on Zenodo:

https://doi.org/10.5281/zenodo.22812836

Plotting scripts

The plotting/ directory contains the NCL scripts used to generate the manuscript figures.

The relationship between the manuscript figures, plotting methods, and source data is summarized below.

Figure	Plotting method	Script / source data
Figure 1	NCL	figure1.ncl + shapefiles
Figure 2	NCL	figure2a.ncl, figure2b.ncl + shapefiles
Figure 3	Origin	Excel source data archived on Zenodo
Figure 4	NCL	figure4.ncl
Figure 5	NCL	figure5.ncl
Figure 6	Origin	Excel source data archived on Zenodo
Figure 7	NCL	figure7.ncl
Figure 8	NCL	figure8.ncl + NetCDF source data
Figure 9	NCL	figure9.ncl + CSV source data
Figure 10	NCL	figure10.ncl + CSV source data
Figure 11	NCL	figure11.ncl + CSV source data

Figures 1, 2, 4, 5, 7, 8, 9, 10, and 11 were generated primarily using the NCAR Command Language (NCL).

Figures 3 and 6 were generated using Origin from the corresponding Excel source data.

Figure source data

The datasets used to support the manuscript figures are archived on Zenodo.

The archived materials include, where applicable:

shapefiles;
Excel source data;
NetCDF source data;
CSV source data;
processed WRF fields;
processed precipitation data;
processed moisture-tracking data;
source-region mask files;
other derived quantities used directly in manuscript figures and analyses.

Zenodo DOI:

https://doi.org/10.5281/zenodo.22812836

Zenodo archive contents

The current archived version contains three main data packages.

WRF-WVTs_source_masks.zip

Contains the WRF-WVTs source-region mask files used in the six moisture-tagging experiments.

The archive contains separate directories for:

All/
Bay_of_Bengal/
India/
South_China/
South_China_Sea/
Western_Pacific/

Each directory contains the corresponding:

trmask_d01

The original filename used during the WRF-WVTs simulations has been preserved.

shapefile.zip

Contains geographical shapefiles used in the moisture-tracking setup and/or manuscript plotting.

A complete shapefile dataset may include:

.shp
.shx
.dbf
.prj
.cpg

depending on the original source.

North_China_Rainfall_Figure_Source_Data.rar

Contains the processed datasets and figure-source materials used to support the manuscript figures.

These materials include Excel, NetCDF, CSV, and other processed datasets where applicable.

The archive includes source data used for Origin-generated figures and input data used by the corresponding NCL plotting scripts.

Raw WRF output

The numerical experiments produced a very large volume of raw WRF output.

Six moisture-tagging experiments were performed, with multiple large wrfout files generated for each experiment.

The complete raw WRF output has a total data volume of approximately:

2.6 TB

Because of the very large storage and transfer requirements, the complete raw wrfout files are not archived in this GitHub repository or on Zenodo.

Instead, the processed datasets and figure-source data required to support the analyses, figures, and conclusions presented in the manuscript are publicly archived on Zenodo:

https://doi.org/10.5281/zenodo.22812836

Researchers who require access to the complete raw WRF output files for additional analyses may contact the corresponding author to discuss possible data transfer, subject to storage and transfer limitations.

Email: 1514777867@qq.com

Data availability

The WRF-WVTs source-region masks, geographical shapefiles, processed datasets, and figure-source data supporting the manuscript are publicly available on Zenodo:

Sun, H. (2026). Data and Figure Source Materials for the 2023 Extreme Rainfall over North China. Zenodo.

https://doi.org/10.5281/zenodo.22812836

The associated WRF configuration, moisture-tracking scripts, source-mask-generation scripts, and plotting scripts are publicly available in this GitHub repository:

https://github.com/1514777867/North-China-Rainfall-2023

Software

The following software and tools were used in the numerical experiments, data processing, and figure preparation.

Weather Research and Forecasting model

The Weather Research and Forecasting (WRF) model was used to perform the numerical simulations.

WRF-WVTs

WRF-WVTs was used for moisture-source tagging and attribution.

Repository:

https://github.com/damianinsua/WRF-WVTs

NCAR Command Language

The NCAR Command Language (NCL) was used for data processing and figure generation.

Depending on the individual script, the following standard NCL libraries may be required:

gsn_code.ncl
gsn_csm.ncl
contributed.ncl
WRFUserARW.ncl
Python

Python was used for source-region processing, mask generation, and selected data-processing tasks.

Origin

Origin was used to generate Figures 3 and 6 from the corresponding Excel source data.

Reproducing the figures

To reproduce an NCL-generated figure:

Download or clone this GitHub repository.
Download the associated figure-source data from Zenodo.
Extract the required source data.
Modify the file paths in the corresponding NCL script according to the local computing environment.
Run the NCL script.

For example:

ncl plotting/figure8.ncl

Some scripts contain absolute paths corresponding to the original computational environment. These paths should be replaced with the locations of the downloaded source data on the user's system.

For Figures 3 and 6, the underlying Excel source data are provided in the Zenodo archive and the final figures were generated using Origin.

Reproducing the moisture-source masks

The source-region shapefiles and the scripts:

3Dsource.py
trmask3Dn.py

are provided in the moisture_tracking/ directory.

These scripts were used to map the geographical source regions onto the WRF model grid and construct the source-region masks required by WRF-WVTs.

The resulting trmask_d01 files are archived on Zenodo:

https://doi.org/10.5281/zenodo.22812836

Users may need to modify file paths, WRF grid-file locations, and local Python environments before running the scripts.

Notes on file paths

Some scripts retain paths from the original high-performance computing environment used for the study.

For example, a script may contain a path such as:

/public1/home/...

These paths are specific to the original computing environment and should be modified before running the scripts on another system.

The scientific calculations and plotting procedures are unaffected by these local path changes.

Versioned data archive

The dataset used for the current manuscript submission corresponds to the following Zenodo version:

Version v3

DOI:

https://doi.org/10.5281/zenodo.22812836

This version-specific DOI is recommended when referring to the exact dataset used for the current manuscript submission.

Citation

If using the archived dataset, please cite:

Sun, H. (2026). Data and Figure Source Materials for the 2023 Extreme Rainfall over North China. Zenodo.
https://doi.org/10.5281/zenodo.22812836

WRF-WVTs reference

Insua-Costa, D., & Miguez-Macho, G. (2018). A new moisture tagging capability in the Weather Research and Forecasting model: formulation, validation and application to the 2014 Great Lake-effect snowstorm. Earth System Dynamics, 9, 167–185.

https://doi.org/10.5194/esd-9-167-2018

Contact

For questions regarding the repository, processed datasets, moisture-tracking setup, or requests concerning the complete raw WRF output:

Huihui Sun

Email:
1514777867@qq.com
