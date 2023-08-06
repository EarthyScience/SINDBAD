export gppDiffRadiation_Turner2006

#! format: off
@bounds @describe @units @with_kw struct gppDiffRadiation_Turner2006{T1} <: gppDiffRadiation
    rueRatio::T1 = 0.5 | (0.0001, 1.0) | "ratio of clear sky LUE to max LUE" | ""
end
#! format: on

function define(p_struct::gppDiffRadiation_Turner2006, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppDiffRadiation_Turner2006 p_struct
    @unpack_forcing (Rg, RgPot) ∈ forcing

    ## calculate variables
    CI = Rg / RgPot
    CI_min = CI
    CI_max = CI
    ## pack land variables
    @pack_land (CI_min, CI_max) => land.gppDiffRadiation
    return land
end

function compute(p_struct::gppDiffRadiation_Turner2006, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppDiffRadiation_Turner2006 p_struct
    @unpack_forcing (Rg, RgPot) ∈ forcing
    @unpack_land begin
        (CI_min, CI_max) ∈ land.gppDiffRadiation
        (z_zero, o_one) ∈ land.wCycleBase
        tolerance ∈ helpers.numbers
    end

    ## calculate variables
    CI = Rg / RgPot

    # update the minimum and maximum on the go
    CI_min = min(CI, CI_min)
    CI_max = min(CI, CI_max)

    SCI = (CI - CI_min) / (CI_max - CI_min + tolerance) # @needscheck: originally, CI_min and max were calculated in the instantiate using the full time series of Rg and RgPot. Now, this is not possible, and thus min and max need to be updated on the go, and once the simulation is complete in the first cycle of forcing, it will work...

    cScGPP = (o_one - rueRatio) * SCI + rueRatio
    gpp_f_cloud = RgPot > z_zero ? cScGPP : z_zero

    ## pack land variables
    @pack_land (gpp_f_cloud, CI_min, CI_max) => land.gppDiffRadiation
    return land
end

@doc """
cloudiness scalar [radiation diffusion] on gpp_potential based on Turner2006

# Parameters
$(SindbadParameters)

---

# compute:

*Inputs*
 - forcing.Rg: Global radiation [SW incoming] [MJ/m2/time]
 - forcing.RgPot: Potential radiation [MJ/m2/time]

*Outputs*
 - land.gppDiffRadiation.gpp_f_cloud: effect of cloudiness on potential GPP

---

# Extended help

*References*
 - Turner, D. P., Ritts, W. D., Styles, J. M., Yang, Z., Cohen, W. B., Law, B. E., & Thornton, P. E. (2006).  A diagnostic carbon flux model to monitor the effects of disturbance & interannual variation in  climate on regional NEP. Tellus B: Chemical & Physical Meteorology, 58[5], 476-490.  DOI: 10.1111/j.1600-0889.2006.00221.x

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up 

*Created by:*
 - mjung
 - ncarval
"""
gppDiffRadiation_Turner2006
