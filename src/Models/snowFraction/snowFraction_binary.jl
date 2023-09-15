export snowFraction_binary

struct snowFraction_binary <: snowFraction end

function compute(p_struct::snowFraction_binary, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        snowW ∈ land.pools
        ΔsnowW ∈ land.states
        (z_zero, o_one) ∈ land.wCycleBase
    end

    # if there is snow; then snow fraction is 1; otherwise 0
    tot_snow = totalS(snowW, ΔsnowW)
    frac_snow = tot_snow > z_zero ? one(tot_snow) : zero(tot_snow)

    ## pack land variables
    @pack_land frac_snow => land.states
    return land
end

@doc """
compute the fraction of snow cover.

---

# compute:
Calculate snow cover fraction using snowFraction_binary

*Inputs*
 - land.fluxes.snow : snow fall [mm/time]

*Outputs*
 - land.states.frac_snow: sets frac_snow to 1 if there is snow; to 0 if there  is now snow

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - mjung
"""
snowFraction_binary
