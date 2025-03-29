export soilTexture_constant

#! format: off
@bounds @describe @units @timescale @with_kw struct soilTexture_constant{T1,T2,T3,T4} <: soilTexture
    clay::T1 = 0.2 | (0.0, 1.0) | "Clay content" | "" | ""
    silt::T2 = 0.3 | (0.0, 1.0) | "Silt content" | "" | ""
    sand::T3 = 0.5 | (0.0, 1.0) | "Sand content" | "" | ""
    orgm::T4 = 0.0 | (0.0, 1.0) | "Organic matter content" | "" | ""
end
#! format: on

function define(params::soilTexture_constant, forcing, land, helpers)
    @unpack_soilTexture_constant params
    @unpack_nt soilW ⇐ land.pools

    ## set parameter variables
    @debug "soilTexture_constant: distributing the constant texture properties over the soil layers." | ""
    st_clay = zero(soilW)
    st_orgm = zero(soilW)
    st_sand = zero(soilW)
    st_silt = zero(soilW)

    ## pack land variables
    @pack_nt (st_clay, st_sand, st_silt, st_orgm) ⇒ land.properties
    return land
end

function precompute(params::soilTexture_constant, forcing, land, helpers)
    @unpack_soilTexture_constant params
    @unpack_nt (st_clay, st_sand, st_silt, st_orgm) ⇐ land.properties

    for sl ∈ eachindex(st_clay)
        @rep_elem clay ⇒ (st_clay, sl, :soilW)
        @rep_elem sand ⇒ (st_sand, sl, :soilW)
        @rep_elem silt ⇒ (st_silt, sl, :soilW)
        @rep_elem orgm ⇒ (st_orgm, sl, :soilW)
    end

    ## pack land variables
    @pack_nt (st_clay, st_sand, st_silt, st_orgm) ⇒ land.properties
    return land
end

purpose(::Type{soilTexture_constant}) = "sets the soil texture properties as constant"

@doc """

$(getBaseDocString())

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
