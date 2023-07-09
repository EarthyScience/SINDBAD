export soilWBase_uniform

struct soilWBase_uniform <: soilWBase end

function define(p_struct::soilWBase_uniform, forcing, land, helpers)
    #@needscheck
    ## unpack land variables
    @unpack_land begin
        (sp_kFC, sp_kSat, sp_kWP, sp_α, sp_β, sp_θFC, sp_θSat, sp_θWP, sp_ψFC, sp_ψSat, sp_ψWP) ∈
        land.soilProperties
        (st_CLAY, st_ORGM, st_SAND, st_SILT) ∈ land.soilTexture
        soilW ∈ land.pools
        num_type ∈ helpers.numbers
    end
    n_soilW = length(soilW)

    # instatiate variables 
    soil_layer_thickness = zero(land.pools.soilW)
    p_wFC = zero(land.pools.soilW)
    p_wWP = zero(land.pools.soilW)
    p_wSat = zero(land.pools.soilW)

    soilDepths = helpers.pools.layerThickness.soilW
    # soilDepths = helpers.pools.layerThickness.soilW

    p_CLAY = st_CLAY
    p_SAND = st_SAND
    p_SILT = st_SILT
    p_ORGM = st_ORGM
    p_kSat = sp_kSat
    p_kFC = sp_kFC
    p_kWP = sp_kWP
    p_ψSat = sp_ψSat
    p_ψFC = sp_ψFC
    p_ψWP = sp_ψWP
    p_θSat = sp_θSat
    p_θFC = sp_θFC
    p_θWP = sp_θWP
    p_α = sp_α
    p_β = sp_β

    for sl ∈ eachindex(soilW)
        sd_sl = soilDepths[sl]
        @rep_elem sd_sl => (soil_layer_thickness, sl, :soilW)
        p_wFC_sl = p_θFC[sl] * sd_sl
        @rep_elem p_wFC_sl => (p_wFC, sl, :soilW)
        p_wWP_sl = p_θWP[sl] * sd_sl
        @rep_elem p_wWP_sl => (p_wWP, sl, :soilW)
        p_wSat_sl = p_θSat[sl] * sd_sl
        @rep_elem p_wSat_sl => (p_wSat, sl, :soilW)
        soilW_sl = min(soilW[sl], p_wSat[sl])
        @rep_elem soilW_sl => (soilW, sl, :soilW)
    end

    # get the plant available water capacity
    p_wAWC = p_wFC - p_wWP

    # save the sums of selected variables
    s_wFC = sum(p_wFC)
    s_wWP = sum(p_wWP)
    s_wSat = sum(p_wSat)
    s_wAWC = sum(p_wAWC)

    @pack_land begin
        (p_CLAY,
            p_ORGM,
            p_SAND,
            p_SILT,
            p_kFC,
            p_kSat,
            p_kWP,
            soil_layer_thickness,
            p_wAWC,
            p_wFC,
            p_wSat,
            p_wWP,
            s_wAWC,
            s_wFC,
            s_wSat,
            s_wWP,
            p_α,
            p_β,
            p_θFC,
            p_θSat,
            p_θWP,
            p_ψFC,
            p_ψSat,
            p_ψWP,
            n_soilW) => land.soilWBase
        soilW => land.pools
    end
    return land
end

@doc """
distributes the soil hydraulic properties for different soil layers assuming an uniform vertical distribution of all soil properties

# Parameters
$(PARAMFIELDS)

---

# compute:
Distribution of soil hydraulic properties over depth using soilWBase_uniform

*Inputs*
 - helpers.pools.: soil layers & depths
 - land.soilProperties.unsatK: function handle to calculate unsaturated hydraulic conduct.
 - land.soilTexture.p_[SAND/SILT/CLAY/ORGM]: texture properties [nPix, nZix]

*Outputs*
 - all soil hydraulic properties in land.soilWBase.p_[parameterName] (nPix, nTix)
 - makeLookup: to switch on/off the creation of lookup table of  unsaturated hydraulic conductivity

# instantiate:
instantiate/instantiate time-invariant variables for soilWBase_uniform


---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala]: clean up & consistency
 - 1.1 on 03.12.2019 [skoirala]: handling potentail vertical distribution of soil texture  

*Created by:*
 - ncarval
 - skoirala
"""
soilWBase_uniform
