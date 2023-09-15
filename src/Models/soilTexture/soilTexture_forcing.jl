export soilTexture_forcing

struct soilTexture_forcing <: soilTexture end

function define(p_struct::soilTexture_forcing, forcing, land, helpers)
    #@needscheck
    ## unpack forcing
    @unpack_forcing (CLAY, ORGM, SAND, SILT) ∈ forcing

    ## unpack land variables

    st_CLAY_f = Tuple(CLAY)
    st_SAND_f = Tuple(SAND)
    st_SILT_f = Tuple(SILT)
    st_ORGM_f = Tuple(ORGM)

    ## precomputations/check
    st_CLAY = zero(land.pools.soilW)
    st_ORGM = zero(land.pools.soilW)
    st_SAND = zero(land.pools.soilW)
    st_SILT = zero(land.pools.soilW)

    if length(st_CLAY_f) != length(st_CLAY)
        @debug "soilTexture_forcing: the number of soil layers in forcing data does not match the layers in model_structure.json. Using mean of input over the soil layers."
        for sl ∈ eachindex(st_CLAY)
            @rep_elem mean(st_CLAY_f) => (st_CLAY, sl, :soilW)
            @rep_elem mean(st_SAND_f) => (st_SAND, sl, :soilW)
            @rep_elem mean(st_SILT_f) => (st_SILT, sl, :soilW)
            @rep_elem mean(st_ORGM_f) => (st_ORGM, sl, :soilW)
        end
    else
        for sl ∈ eachindex(st_CLAY)
            @rep_elem st_CLAY_f[sl] => (st_CLAY, sl, :soilW)
            @rep_elem st_SAND_f[sl] => (st_SAND, sl, :soilW)
            @rep_elem st_SILT_f[sl] => (st_SILT, sl, :soilW)
            @rep_elem st_ORGM_f[sl] => (st_ORGM, sl, :soilW)
        end
    end

    ## pack land variables
    @pack_land (st_CLAY, st_ORGM, st_SAND, st_SILT) => land.soilTexture
    return land
end

@doc """
sets the soil texture properties from input

---

# compute:
Soil texture (sand,silt,clay, and organic matter fraction) using soilTexture_forcing

*Inputs*
 - forcing.SAND/SILT/CLAY/ORGM

*Outputs*
 - land.soilTexture.st_SAND/SILT/CLAY/ORGM

# instantiate:
instantiate/instantiate time-invariant variables for soilTexture_forcing


---

# Extended help

*References*

*Versions*
 - 1.0 on 21.11.2019  

*Created by:*
 - skoirala

*Notes*
 - if not; then sets the average of all as the fixed property of all layers
 - if the input has same number of layers & soilW; then sets the properties per layer
"""
soilTexture_forcing
