# Moisture Tracking

Moisture source tracking in this study was performed using the WRF-WVTs moisture tagging framework coupled with the Weather Research and Forecasting (WRF) model.

WRF-WVTs:
https://github.com/damianinsua/WRF-WVTs

## Source regions

The geographical source regions used for moisture tagging are provided in the `source_regions` directory. These shapefiles define the moisture source regions used in the experiments, including oceanic and terrestrial source regions.

## Mask generation

The scripts `3Dsource.py` and `trmask3Dn.py` were used to map the geographical source regions onto the WRF model grid and generate the source-region mask required by WRF-WVTs.

The resulting WRF-WVTs mask file (`trmask_d01`) is archived with the associated dataset on Zenodo.

## Reference

Insua-Costa, D., and Miguez-Macho, G. (2018). A new moisture tagging capability in the Weather Research and Forecasting model: formulation, validation and application to the 2014 Great Lake-effect snowstorm. Earth System Dynamics, 9, 167–185. https://doi.org/10.5194/esd-9-167-2018
