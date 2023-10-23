export soilTexture_forcing

struct soilTexture_forcing <: soilTexture end

function define(params::soilTexture_forcing, forcing, land, helpers)
    #@needscheck
    ## unpack forcing
    @unpack_nt (f_clay, f_orgm, f_sand, f_silt) ⇐ forcing
    @unpack_nt soilW ⇐ land.pools

    ## unpack land variables

    st_clay_f = Tuple(f_clay)
    st_sand_f = Tuple(f_sand)
    st_silt_f = Tuple(f_silt)
    st_orgm_f = Tuple(f_orgm)

    ## precomputations/check
    st_clay = zero(soilW)
    st_orgm = zero(soilW)
    st_sand = zero(soilW)
    st_silt = zero(soilW)

    if length(st_clay_f) != length(st_clay)
        @debug "soilTexture_forcing: the number of soil layers in forcing data does not match the layers in model_structure.json. Using mean of input over the soil layers."
        for sl ∈ eachindex(st_clay)
            @rep_elem mean(st_clay_f) ⇒ (st_clay, sl, :soilW)
            @rep_elem mean(st_sand_f) ⇒ (st_sand, sl, :soilW)
            @rep_elem mean(st_silt_f) ⇒ (st_silt, sl, :soilW)
            @rep_elem mean(st_orgm_f) ⇒ (st_orgm, sl, :soilW)
        end
    else
        for sl ∈ eachindex(st_clay)
            @rep_elem st_clay_f[sl] ⇒ (st_clay, sl, :soilW)
            @rep_elem st_sand_f[sl] ⇒ (st_sand, sl, :soilW)
            @rep_elem st_silt_f[sl] ⇒ (st_silt, sl, :soilW)
            @rep_elem st_orgm_f[sl] ⇒ (st_orgm, sl, :soilW)
        end
    end

    ## pack land variables
    @pack_nt (st_clay, st_orgm, st_sand, st_silt) ⇒ land.properties
    return land
end

@doc """
sets the soil texture properties from input

---

# compute:
Soil texture (sand,silt,clay, and organic matter fraction) using soilTexture_forcing

*Inputs*
 - forcing.sand/silt/clay/orgm

*Outputs*
 - land.properties.st_sand/silt/clay/orgm

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
