export autoRespiration_Thornley2000C

#! format: off
@bounds @describe @units @timescale @with_kw struct autoRespiration_Thornley2000C{T1,T2,T3} <: autoRespiration
    RMN::T1 = 0.009085714285714286 | (0.0009085714285714285, 0.09085714285714286) | "Nitrogen efficiency rate of maintenance respiration" | "gC/gN/year" | "year"
    YG::T2 = 0.75 | (0.0, 1.0) | "growth yield coefficient, or growth efficiency. Loosely: (1-YG)*GPP is growth respiration" | "gC/gC" | ""
    MTF::T3 = 0.85 | (-Inf, Inf) | "" | "" | ""
end
#! format: on

function define(params::autoRespiration_Thornley2000C, forcing, land, helpers)
    @unpack_nt begin
        cEco ⇐ land.pools
    end
    c_eco_efflux = zero(cEco)
    k_respiration_maintain = one.(cEco)
    k_respiration_maintain_su = one.(cEco)
    auto_respiration_growth = zero(cEco)
    auto_respiration_maintain = zero(cEco)
    Fd = one.(cEco)

    ## pack land variables
    @pack_nt begin
        (k_respiration_maintain, k_respiration_maintain_su, Fd) ⇒ land.diagnostics
        (auto_respiration_growth, auto_respiration_maintain, c_eco_efflux) ⇒ land.fluxes
    end
    return land
end

function compute(params::autoRespiration_Thornley2000C, forcing, land, helpers)
    ## unpack parameters
    @unpack_autoRespiration_Thornley2000C params

    ## unpack land variables
    @unpack_nt begin
        (k_respiration_maintain, k_respiration_maintain_su, Fd) ⇐ land.diagnostics
        (c_eco_efflux, auto_respiration_growth, auto_respiration_maintain) ⇐ land.fluxes
        (cEco, cVeg) ⇐ land.pools
        gpp ⇐ land.fluxes
        C_to_N_cVeg ⇐ land.diagnostics
        cVegZix = cVeg ⇐ helpers.pools.zix
        (auto_respiration_f_airT, c_allocation) ⇐ land.diagnostics
        (z_zero, o_one) ⇐ land.constants
    end
    # adjust nitrogen efficiency rate of maintenance respiration to the current
    # model time step
    zix = getZix(cVeg, cVegZix)
    for ix ∈ zix

        @rep_elem MTF ⇒ (Fd, ix, :cEco)

        # compute maintenance & growth respiration terms for each vegetation pool
        # according to MODEL C - growth; degradation & resynthesis view of
        # respiration

        # scalars of maintenance respiration for models A; B & C
        # km is the maintenance respiration coefficient [d-1]

        km_ix = minOne(o_one / C_to_N_cVeg[ix] * RMN * auto_respiration_f_airT)
        kd_ix = Fd[ix]
        k_respiration_maintain_ix = km_ix * kd_ix
        k_respiration_maintain_su_ix = k_respiration_maintain[ix] * (o_one - YG)

        # maintenance respiration: R_m = km * (1.0 - YG) * C; km = km * MTF [before equivalent to kd]
        RA_M_ix = k_respiration_maintain_ix * (o_one - YG) * cEco[ix]
        # no negative maintenance respiration
        RA_M_ix = maxZero(RA_M_ix)

        # growth respiration: R_g = (1.0 - YG) * (GPP * allocationToPool - R_m)
        RA_G_ix = (o_one - YG) * (gpp * c_allocation[ix] - RA_M_ix)

        # no negative growth respiration
        RA_G_ix = maxZero(RA_G_ix)

        # total respiration per pool: R_a = R_m + R_g
        cEcoEfflux_ix = RA_M_ix + RA_G_ix
        @rep_elem cEcoEfflux_ix ⇒ (c_eco_efflux, ix, :cEco)
        @rep_elem k_respiration_maintain_ix ⇒ (k_respiration_maintain, ix, :cEco)
        @rep_elem k_respiration_maintain_su_ix ⇒ (k_respiration_maintain_su, ix, :cEco)
        @rep_elem RA_M_ix ⇒ (auto_respiration_maintain, ix, :cEco)
        @rep_elem RA_G_ix ⇒ (auto_respiration_growth, ix, :cEco)
    end
    ## pack land variables
    @pack_nt begin
        (k_respiration_maintain, k_respiration_maintain_su) ⇒ land.diagnostics
        (auto_respiration_growth, auto_respiration_maintain, c_eco_efflux) ⇒ land.fluxes
    end
    return land
end

@doc """
Estimate autotrophic respiration as maintenance + growth respiration according to Thornley & Cannell [2000]: MODEL C - growth, degradation & resynthesis view of respiration (check Fig.1 of the paper). Computes the km [maintenance [respiration] coefficient].

# Parameters
$(SindbadParameters)

---

# compute:
Determine growth and maintenance respiration using autoRespiration_Thornley2000C

*Inputs*
 - info.timeScale.stepsPerDay: number of time steps per day
 - land.diagnostics.auto_respiration_f_airT: temperature effect on autrotrophic respiration [δT-1]
 - land.diagnostics.C_to_N_cVeg: carbon to nitrogen ratio [gC.gN-1]
 - land.diagnostics.c_allocation: carbon allocation []
 - cEco: ecosystem carbon pools [gC.m2]
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
autoRespiration_Thornley2000C
