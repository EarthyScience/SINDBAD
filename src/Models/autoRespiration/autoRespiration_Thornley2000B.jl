export autoRespiration_Thornley2000B

#! format: off
@bounds @describe @units @with_kw struct autoRespiration_Thornley2000B{T1,T2} <: autoRespiration
    RMN::T1 = 0.009085714285714286 | (0.0009085714285714285, 0.09085714285714286) | "Nitrogen efficiency rate of maintenance respiration" | "gC/gN/day"
    YG::T2 = 0.75 | (0.0, 1.0) | "growth yield coefficient, or growth efficiency. Loosely: (1-YG)*GPP is growth respiration" | "gC/gC"
end
#! format: on

function define(params::autoRespiration_Thornley2000B, forcing, land, helpers)
    @unpack_land begin
        cEco ∈ land.pools
    end
    c_eco_efflux = zero(land.pools.cEco)
    k_respiration_maintain = one.(land.pools.cEco)
    k_respiration_maintain_su = one.(land.pools.cEco)
    auto_respiration_growth = zero(land.pools.cEco)
    auto_respiration_maintain = zero(land.pools.cEco)

    ## pack land variables
    @pack_land begin
        (k_respiration_maintain, k_respiration_maintain_su) => land.autoRespiration
        (auto_respiration_growth, auto_respiration_maintain, c_eco_efflux) => land.states
    end
    return land
end

function compute(params::autoRespiration_Thornley2000B, forcing, land, helpers)
    ## unpack parameters
    @unpack_autoRespiration_Thornley2000B params

    ## unpack land variables
    @unpack_land begin
        (k_respiration_maintain, k_respiration_maintain_su) ∈ land.autoRespiration
        (c_allocation, c_eco_efflux, auto_respiration_growth, auto_respiration_maintain) ∈ land.states
        cEco ∈ land.pools
        gpp ∈ land.fluxes
        C_to_N_cVeg ∈ land.cCycleBase
        auto_respiration_f_airT ∈ land.autoRespirationAirT
    end
    # adjust nitrogen efficiency rate of maintenance respiration to the current
    # model time step
    RMN = RMN / helpers.dates.timesteps_in_day
    zix = getZix(land.pools.cVeg, helpers.pools.zix.cVeg)
    for ix ∈ zix

        # compute maintenance & growth respiration terms for each vegetation pool
        # according to MODEL B - growth respiration is given priority

        # scalars of maintenance respiration for models A; B & C
        # km is the maintenance respiration coefficient [d-1]
        k_respiration_maintain_ix = minOne(one(eltype(C_to_N_cVeg)) / C_to_N_cVeg[ix] * RMN * auto_respiration_f_airT)
        k_respiration_maintain_su_ix = k_respiration_maintain[ix] * YG

        # growth respiration: R_g = (1.0 - YG) * (GPP * allocationToPool - R_m)
        RA_G_ix = (one(YG) - YG) * (gpp * c_allocation[ix])

        # maintenance respiration: R_m = km * (C + YG * GPP * allocationToPool)
        RA_M_ix = k_respiration_maintain_ix * (cEco[ix] + YG * gpp * c_allocation[ix])

        # no negative growth or maintenance respiration
        RA_G_ix = maxZero(RA_G_ix)
        RA_M_ix = maxZero(RA_M_ix)

        # total respiration per pool: R_a = R_m + R_g
        cEcoEfflux_ix = RA_M_ix + RA_G_ix
        @rep_elem cEcoEfflux_ix => (c_eco_efflux, ix, :cEco)
        @rep_elem k_respiration_maintain_ix => (k_respiration_maintain, ix, :cEco)
        @rep_elem k_respiration_maintain_su_ix => (k_respiration_maintain_su, ix, :cEco)
        @rep_elem RA_M_ix => (auto_respiration_maintain, ix, :cEco)
        @rep_elem RA_G_ix => (auto_respiration_growth, ix, :cEco)
    end
    ## pack land variables
    @pack_land begin
        (k_respiration_maintain, k_respiration_maintain_su) => land.autoRespiration
        (auto_respiration_growth, auto_respiration_maintain, c_eco_efflux) => land.states
    end
    return land
end

@doc """
Estimate autotrophic respiration as maintenance + growth respiration according to Thornley & Cannell [2000]: MODEL B - growth respiration is given priority [check Fig.1 of the paper].

# Parameters
$(SindbadParameters)

---

# compute:
Determine growth and maintenance respiration using autoRespiration_Thornley2000A

*Inputs*
 - info.timeScale.stepsPerDay: number of time steps per day
 - land.autoRespirationAirT.auto_respiration_f_airT: temperature effect on autrotrophic respiration [δT-1]
 - land.cCycleBase.C_to_N_cVeg: carbon to nitrogen ratio [gC.gN-1]
 - land.states.c_allocation: carbon allocation []
 - land.pools.cEco: ecosystem carbon pools [gC.m2]
 - land.fluxes.gpp: gross primary productivity [gC.m2.δT-1]

*Outputs*
 - land.states.c_eco_efflux: autotrophic respiration from each plant pools [gC.m-2.δT-1]
 - land.states.auto_respiration_growth: growth respiration from each plant pools [gC.m-2.δT-1]
 - land.states.auto_respiration_maintain: maintenance respiration from each plant pools [gC.m-2.δT-1]

---

# Extended help

*References*
 - Amthor, J. S. (2000), The McCree-de Wit-Penning de Vries-Thornley  respiration paradigms: 30 years later, Ann Bot-London, 86[1], 1-20.  Ryan, M. G. (1991), Effects of Climate Change on Plant Respiration, Ecol  Appl, 1[2], 157-167.
 - Thornley, J. H. M., & M. G. R. Cannell [2000], Modelling the components  of plant respiration: Representation & realism, Ann Bot-London, 85[1]  55-67.

*Versions*
 - 1.0 on 06.05.2022 [ncarval/skoirala]: cleaned up the code

*Created by:*
 - ncarval

*Notes*
 - Questions - practical - leave raAct per pool; | make a field land.fluxes.ra  that has all the autotrophic respiration components together?  
"""
autoRespiration_Thornley2000B
