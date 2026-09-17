# North-China-Rainfall-2023

This repository contains the model configuration, moisture-tracking setup, data-processing scripts, and visualization scripts used for the study:

**Land-Moisture Preconditioning and Oceanic Maintenance of the 2023 Extreme Rainfall over North China**

## Repository structure

- `WRF_configuration/`  
  WRF model configuration files used in the numerical simulations.

- `moisture_tracking/`  
  Source-region shapefiles and scripts used to generate the WRF-WVTs source-region masks.

- `analysis/`  
  Scripts used for processing and analyzing WRF and moisture-tracking outputs.

- `plotting/`  
  Scripts used to generate the figures presented in the manuscript.

## WRF configuration

The Weather Research and Forecasting (WRF) model was used for the numerical simulations. The model configuration files used in this study are provided in the `WRF_configuration` directory.

## Moisture tracking

Moisture-source attribution was performed using the WRF-WVTs moisture tagging framework.

WRF-WVTs:  
https://github.com/damianinsua/WRF-WVTs

The geographical source regions and scripts used to generate the WRF-WVTs source-region masks are provided in the `moisture_tracking` directory.

The source-region mask files used in the experiments are publicly archived on Zenodo:

https://doi.org/10.5281/zenodo.22803751

## Source regions

The moisture-source regions considered in this study include:

- All
- Bay of Bengal
- India
- South China
- South China Sea
- Western Pacific

## Data availability

The WRF-WVTs source-region mask files supporting this study are available at:

Sun, H. (2026). *Moisture-Tracking Source Masks for the 2023 Extreme Rainfall over North China*. Zenodo.  
https://doi.org/10.5281/zenodo.22803751

Additional processed datasets supporting the figures and analyses of the manuscript will be archived in the associated research-data repository.

## Reference

Insua-Costa, D., & Miguez-Macho, G. (2018). A new moisture tagging capability in the Weather Research and Forecasting model: formulation, validation and application to the 2014 Great Lake-effect snowstorm. *Earth System Dynamics, 9*, 167–185.  
https://doi.org/10.5194/esd-9-167-2018
