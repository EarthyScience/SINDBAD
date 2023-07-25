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
        n_soilW ∈ land.wCycleBase
    end

    # instatiate variables 
    soil_layer_thickness = zero(land.pools.soilW)
    wFC = zero(land.pools.soilW)
    WP = zero(land.pools.soilW)
    wSat = zero(land.pools.soilW)

    soilDepths = helpers.pools.layerThickness.soilW
    # soilDepths = helpers.pools.layerThickness.soilW

    kSat = sp_kSat
    soil_kFC = sp_kFC
    kWP = sp_kWP
    ψSat = sp_ψSat
    ψFC = sp_ψFC
    ψWP = sp_ψWP
    θSat = sp_θSat
    θFC = sp_θFC
    θWP = sp_θWP
    soil_α = sp_α
    soil_β = sp_β

    for sl ∈ eachindex(soilW)
        sd_sl = soilDepths[sl]
        @rep_elem sd_sl => (soil_layer_thickness, sl, :soilW)
        p_wFC_sl = θFC[sl] * sd_sl
        @rep_elem p_wFC_sl => (wFC, sl, :soilW)
        WP_sl = θWP[sl] * sd_sl
        @rep_elem WP_sl => (WP, sl, :soilW)
        p_wSat_sl = θSat[sl] * sd_sl
        @rep_elem p_wSat_sl => (wSat, sl, :soilW)
        soilW_sl = min(soilW[sl], wSat[sl])
        @rep_elem soilW_sl => (soilW, sl, :soilW)
    end

    # get the plant available water capacity
    wAWC = wFC - WP

    # save the sums of selected variables
    sum_wFC = sum(wFC)
    sum_WP = sum(WP)
    sum_wSat = sum(wSat)
    sum_wAWC = sum(wAWC)

    @pack_land begin
        (soil_kFC,
            kSat,
            kWP,
            soil_layer_thickness,
            wAWC,
            wFC,
            wSat,
            WP,
            sum_wAWC,
            sum_wFC,
            sum_wSat,
            sum_WP,
            soil_α,
            soil_β,
            θFC,
            θSat,
            θWP,
            ψFC,
            ψSat,
            ψWP) => land.soilWBase
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
 - land.soilProperties.unsatK: function to calculate unsaturated hydraulic conduct.
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
