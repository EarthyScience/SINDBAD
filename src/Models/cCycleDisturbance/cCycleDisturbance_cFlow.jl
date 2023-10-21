export cCycleDisturbance_cFlow

#! format: off
struct cCycleDisturbance_cFlow <: cCycleDisturbance end
#! format: on

function define(params::cCycleDisturbance_cFlow, forcing, land, helpers)
    @unpack_land begin
        (c_giver, c_taker) ∈ land.cCycleBase
        (z_zero, o_one) ∈ land.constants
        cVeg ∈ land.pools
    end
    zix_veg_all = Tuple(vcat(getZix(cVeg, helpers.pools.zix.cVeg)...))
    c_lose_to_zix_vec = []
    for zixVeg ∈ zix_veg_all
        c_lose_to_zix = c_taker[[(c_giver .== zixVeg)...]]
        ndxNoVeg = []
        for ndxl ∈ c_lose_to_zix
            if ndxl ∉ zix_veg_all
                push!(ndxNoVeg, ndxl)
            end
        end
        push!(c_lose_to_zix_vec, Tuple(ndxNoVeg))
    end
    c_lose_to_zix_vec = Tuple(c_lose_to_zix_vec)
    @pack_land (zix_veg_all, c_lose_to_zix_vec) → land.cCycleDisturbance
    return land
end

function compute(params::cCycleDisturbance_cFlow, forcing, land, helpers)
    ## unpack forcing
    @unpack_forcing f_dist_intensity ∈ forcing

    ## unpack land variables
    @unpack_land begin
        (zix_veg_all, c_lose_to_zix_vec) ∈ land.cCycleDisturbance
        cEco ∈ land.pools
        (c_giver, c_taker, c_remain) ∈ land.cCycleBase
        c_model ∈ land.models

    end
    if f_dist_intensity > z_zero
        for zixVeg ∈ zix_veg_all
            cLoss = z_zero# do not lose carbon if reserve pool
            if helpers.pools.components.cEco[zixVeg] !== :cVegReserve
                cLoss = maxZero(cEco[zixVeg] - c_remain) * f_dist_intensity
            end
            @add_to_elem -cLoss → (cEco, zixVeg, :cEco)
            c_lose_to_zix = c_lose_to_zix_vec[zixVeg]
            for tZ ∈ eachindex(c_lose_to_zix)
                tarZix = c_lose_to_zix[tZ]
                toGain = cLoss / length(c_lose_to_zix)
                @add_to_elem toGain → (cEco, tarZix, :cEco)
            end
        end
        ## pack land variables
        @pack_land cEco → land.pools
        land = adjustPackPoolComponents(land, helpers, c_model)
    end
    return land
end

@doc """
move all vegetation carbon pools except reserve to respective flow target when there is disturbance

# Parameters
$(SindbadParameters)

---

# compute:
Disturb the carbon cycle pools using cCycleDisturbance_cFlow

*Inputs*
 - land.pools.cEco: carbon pool at the end of spinup

*Outputs*

# update

update pools and states in cCycleDisturbance_cFlow

 - land.pools.cEco

---

# Extended help

*References*
 - Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance & inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].

*Versions*
 - 1.0 on 23.04.2021 [skoirala]
 - 1.0 on 23.04.2021 [skoirala]  
 - 1.1 on 29.11.2021 [skoirala]: moved the scaling parameters to  ccyclebase_gsi [land.cCycleBase.ηA & land.cCycleBase.ηH]  

*Created by:*
 - skoirala
"""
cCycleDisturbance_cFlow
