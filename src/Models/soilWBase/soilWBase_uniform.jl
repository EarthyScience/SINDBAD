export soilWBase_uniform

struct soilWBase_uniform <: soilWBase end

function define(params::soilWBase_uniform, forcing, land, helpers)
    #@needscheck
    ## unpack land variables
    @unpack_nt begin
        soilW ⇐ land.pools
    end

    # instatiate variables 
    soil_layer_thickness = zero(soilW)
    wFC = zero(soilW)
    wWP = zero(soilW)
    wSat = zero(soilW)
    wAWC = wFC - wWP
    # save the sums of selected variables
    sum_wFC = sum(wFC)
    sum_WP = sum(wWP)
    sum_wSat = sum(wSat)
    sum_wAWC = sum(wAWC)

    kSat = zero(soilW)
    kFC = zero(soilW)
    kWP = zero(soilW)
    ψSat = zero(soilW)
    ψFC = zero(soilW)
    ψWP = zero(soilW)
    θSat = zero(soilW)
    θFC = zero(soilW)
    θWP = zero(soilW)
    soil_α = zero(soilW)
    soil_β = zero(soilW)

    # get the plant available water capacity

    @pack_nt begin
        (kFC, kSat, kWP, soil_layer_thickness, wAWC, wFC, wSat, wWP, sum_wAWC, sum_wFC, sum_wSat, sum_WP, soil_α, soil_β, θFC, θSat, θWP, ψFC, ψSat, ψWP) ⇒ land.properties
    end
    return land
end


function precompute(params::soilWBase_uniform, forcing, land, helpers)
    ## unpack land variables
    @unpack_nt begin
        (sp_kFC, sp_kSat, sp_kWP, sp_α, sp_β, sp_θFC, sp_θSat, sp_θWP, sp_ψFC, sp_ψSat, sp_ψWP) ⇐ land.properties
        (kFC, kSat, kWP, soil_layer_thickness, wAWC, wFC, wSat, wWP, sum_wAWC, sum_wFC, sum_wSat, sum_WP, soil_α, soil_β, θFC, θSat, θWP, ψFC, ψSat, ψWP) ⇐ land.properties
        soilW ⇐ land.pools
        soilDepths = soilW ⇐ helpers.pools.layer_thickness 
    end

    for sl ∈ eachindex(soilW)
        @rep_elem sp_kSat[sl] ⇒ (kSat, sl, :soilW)
        @rep_elem sp_kFC[sl] ⇒ (kFC, sl, :soilW)
        @rep_elem sp_kWP[sl] ⇒ (kWP, sl, :soilW)
        @rep_elem sp_ψSat[sl] ⇒ (ψSat, sl, :soilW)
        @rep_elem sp_ψFC[sl] ⇒ (ψFC, sl, :soilW)
        @rep_elem sp_ψWP[sl] ⇒ (ψWP, sl, :soilW)
        @rep_elem sp_θSat[sl] ⇒ (θSat, sl, :soilW)
        @rep_elem sp_θFC[sl] ⇒ (θFC, sl, :soilW)
        @rep_elem sp_θWP[sl] ⇒ (θWP, sl, :soilW)
        @rep_elem sp_α[sl] ⇒ (soil_α, sl, :soilW)
        @rep_elem sp_β[sl] ⇒ (soil_β, sl, :soilW)

        sd_sl = soilDepths[sl]
        @rep_elem sd_sl ⇒ (soil_layer_thickness, sl, :soilW)
        p_wFC_sl = θFC[sl] * sd_sl
        @rep_elem p_wFC_sl ⇒ (wFC, sl, :soilW)
        wWP_sl = θWP[sl] * sd_sl
        @rep_elem wWP_sl ⇒ (wWP, sl, :soilW)
        p_wSat_sl = θSat[sl] * sd_sl
        @rep_elem p_wSat_sl ⇒ (wSat, sl, :soilW)
        soilW_sl = min(soilW[sl], wSat[sl])
        @rep_elem soilW_sl ⇒ (soilW, sl, :soilW)
    end

    # get the plant available water capacity
    wAWC = wFC - wWP

    # save the sums of selected variables
    sum_wFC = sum(wFC)
    sum_WP = sum(wWP)
    sum_wSat = sum(wSat)
    sum_wAWC = sum(wAWC)

    @pack_nt begin
        (kFC, kSat, kWP, soil_layer_thickness, wAWC, wFC, wSat, wWP, sum_wAWC, sum_wFC, sum_wSat, sum_WP, soil_α, soil_β, θFC, θSat, θWP, ψFC, ψSat, ψWP) ⇒ land.properties
        soilW ⇒ land.pools
    end
    return land
end

@doc """
distributes the soil hydraulic properties for different soil layers assuming an uniform vertical distribution of all soil properties

# Parameters
$(SindbadParameters)

---

# compute:
Distribution of soil hydraulic properties over depth using soilWBase_uniform

*Inputs*
 - helpers.pools.: soil layers & depths
 - land.soilProperties.unsatK: function to calculate unsaturated hydraulic conduct.
 - land.properties.p_[sand/silt/clay/orgm]: texture properties [nZix]

*Outputs*
 - all soil hydraulic properties in land.properties.p_[parameterName]
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
