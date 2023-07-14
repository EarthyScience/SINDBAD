export cTau_mult

struct cTau_mult <: cTau end

function define(p_struct::cTau_mult, forcing, land, helpers)
    ## unpack land variables
    @unpack_land begin
        cEco ∈ land.pools
    end
    p_k = zero(cEco)

    ## pack land variables
    @pack_land p_k => land.states
    return land
end

function compute(p_struct::cTau_mult, forcing, land, helpers)
    ## unpack land variables
    @unpack_land begin
        p_k_f_veg_props ∈ land.cTauVegProperties
        p_k_f_soilW ∈ land.cTauSoilW
        p_k_f_soilT ∈ land.cTauSoilT
        p_k_f_soil_props ∈ land.cTauSoilProperties
        p_k_f_LAI ∈ land.cTauLAI
        p_k_base ∈ land.cCycleBase
        p_k ∈ land.states
        (𝟘, 𝟙) ∈ helpers.numbers
    end
    for i ∈ eachindex(p_k)
        tmp = p_k_base[i] * p_k_f_LAI[i] * p_k_f_soil_props[i] * p_k_f_veg_props[i] * p_k_f_soilT * p_k_f_soilW[i]
        tmp = clamp_01(tmp)
        @rep_elem tmp => (p_k, i, :cEco)
    end

    ## pack land variables
    @pack_land p_k => land.states
    return land
end

@doc """
multiply all effects that change the turnover rates [k]

---

# compute:
Combine effects of different factors on decomposition rates using cTau_mult

*Inputs*
 - land.cCycleBase.p_k:
 - land.cTauLAI.p_k_f_LAI: LAI stressor values on the the turnover rates
 - land.cTauSoilProperties.p_k_f_soil_props: Soil texture stressor values on the the turnover rates
 - land.cTauSoilT.p_k_f_soilT: Air temperature stressor values on the the turnover rates
 - land.cTauSoilW.fsoilW: Soil moisture stressor values on the the turnover rates
 - land.cTauVegProperties.p_k_f_veg_props: Vegetation type stressor values on the the turnover rates

*Outputs*
 - land.cTau.p_k: values for actual turnover rates
 - land.cTau.p_k

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
