export fAPAR_cVegLeaf

#! format: off
@bounds @describe @units @with_kw struct fAPAR_cVegLeaf{T1} <: fAPAR
    kEffExt::T1 = 0.005 | (0.0005, 0.05) | "effective light extinction coefficient" | ""
end
#! format: on

function compute(p_struct::fAPAR_cVegLeaf, forcing, land, helpers)
    ## unpack parameters
    @unpack_fAPAR_cVegLeaf p_struct

    ## unpack land variables
    @unpack_land begin
        cVegLeaf ∈ land.pools
        (z_zero, o_one) ∈ land.wCycleBase
    end

    ## calculate variables
    cVegLeaf_sum = totalS(cVegLeaf)
    fAPAR = o_one - exp(-(cVegLeaf_sum * kEffExt))

    ## pack land variables
    @pack_land fAPAR => land.states
    return land
end

@doc """
Compute FAPAR based on carbon pool of the leave; SLA; kLAI

# Parameters
$(SindbadParameters)

---

# compute:
Fraction of absorbed photosynthetically active radiation using fAPAR_cVegLeaf

*Inputs*
 - land.pools.cEco.cVegLeaf

*Outputs*
 - land.states.fAPAR: the value of fAPAR for current time step
 - land.states.fAPAR

---

# Extended help

*References*

*Versions*
 - 1.0 on 24.04.2021 [skoirala]

*Created by:*
 - skoirala
"""
fAPAR_cVegLeaf
