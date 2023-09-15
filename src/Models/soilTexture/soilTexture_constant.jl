export soilTexture_constant

#! format: off
@bounds @describe @units @with_kw struct soilTexture_constant{T1,T2,T3,T4} <: soilTexture
    CLAY::T1 = 0.2 | (0.0, 1.0) | "Clay content" | ""
    SILT::T2 = 0.3 | (0.0, 1.0) | "Silt content" | ""
    SAND::T3 = 0.5 | (0.0, 1.0) | "Sand content" | ""
    ORGM::T4 = 0.0 | (0.0, 1.0) | "Organic matter content" | ""
end
#! format: on

function define(p_struct::soilTexture_constant, forcing, land, helpers)
    @unpack_soilTexture_constant p_struct

    ## set parameter variables
    @debug "soilTexture_constant: distributing the constant texture properties over the soil layers."
    st_CLAY = zero(land.pools.soilW)
    st_ORGM = zero(land.pools.soilW)
    st_SAND = zero(land.pools.soilW)
    st_SILT = zero(land.pools.soilW)

    ## pack land variables
    @pack_land (st_CLAY, st_SAND, st_SILT, st_ORGM) => land.soilTexture
    return land
end

function precompute(p_struct::soilTexture_constant, forcing, land, helpers)
    @unpack_soilTexture_constant p_struct
    @unpack_land (st_CLAY, st_SAND, st_SILT, st_ORGM) ∈ land.soilTexture

    for sl ∈ eachindex(st_CLAY)
        @rep_elem CLAY => (st_CLAY, sl, :soilW)
        @rep_elem SAND => (st_SAND, sl, :soilW)
        @rep_elem SILT => (st_SILT, sl, :soilW)
        @rep_elem ORGM => (st_ORGM, sl, :soilW)
    end

    ## pack land variables
    @pack_land (st_CLAY, st_SAND, st_SILT, st_ORGM) => land.soilTexture
    return land
end

@doc """
sets the soil texture properties as constant

# Parameters
$(SindbadParameters)

---

# compute:
Soil texture (sand,silt,clay, and organic matter fraction) using soilTexture_constant

*Inputs*

*Outputs*

# instantiate:
instantiate/instantiate time-invariant variables for soilTexture_constant


---

# Extended help

*References*

*Versions*
 - 1.0 on 21.11.2019  

*Created by:*
 - skoirala

*Notes*
 - texture does not change with space & depth
"""
soilTexture_constant
