# Why this README?
Well, just to state that we have raw data in high resolution for land cover types, which we use for the PFT scenario.
And when computing burn areas we need to know how much of that is actullay vegetated, hence we should know what is the fraction of that area to use in the final calculation, this is done by going up from the highest resolution!

This folder contains all the scripts used to pre-proccess all that!

## UnpackSinTiles.jl

> [!CAUTION]  
> For this, I created another package to reads and stacks all tiles into global maps in a lon/lat grid.
> The original products are in the MODIS sinusoidal projection.

For some scripts you will need to add (specially when reading the original files):

```julia
pkg> add https://github.com/EarthyScience/UnpackSinTiles.jl#la/split_land_cover_types
```

it will be included where appropiate, however in this folder's `Project.toml` is not included!

> [!INFO]  
> Also, some scripts for that are already available in that package, however for completeness workflow I'm copying them here!

### IGBP Vegetation Types Classification: `LC_Type1`

> [!IMPORTANT]
> The user guide uses an scale from 0-16, zero being water. But the actual data goes from 1 to 17, where now 17 is water.
> See also https://www.ceom.ou.edu/static/docs/IGBP.pdf

> [!TIP]
> Non-vegetated areas: `Dominant Plant Form`
> 17, 13, 15, 16, 255

| Value | Land Cover Classification            | Dominant Plant Form |
|-------|--------------------------------------| -------------------- |
| 1     | Evergreen Needleleaf Forests         | Tree |
| 2     | Evergreen Broadleaf Forests          | Tree |
| 3     | Deciduous Needleleaf Forests         | Tree |
| 4     | Deciduous Broadleaf Forests          | Tree |
| 5     | Mixed Forests                        | Tree |
| 6     | Closed Shrublands                    | Shrub |
| 7     | Open Shrublands                      | Shrub |
| 8     | Woody Savannas                       | Savanna |
| 9     | Savannas                             | Savanna |
| 10    | Grasslands                           | Herb |
| 11    | Permanent Wetlands                   | Herb |
| 12    | Croplands                            | Herb |
| 13    | Urban and Built-up Lands             | Non-Veg |
| 14    | Cropland/Natural Vegetation Mosaics  | Herb |
| 15    | Permanent Snow and Ice               | Non-Veg |
| 16    | Barren or Sparsely Vegetated         | Non-Veg |
| 17    | Water                                | Non-Veg |
| 255   | Unclassified (No Data)               | Non-Veg |