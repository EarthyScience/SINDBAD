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
            v = spatialSubset(v, ss_range, Val(ssn))
        end
    end
    return v
end


"""
    spatialSubset(v, ss_range, Val{:site})



# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Val{:site})
    return v[site=ss_range]
end

"""
    spatialSubset(v, ss_range, Val{:lat})



# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Val{:lat})
    return v[lat=ss_range]
end

"""
    spatialSubset(v, ss_range, Val{:latitude})



# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Val{:latitude})
    return v[latitude=ss_range]
end

"""
    spatialSubset(v, ss_range, Val{:lon})



# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Val{:lon})
    return v[lon=ss_range]
end

"""
    spatialSubset(v, ss_range, Val{:longitude})



# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Val{:longitude})
    return v[longitude=ss_range]
end

"""
    spatialSubset(v, ss_range, Val{:id})



# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Val{:id})
    return v[id=ss_range]
end

"""
    spatialSubset(v, ss_range, Val{:Id})



# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Val{:Id})
    return v[Id=ss_range]
end

"""
    spatialSubset(v, ss_range, Val{:ID})



# Arguments:
- `v`: DESCRIPTION
- `ss_range`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function spatialSubset(v, ss_range, ::Val{:ID})
    return v[ID=ss_range]
end
