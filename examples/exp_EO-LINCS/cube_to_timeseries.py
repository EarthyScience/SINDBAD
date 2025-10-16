import xarray as xr
import matplotlib.pyplot as plt
import numpy as np
import os

def apply_scaling(var):
    scale = var.attrs.get("data_scale_factor", 1.0)
    offset = var.attrs.get("add_offset", 0.0)
    return var * scale + offset
def plot_time_series(data_array, var_name, output_dir="tmp_newNDVI"):
    os.makedirs(output_dir, exist_ok=True)
    plt.figure(figsize=(10, 5))
    data_array.plot()
    plt.title(f"{var_name} over Time")
    plt.xlabel("Time")
    plt.ylabel(var_name)
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, f"{var_name}.png"))
    plt.close()

def do_time_resample(reduced, freq="1MS", method="mean"):
    """
    Normalize time dimension and resample to specified frequency using the given aggregation method.

    Parameters:
    - reduced (xarray.DataArray): The data array to resample.
    - freq (str): Resampling frequency (e.g., '1MS' for monthly start).
    - method (str): Aggregation method ('mean', 'median', etc.).

    Returns:
    - xarray.DataArray: Resampled data array.
    """
    time_dim = None
    for tdim in ["time", "start_range"]:
        if tdim in reduced.dims:
            time_dim = tdim
            break

    if time_dim is not None:
        print(f"Resampling time ({time_dim}) for {reduced.name} using {method} over {freq}")
        if time_dim != "time":
            print(f"    Renaming time dimension from {time_dim} to 'time'")
            reduced = reduced.rename({time_dim: "time"})
        reducer = getattr(reduced.resample(time=freq), method)
        reduced = reducer()

    return reduced

        
def reduce_dataset(ds, spatial_dims=["x", "y"], method="mean"):
    reducer = getattr(xr.Dataset, method)
    reduced_vars = {}

    for var_name in ds.data_vars:
        if var_name is not None:
            var = ds[var_name]
            if any(dim in var.dims for dim in ["time", "start_range"]):
                scaled = apply_scaling(var)
                reduced = getattr(scaled, method)(dim=spatial_dims)

                # Aggregate to monthly mean if time dimension exists
                reduced = do_time_resample(reduced, freq="1MS", method=method)

                reduced_vars[var_name] = reduced
                plot_time_series(reduced, var_name)

    # NDVI calculation
    if "B08" in ds and "B04" in ds:
        nir = apply_scaling(ds["B08"])
        red = apply_scaling(ds["B04"])
        ndvi = (nir - red) / (nir + red)
        ndvi_reduced = getattr(ndvi, method)(dim=spatial_dims)
        ndvi_reduced = do_time_resample(ndvi_reduced, freq="1MS", method=method)

        reduced_vars["NDVI"] = ndvi_reduced
        plot_time_series(ndvi_reduced, "NDVI")

    return xr.Dataset(reduced_vars)
def merge_with_netcdf(nc_path, zarr_path, output_path, spatial_dims=["x", "y"], method="mean", freq="1MS"):
    """
    Reduce Zarr dataset, resample to monthly, interpolate to NetCDF time axis,
    broadcast to match spatial grid, and save merged dataset.

    Parameters:
    - nc_path (str): Path to the NetCDF file.
    - zarr_path (str): Path to the Zarr dataset.
    - output_path (str): Path to save the merged NetCDF file.
    - spatial_dims (list): Dimensions to reduce (e.g., ['x', 'y']).
    - method (str): Aggregation method ('mean', 'median').
    - freq (str): Resampling frequency (e.g., '1MS').
    """
    # Load NetCDF dataset
    base_ds = xr.open_dataset(nc_path)

    # Load and reduce Zarr dataset
    zarr_ds = xr.open_zarr(zarr_path)
    reduced_ds = reduce_dataset(zarr_ds, spatial_dims=spatial_dims, method=method)

    # Interpolate to match NetCDF time axis
    if "time" in base_ds.dims and "time" in reduced_ds.dims:
        reduced_ds = reduced_ds.interp(time=base_ds.time)

    # Broadcast reduced variables to match spatial grid
    lat = base_ds["latitude"]
    lon = base_ds["longitude"]
    broadcasted_vars = {}

    for var_name in reduced_ds.data_vars:
        var = reduced_ds[var_name]
        # Expand to 3D: time x lat x lon
        broadcasted = var.expand_dims({"latitude": lat, "longitude": lon}, axis=(1, 2))
        broadcasted_vars[var_name] = broadcasted

    # Merge with base dataset
    merged_ds = xr.merge([base_ds, xr.Dataset(broadcasted_vars)])

    # Save to NetCDF
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    merged_ds.to_netcdf(output_path, mode="w")
    print(f"✅ Saved merged dataset to {output_path}")

def process_and_save(zarr_path, output_path, spatial_dims=["x", "y"], method="mean"):
    ds = xr.open_zarr(zarr_path)
    reduced_ds = reduce_dataset(ds, spatial_dims=spatial_dims, method=method)
    reduced_ds.to_zarr(output_path, mode="w")
    print(f"Saved reduced dataset to {output_path}")

# Example usage
if __name__ == "__main__":
    sites_dict = {"FR-Pue": ("43.74", "3.60"),
    "DE-Hai": ("51.08", "10.45"),"AT-Neu": ("47.12", "11.32"),}
    for site, coords in sites_dict.items():
        zarr_path = f"/Users/skoirala/research/RnD/SINDBAD-RnD-SK/examples/exp_EO-LINCS/{site}_{coords[0]}_{coords[1]}_v0.zarr"
        output_path = f"tmp_newNDVI/{site}_newNDVI.v0.zarr"
        nc_path = f"/Users/skoirala/research/RnD/SINDBAD-RnD-SK/examples/data/fn/{site}.1979.2017.daily.nc"
        merged_output_path = f"tmp_mergedData/{site}.merged.nc"
        if os.path.exists(merged_output_path):
            os.remove(merged_output_path)
        merge_with_netcdf(nc_path, zarr_path, merged_output_path, spatial_dims=["x", "y"], method="mean")
