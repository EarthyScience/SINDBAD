# Counting MODIS fire events

The raw data comes in `hdf` files which we can read and aggregate with `UnpackSinTiles.jl`. The workflow breaks down into:

- Creating a final fire skeleton zarr file of a given resolution, into which we will save the counts. See `fire_skeleton_zarr.jl`, where to `skeletons` are created.
- Load a single tile across all available dates, count, aggregate and update the zarr file. See `fill_skeleton_zarr.jl`
- Launch a slurm job for each tile, such that we do all of them in parallel. See `fill_skeleton_zarr.sh`.
- Reproject data from Sinusoidal to EPSG(4326).  See `fire_reproject_to_4326.jl`