export cTau_mult

struct cTau_mult <: cTau end

function instantiate(o::cTau_mult, forcing, land, helpers)
    ## unpack land variables
    @unpack_land begin
        cEco ∈ land.pools
    end
    p_k = zero(cEco)

    ## pack land variables
    @pack_land p_k => land.states
    return land
end

function compute(o::cTau_mult, forcing, land, helpers)
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
    for i in eachindex(p_k)
        tmp = p_k_base[i] * p_kfLAI[i] * p_kfSoil[i] * p_kfVeg[i] * fT * p_fsoilW[i]
        tmp = clamp(tmp, 𝟘, 𝟙)
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
 - land.cTauLAI.p_kfLAI: LAI stressor values on the the turnover rates
 - land.cTauSoilProperties.p_kfSoil: Soil texture stressor values on the the turnover rates
 - land.cTauSoilT.fT: Air temperature stressor values on the the turnover rates
 - land.cTauSoilW.fsoilW: Soil moisture stressor values on the the turnover rates
 - land.cTauVegProperties.p_kfVeg: Vegetation type stressor values on the the turnover rates

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