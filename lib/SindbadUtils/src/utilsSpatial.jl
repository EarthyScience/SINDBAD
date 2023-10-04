export getSpatialSubset

"""
    getSpatialSubset(ss, v)


"""
function getSpatialSubset(ss, v)
    if !isnothing(ss)
        ssname = propertynames(ss)
        for ssn ∈ ssname
            ss_r = getproperty(ss, ssn)
            ss_range = ss_r[1]:ss_r[2]
            @show ssn
            ss_typeName = Symbol("Space" * string(ssn))
            v = spatialSubset(v, ss_range, getfield(SindbadUtils, ss_typeName)())
        end
    end
    return v
end


"""
    spatialSubset(v, ss_range, ::Spacesite)



# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `::Spacesite`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Spacesite)
    return v[site=ss_range]
end

"""
    spatialSubset(v, ss_range, ::Spacelat)



# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `::Spacelat`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Spacelat)
    return v[lat=ss_range]
end

"""
    spatialSubset(v, ss_range, ::Spacelatitude)



# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `::Spacelatitude`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Spacelatitude)
    return v[latitude=ss_range]
end

"""
    spatialSubset(v, ss_range, ::Spacelon)



# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `::Spacelon`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Spacelon)
    return v[lon=ss_range]
end

"""
    spatialSubset(v, ss_range, ::Spacelongitude)



# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `::Spacelongitude`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Spacelongitude)
    return v[longitude=ss_range]
end

"""
    spatialSubset(v, ss_range, ::Spaceid)



# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `::Spaceid`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Spaceid)
    return v[id=ss_range]
end

"""
    spatialSubset(v, ss_range, ::SpaceId)



# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `::SpaceId`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::SpaceId)
    return v[Id=ss_range]
end

"""
    spatialSubset(v, ss_range, ::SpaceID)



# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `::SpaceID`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::SpaceID)
    return v[ID=ss_range]
end
