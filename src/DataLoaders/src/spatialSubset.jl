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
            if !isnothing(ss_r)
                ss_range = collect(ss_r)
                ss_typeName = Symbol("Space" * string(ssn))
                v = spatialSubset(v, ss_range, getfield(Utils, ss_typeName)())
            end
        end
    end
    return v
end

"""
    spatialSubset(v, ss_range, <: SpatialSubsetter)

Extracts a spatial subset of the input data `v` based on the specified range and spatial dimension.

# Arguments:
- `v`: The input data from which a spatial subset is to be extracted.
- `ss_range`: The range of indices or values to subset along the specified spatial dimension.

# Returns:
- A subset of the input data `v` corresponding to the specified spatial range and dimension.

$(methodsOf(SpatialSubsetter))

---

# Extended help

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
function spatialSubset end

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
