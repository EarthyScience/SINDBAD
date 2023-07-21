export cCycleBase_CASA

#! format: off
@bounds @describe @units @with_kw struct cCycleBase_CASA{T1,T2,T3,T4,T5,T6,T7} <: cCycleBase
    annk::T1 = Float64[1, 0.03, 0.03, 1, 14.8, 3.9, 18.5, 4.8, 0.2424, 0.2424, 6, 7.3, 0.2, 0.0045] | (Float64[0.05, 0.002, 0.002, 0.05, 1.48, 0.39, 1.85, 0.48, 0.02424, 0.02424, 0.6, 0.73, 0.02, 0.0045], Float64[3.3, 0.5, 0.5, 3.3, 148.0, 39.0, 185.0, 48.0, 2.424, 2.424, 60.0, 73.0, 2.0, 0.045]) | "turnover rate of ecosystem carbon pools" | "yr-1"
    c_flow_E::T2 = Float64[
                     -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
                     0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
                     0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
                     0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
                     0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
                     0.0 0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
                     0.0 0.0 0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
                     0.0 0.0 0.0 0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0
                     0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0
                     0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0
                     0.0 0.0 0.0 0.0 0.4 0.4 0.0 0.0 0.4 0.0 -1.0 0.0 0.0 0.0
                     0.0 0.0 0.0 0.0 0.0 0.0 0.45 0.45 0.0 0.4 0.0 -1.0 0.45 0.45
                     0.0 0.0 0.0 0.0 0.0 0.6 0.0 0.55 0.6 0.6 0.4 0.0 -1.0 0.0
                     0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.45 -1.0
                 ] | (nothing, nothing) | "Transfer matrix for carbon at ecosystem level" | ""
    cVegRootF_AGE_per_PFT::T3 = Float64[1.8, 1.2, 1.2, 5.0, 1.8, 1.0, 1.0, 0.0, 1.0, 2.8, 1.0, 1.0] | (Float64[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], Float64[20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0]) | "mean age of fine roots" | "yr"
    cVegRootC_AGE_per_PFT::T4 = Float64[41.0, 58.0, 58.0, 42.0, 27.0, 25.0, 25.0, 0.0, 5.5, 40.0, 1.0, 40.0] | (Float64[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], Float64[100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0]) | "mean age of coarse roots" | "yr"
    cVegWood_AGE_per_PFT::T5 = Float64[41.0, 58.0, 58.0, 42.0, 27.0, 25.0, 25.0, 0.0, 5.5, 40.0, 1.0, 40.0] | (Float64[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], Float64[100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0]) | "mean age of wood" | "yr"
    cVegLeaf_AGE_per_PFT::T6 = Float64[1.8, 1.2, 1.2, 5.0, 1.8, 1.0, 1.0, 0.0, 1.0, 2.8, 1.0, 1.0] | (Float64[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], Float64[20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0]) | "mean age of leafs" | "yr"
    C2Nveg::T7 = Float64[25.0, 260.0, 260.0, 25.0] | (nothing, nothing) | "carbon to nitrogen ratio in vegetation pools" | "gC/gN"
end
#! format: on

function define(p_struct::cCycleBase_CASA, forcing, land, helpers)
    @unpack_cCycleBase_CASA p_struct

    @unpack_land begin
        cEco ∈ land.pools
    end

    ## instantiate variables
    p_C2Nveg = zero(cEco) .+ one(first(cEco)) #sujan

    ## pack land variables
    @pack_land begin
        (p_C2Nveg, c_flow_A, c_flow_E) => land.cCycleBase
    end
    return land
end

function compute(p_struct::cCycleBase_CASA, forcing, land, helpers)
    ## unpack parameters
    @unpack_cCycleBase_CASA p_struct

    ## unpack land variables
    @unpack_land begin
        p_C2Nveg ∈ land.cCycleBase
        o_one ∈ land.wCycleBase
    end

    ## calculate variables
    # carbon to nitrogen ratio [gC.gN-1]
    p_C2Nveg[getzix(land.pools.cVeg, helpers.pools.zix.cVeg)] .= C2Nveg

    # turnover rates
    TSPY = helpers.dates.timesteps_in_year
    p_k_base = o_one .- (exp.(-o_one .* annk) .^ (o_one / TSPY))

    ## pack land variables
    @pack_land (p_k_base) => land.cCycleBase
    # @pack_land (p_C2Nveg, p_k_base, c_flow_E) => land.cCycleBase
    return land
end

@doc """
Compute carbon to nitrogen ratio & base turnover rates

# Parameters
$(PARAMFIELDS)

---

# compute:
Pool structure of the carbon cycle using cCycleBase_CASA

*Inputs*

*Outputs*

# instantiate:
instantiate/instantiate time-invariant variables for cCycleBase_CASA


---

# Extended help

*References*
 - Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance & inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
 - Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., & Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data & ecosystem  modeling 1982–1998. Global & Planetary Change, 39[3-4], 201-213.
 - Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite & surface data. Global Biogeochemical Cycles, 7[4], 811-841.

*Versions*
 - 1.0 on 28.05.2022 [skoirala]: migrate to julia  

*Created by:*
 - ncarvalhais
"""
cCycleBase_CASA
