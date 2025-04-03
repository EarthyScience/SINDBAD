export getSpatialSubset

"""
    getSpatialSubset(ss, v)

Extracts a spatial subset of data based on specified spatial subsetting type/strategy.

# Arguments
- `ss`: Spatial subset parameters or geometry defining the region of interest
- `v`: Data to be spatially subset

# Returns
Spatially subset data according to the specified parameters

# Note
The function assumes input data and spatial parameters are in compatible formats
"""
function getSpatialSubset(ss, v)
    if isa(ss, Dict)
        ss = dictToNamedTuple(ss)
    end
    if !isnothing(ss)
        ssname = propertynames(ss)
        for ssn ∈ ssname
            ss_r = getproperty(ss, ssn)
            ss_range = ss_r[1]:ss_r[2]
            ss_typeName = Symbol("Space" * string(ssn))
            v = spatialSubset(v, ss_range, getfield(SindbadUtils, ss_typeName)())
        end
    end
    return v
end

"""
    spatialSubset(v, ss_range, <:SindbadSpatialSubsetType)

Extracts a spatial subset of the input data `v` based on the specified range and spatial dimension.

# Arguments:
- `v`: The input data from which a spatial subset is to be extracted.
- `ss_range`: The range of indices or values to subset along the specified spatial dimension.
- `<:SindbadSpatialSubsetType`: The spatial dimension to subset, represented by one of the following types:
    - `Spacesite`: Subsets based on site indices.
    - `Spacelat`: Subsets based on latitude indices.
    - `Spacelatitude`: Subsets based on latitude values.
    - `Spacelon`: Subsets based on longitude indices.
    - `Spacelongitude`: Subsets based on longitude values.
    - `Spaceid`: Subsets based on ID indices.
    - `SpaceId`: Subsets based on ID values (capitalized `Id`).
    - `SpaceID`: Subsets based on ID values (uppercase `ID`).

# Returns:
- A subset of the input data `v` corresponding to the specified spatial range and dimension.

# Notes:
- The function dynamically selects the appropriate field in `v` based on the spatial type provided.
- The spatial type determines the field name (e.g., `site`, `lat`, `longitude`, `id`, etc.) used for subsetting.

# Examples:
1. **Subsetting by latitude**:
```julia
subset = spatialSubset(data, 10:20, Spacelat())
```

2. **Subsetting by longitude**:
```julia
subset = spatialSubset(data, 30:40, Spacelongitude())
```

3. **Subsetting by site ID**:
```julia
subset = spatialSubset(data, 1:5, Spaceid())
```
"""
spatialSubset

function spatialSubset(v, ss_range, ::Spacesite)
    return v[site=ss_range]
end

function spatialSubset(v, ss_range, ::Spacelat)
    return v[lat=ss_range]
end

function spatialSubset(v, ss_range, ::Spacelatitude)
    return v[latitude=ss_range]
end

function spatialSubset(v, ss_range, ::Spacelon)
    return v[lon=ss_range]
end

function spatialSubset(v, ss_range, ::Spacelongitude)
    return v[longitude=ss_range]
end

function spatialSubset(v, ss_range, ::Spaceid)
    return v[id=ss_range]
end

function spatialSubset(v, ss_range, ::SpaceId)
    return v[Id=ss_range]
end

function spatialSubset(v, ss_range, ::SpaceID)
    return v[ID=ss_range]
end
