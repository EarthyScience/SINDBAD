export aRespiration_Thornley2000C

#! format: off
@bounds @describe @units @with_kw struct aRespiration_Thornley2000C{T1,T2} <: aRespiration
    RMN::T1 = 0.009085714285714286 | (0.0009085714285714285, 0.09085714285714286) | "Nitrogen efficiency rate of maintenance respiration" | "gC/gN/day"
    YG::T2 = 0.75 | (0.0, 1.0) | "growth yield coefficient, or growth efficiency. Loosely: (1-YG)*GPP is growth respiration" | "gC/gC"
    MTF::T3 = 0.85 | (nothing, nothing) | "" | ""
end
#! format: on

function define(p_struct::aRespiration_Thornley2000C, forcing, land, helpers)
    @unpack_land begin
        cEco ∈ land.pools
        (num_type, 𝟘, 𝟙) ∈ helpers.numbers
    end
    c_efflux = zero(land.pools.cEco)
    p_km = zero(land.pools.cEco) .+ 𝟙
    p_km4su = zero(land.pools.cEco) .+ 𝟙
    auto_respiration_growth = zero(land.pools.cEco)
    auto_respiration_maintain = zero(land.pools.cEco)
    Fd = zero(land.pools.cEco) .+ 𝟙

    ## pack land variables
    @pack_land begin
        (p_km, p_km4su, Fd) => land.aRespiration
        (auto_respiration_growth, auto_respiration_maintain, c_efflux) => land.states
    end
    return land
end

function compute(p_struct::aRespiration_Thornley2000C, forcing, land, helpers)
    ## unpack parameters
    @unpack_aRespiration_Thornley2000C p_struct

    ## unpack land variables
    @unpack_land begin
        (p_km, p_km4su, Fd) ∈ land.aRespiration
        (c_allocation, c_efflux, auto_respiration_growth, auto_respiration_maintain) ∈ land.states
        cEco ∈ land.pools
        gpp ∈ land.fluxes
        p_C2Nveg ∈ land.cCycleBase
        auto_respiration_f_airT ∈ land.aRespirationAirT
    end
    # adjust nitrogen efficiency rate of maintenance respiration to the current
    # model time step
    RMN = RMN / helpers.dates.timesteps_in_day
    zix = getzix(land.pools.cVeg, helpers.pools.zix.cVeg)
    for ix ∈ zix

        @rep_elem MTF => (Fd, ix, :cEco)

        # compute maintenance & growth respiration terms for each vegetation pool
        # according to MODEL C - growth; degradation & resynthesis view of
        # respiration

        # scalars of maintenance respiration for models A; B & C
        # km is the maintenance respiration coefficient [d-1]

        km_ix = min_1(one(eltype(p_C2Nveg)) / p_C2Nveg[ix] * RMN * auto_respiration_f_airT)
        kd_ix = Fd[ix]
        p_km_ix = km_ix * kd_ix
        p_km4su_ix = p_km[ix] * (one(YG) - YG)

        # maintenance respiration: R_m = km * (1.0 - YG) * C; km = km * MTF [before equivalent to kd]
        RA_M_ix = p_km_ix * (one(YG) - YG) * cEco[ix]
        # no negative maintenance respiration
        RA_M_ix = max_0(RA_M_ix)

        # growth respiration: R_g = (1.0 - YG) * (GPP * allocationToPool - R_m)
        RA_G_ix = (one(YG) - YG) * (gpp * c_allocation[ix] - RA_M_ix)

        # no negative growth respiration
        RA_G_ix = max_0(RA_G_ix)

        # total respiration per pool: R_a = R_m + R_g
        cEcoEfflux_ix = RA_M_ix + RA_G_ix
        @rep_elem cEcoEfflux_ix => (c_efflux, ix, :cEco)
        @rep_elem p_km_ix => (p_km, ix, :cEco)
        @rep_elem p_km4su_ix => (p_km4su, ix, :cEco)
        @rep_elem RA_M_ix => (auto_respiration_maintain, ix, :cEco)
        @rep_elem RA_G_ix => (auto_respiration_growth, ix, :cEco)
    end
    ## pack land variables
    @pack_land begin
        (p_km, p_km4su) => land.aRespiration
        (auto_respiration_growth, auto_respiration_maintain, c_efflux) => land.states
    end
    return land
end

@doc """
Estimate autotrophic respiration as maintenance + growth respiration according to Thornley & Cannell [2000]: MODEL C - growth, degradation & resynthesis view of respiration (check Fig.1 of the paper). Computes the km [maintenance [respiration] coefficient].

# Parameters
$(PARAMFIELDS)

---

# compute:
Determine growth and maintenance respiration using aRespiration_Thornley2000C

*Inputs*
 - info.timeScale.stepsPerDay: number of time steps per day
 - land.aRespirationAirT.auto_respiration_f_airT: temperature effect on autrotrophic respiration [δT-1]
 - land.cCycleBase.C2Nveg: carbon to nitrogen ratio [gC.gN-1]
 - land.states.c_allocation: carbon allocation []
 - land.pools.cEco: ecosystem carbon pools [gC.m2]
 - land.fluxes.gpp: gross primary productivity [gC.m2.δT-1]

*Outputs*
 - land.states.c_efflux: autotrophic respiration from each plant pools [gC.m-2.δT-1]
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
aRespiration_Thornley2000C
