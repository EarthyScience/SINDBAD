export cTau_mult

struct cTau_mult <: cTau end

function precompute(o::cTau_mult, forcing::NamedTuple, land::NamedTuple, helpers::NamedTuple)
    ## unpack land variables
    @unpack_land begin
        cEco ∈ land.pools
    end
    p_k = zero(cEco)

    ## pack land variables
    @pack_land p_k => land.states
    return land
end

function compute(o::cTau_mult, forcing::NamedTuple, land::NamedTuple, helpers::NamedTuple)
    ## unpack land variables
    @unpack_land begin
        p_kfVeg ∈ land.cTauVegProperties
        p_fsoilW ∈ land.cTauSoilW
        fT ∈ land.cTauSoilT
        p_kfSoil ∈ land.cTauSoilProperties
        p_kfLAI ∈ land.cTauLAI
        p_k_base ∈ land.cCycleBase
        p_k ∈ land.states
        (𝟘, 𝟙) ∈ helpers.numbers
    end
    p_k .= p_k_base .* p_kfLAI .* p_kfSoil .* p_kfVeg .* fT .* p_fsoilW
    p_k .= clamp.(p_k, 𝟘, 𝟙)

    ## pack land variables
    # @pack_land p_k => land.states
    return land
end

@doc """
multiply all effects that change the turnover rates [k]

---

# compute:
Combine effects of different factors on decomposition rates using cTau_mult

*Inputs*
 - land.cCycleBase.p_k:
 - land.cTauLAI.p_kfLAI: LAI stressor values on the the turnover rates
 - land.cTauSoilProperties.p_kfSoil: Soil texture stressor values on the the turnover rates
 - land.cTauSoilT.fT: Air temperature stressor values on the the turnover rates
 - land.cTauSoilW.fsoilW: Soil moisture stressor values on the the turnover rates
 - land.cTauVegProperties.p_kfVeg: Vegetation type stressor values on the the turnover rates

*Outputs*
 - land.cTau.p_k: values for actual turnover rates
 - land.cTau.p_k

# precompute:
precompute/instantiate time-invariant variables for cTau_mult


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