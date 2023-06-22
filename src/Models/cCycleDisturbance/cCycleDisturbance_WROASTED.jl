export cCycleDisturbance_WROASTED

#! format: off
struct cCycleDisturbance_WROASTED <: cCycleDisturbance end
#! format: on

function define(o::cCycleDisturbance_WROASTED, forcing, land, helpers)
    @unpack_land begin
        (giver, taker) ∈ land.cCycleBase
    end
    zixVegAll = Tuple(vcat(getzix(getfield(land.pools, :cVeg), helpers.pools.zix.cVeg)...))
    ndxLoseToZixVec = []
    for zixVeg ∈ zixVegAll
        # make reserve pool flow to slow litter pool/woody debris
        if helpers.pools.components.cEco[zixVeg] == :cVegReserve
            ndxLoseToZix = helpers.pools.zix.cLitSlow
        else
            ndxLoseToZix = taker[[(giver .== zixVeg)...]]
        end
        ndxNoVeg = []
        for ndxl ∈ ndxLoseToZix
            if ndxl ∉ zixVegAll
                push!(ndxNoVeg, ndxl)
            end
        end
        push!(ndxLoseToZixVec, Tuple(ndxNoVeg))
    end
    ndxLoseToZixVec = Tuple(ndxLoseToZixVec)
    @pack_land (zixVegAll, ndxLoseToZixVec) => land.cCycleDisturbance
    return land
end

function compute(o::cCycleDisturbance_WROASTED, forcing, land, helpers)
    ## unpack forcing
    @unpack_forcing isDisturbed ∈ forcing

    ## unpack land variables
    @unpack_land begin
        (zixVegAll, ndxLoseToZixVec) ∈ land.cCycleDisturbance
        cEco ∈ land.pools
        (giver, taker, carbon_remain) ∈ land.cCycleBase
        𝟘 ∈ helpers.numbers
    end
    if isDisturbed > 𝟘
        for zixVeg ∈ zixVegAll
            cLoss = max(cEco[zixVeg] - carbon_remain, 𝟘) * isDisturbed
            @add_to_elem -cLoss => (cEco, zixVeg, :cEco)
            ndxLoseToZix = ndxLoseToZixVec[zixVeg]
            for tZ ∈ eachindex(ndxLoseToZix)
                tarZix = ndxLoseToZix[tZ]
                toGain = cLoss / length(ndxLoseToZix)
                @add_to_elem toGain => (cEco, tarZix, :cEco)
            end
        end

    end
    ## pack land variables
    @pack_land cEco => land.pools
    return land
end

@doc """
move all vegetation carbon pools except reserve to respective flow target when there is disturbance

# Parameters
$(PARAMFIELDS)

---

# compute:
Disturb the carbon cycle pools using cCycleDisturbance_WROASTED

*Inputs*
 - land.pools.cEco: carbon pool at the end of spinup

*Outputs*

# update

update pools and states in cCycleDisturbance_WROASTED

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
cCycleDisturbance_WROASTED
