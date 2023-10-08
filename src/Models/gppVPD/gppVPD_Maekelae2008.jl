export gppVPD_Maekelae2008

#! format: off
@bounds @describe @units @with_kw struct gppVPD_Maekelae2008{T1} <: gppVPD
    k::T1 = 0.4 | (0.06, 0.7) | "empirical parameter assuming typically negative values" | "kPa-1"
end
#! format: on

function compute(p_struct::gppVPD_Maekelae2008, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppVPD_Maekelae2008 p_struct
    @unpack_forcing f_VPD_day ∈ forcing
    @unpack_land o_one ∈ land.wCycleBase

    ## calculate variables
    gpp_f_vpd = exp(-k * f_VPD_day)
    gpp_f_vpd = minOne(gpp_f_vpd)

    ## pack land variables
    @pack_land gpp_f_vpd => land.gppVPD
    return land
end

@doc """
calculate the VPD stress on gpp_potential based on Maekelae2008 [eqn 5]

# Parameters
$(SindbadParameters)

---

# compute:
Vpd effect using gppVPD_Maekelae2008

*Inputs*

*Outputs*
 - land.gppVPD.gpp_f_vpd: VPD effect on GPP between 0-1

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
