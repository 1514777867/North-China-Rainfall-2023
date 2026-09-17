# Moisture Tracking

Moisture-source tracking in this study was performed using the WRF-WVTs moisture-tagging framework coupled with the Weather Research and Forecasting (WRF) model.

WRF-WVTs:  
https://github.com/damianinsua/WRF-WVTs

## Source regions

The geographical source regions used for moisture tagging are provided in the `source_regions` directory.

These shapefiles define the oceanic and terrestrial moisture-source regions used in the WRF-WVTs experiments.

The source regions considered in this study include:

- All
- Bay of Bengal
- India
- South China
- South China Sea
- Western Pacific

## Mask generation

The scripts `3Dsource.py` and `trmask3Dn.py` were used to map the geographical source regions onto the WRF model grid and generate the source-region masks required by WRF-WVTs.

Six source-region mask files were generated for the moisture-tracking experiments.

Each experiment used a mask file named `trmask_d01`. To preserve the original filenames used in the simulations, the mask files are stored separately according to their corresponding source regions in the associated Zenodo archive.

## Files

### `3Dsource.py`

Used in the preparation of the geographical source-region information required for moisture tagging.

### `trmask3Dn.py`

Used to map the source-region shapefiles onto the WRF model grid and generate the `trmask_d01` mask files.

### `source_regions/`

Contains the shapefiles defining the moisture-source regions used in the experiments.

A complete shapefile dataset may include:

- `.shp`
- `.shx`
- `.dbf`
- `.prj`
- `.cpg`, where available

## Source-region mask data

The `trmask_d01` files are not stored directly in this GitHub repository because of their relatively large file sizes.

The six WRF-WVTs source-region mask files, together with related figure-source materials and shapefiles, are publicly archived on Zenodo:

https://doi.org/10.5281/zenodo.22812836

The archived source-mask directories correspond to:


## Data availability

The moisture-tracking source masks and associated source-region materials used in this study are publicly available at:

Sun, H. (2026). *Data and Figure Source Materials for the 2023 Extreme Rainfall over North China*. Zenodo.  
https://doi.org/10.5281/zenodo.22812836

## Related repository

The WRF configuration files, moisture-tracking setup, mask-generation scripts, and plotting scripts used in this study are available in the main GitHub repository:

https://github.com/1514777867/North-China-Rainfall-2023

## Reference

Insua-Costa, D., & Miguez-Macho, G. (2018). A new moisture tagging capability in the Weather Research and Forecasting model: formulation, validation and application to the 2014 Great Lake-effect snowstorm. *Earth System Dynamics, 9*, 167–185.  
https://doi.org/10.5194/esd-9-167-2018

## Notes

Users who wish to reproduce the moisture-tagging setup may need to modify local file paths in `3Dsource.py` and `trmask3Dn.py` according to their own computing environment.

The complete raw WRF output files are not archived in this repository or on Zenodo because of their large total data volume (approximately 2.6 TB). The processed datasets and figure-source data required to support the analyses and figures presented in the manuscript are publicly available through the associated Zenodo record:

https://doi.org/10.5281/zenodo.22812836

Researchers who require access to the complete raw WRF output files for additional analyses may contact the corresponding author to discuss data transfer, subject to storage and transfer limitations:

Email: [1514777867@qq.com]
