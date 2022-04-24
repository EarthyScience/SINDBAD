export gppVPD_Maekelae2008

@bounds @describe @units @with_kw struct gppVPD_Maekelae2008{T1} <: gppVPD
    k::T1 = 0.4 | (0.06, 0.7) | "empirical parameter assuming typically negative values" | "kPa-1"
end

function compute(o::gppVPD_Maekelae2008, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppVPD_Maekelae2008 o
    @unpack_forcing VPDDay ∈ forcing
    @unpack_land (zero, one) ∈ helpers.numbers


    ## calculate variables
    VPDScGPP = exp(-k * VPDDay)
    VPDScGPP = min(VPDScGPP, one)

    ## pack land variables
    @pack_land VPDScGPP => land.gppVPD
    return land
end

@doc """
calculate the VPD stress on gppPot based on Maekelae2008 [eqn 5]

# Parameters
$(PARAMFIELDS)

---

# compute:
Vpd effect using gppVPD_Maekelae2008

*Inputs*

*Outputs*
 - land.gppVPD.VPDScGPP: VPD effect on GPP between 0-1

---

# Extended help

*References*

*Versions*

*Created by:*
 - ncarval

*Notes*
 - Equation 5. a negative exponent is introduced to have positive parameter  values
"""
gppVPD_Maekelae2008