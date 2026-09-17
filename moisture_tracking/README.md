# Moisture Tracking

Moisture source tracking in this study was performed using the WRF-WVTs moisture tagging framework coupled with the Weather Research and Forecasting (WRF) model.

WRF-WVTs:  
https://github.com/damianinsua/WRF-WVTs

## Source regions

The geographical source regions used for moisture tagging are provided in the `source_regions` directory. These shapefiles define the oceanic and terrestrial moisture-source regions used in the experiments.

The source regions include:

- All
- Bay of Bengal
- India
- South China
- South China Sea
- Western Pacific

## Mask generation

The scripts `3Dsource.py` and `trmask3Dn.py` were used to map the geographical source regions onto the WRF model grid and generate the source-region masks required by WRF-WVTs.

Six source-region mask files were generated for the moisture-tracking experiments. To preserve the original configuration used in the simulations, the mask files are stored separately according to their corresponding source regions.

The source-region mask files (`trmask_d01`) used in the WRF-WVTs experiments are archived on Zenodo:

https://doi.org/10.5281/zenodo.22803751

## Files

`3Dsource.py`  
Used in the preparation of the source-region information for moisture tagging.

`trmask3Dn.py`  
Used to map the geographical source regions onto the WRF model grid and generate the source-region mask files.

`source_regions/`  
Contains the shapefiles defining the geographical moisture-source regions used in the experiments.

The resulting `trmask_d01` files are not stored in this GitHub repository because of their file size. They are publicly archived in the associated Zenodo dataset.

## Data availability

The WRF-WVTs source-region mask files used in this study are publicly available on Zenodo:

Sun, H. (2026). *Moisture-Tracking Source Masks for the 2023 Extreme Rainfall over North China*. Zenodo.  
https://doi.org/10.5281/zenodo.22812836

## Reference

Insua-Costa, D., & Miguez-Macho, G. (2018). A new moisture tagging capability in the Weather Research and Forecasting model: formulation, validation and application to the 2014 Great Lake-effect snowstorm. *Earth System Dynamics, 9*, 167–185.  
https://doi.org/10.5194/esd-9-167-2018
