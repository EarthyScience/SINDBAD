export cTau_mult

struct cTau_mult <: cTau end

function define(params::cTau_mult, forcing, land, helpers)
    ## unpack land variables
    @unpack_land begin
        cEco ∈ land.pools
    end
    c_eco_k = zero(cEco)

    ## pack land variables
    @pack_land c_eco_k => land.states
    return land
end

function compute(params::cTau_mult, forcing, land, helpers)
    ## unpack land variables
    @unpack_land begin
        c_eco_k_f_veg_props ∈ land.cTauVegProperties
        c_eco_k_f_soilW ∈ land.cTauSoilW
        c_eco_k_f_soilT ∈ land.cTauSoilT
        c_eco_k_f_soil_props ∈ land.cTauSoilProperties
        c_eco_k_f_LAI ∈ land.cTauLAI
        c_eco_k_base ∈ land.cCycleBase
        c_eco_k ∈ land.states
    end
    for i ∈ eachindex(c_eco_k)
        tmp = c_eco_k_base[i] * c_eco_k_f_LAI[i] * c_eco_k_f_soil_props[i] * c_eco_k_f_veg_props[i] * c_eco_k_f_soilT * c_eco_k_f_soilW[i]
        tmp = clampZeroOne(tmp)
        @rep_elem tmp => (c_eco_k, i, :cEco)
    end

    ## pack land variables
    @pack_land c_eco_k => land.states
    return land
end

@doc """
multiply all effects that change the turnover rates [k]

---

# compute:
Combine effects of different factors on decomposition rates using cTau_mult

*Inputs*
 - land.cCycleBase.c_eco_k:
 - land.cTauLAI.c_eco_k_f_LAI: LAI stressor values on the the turnover rates
 - land.cTauSoilProperties.c_eco_k_f_soil_props: Soil texture stressor values on the the turnover rates
 - land.cTauSoilT.c_eco_k_f_soilT: Air temperature stressor values on the the turnover rates
 - land.cTauSoilW.fsoilW: Soil moisture stressor values on the the turnover rates
 - land.cTauVegProperties.c_eco_k_f_veg_props: Vegetation type stressor values on the the turnover rates

*Outputs*
 - land.cTau.c_eco_k: values for actual turnover rates
 - land.cTau.c_eco_k

# instantiate:
instantiate/instantiate time-invariant variables for cTau_mult


---

# Extended help

*References*

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais

Noteswe are multiplying [nPix, nZix]x[nPix, 1] should be OK!
"""
cTau_mult
