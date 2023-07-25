export cCycleBase_simple

#! format: off
@bounds @describe @units @with_kw struct cCycleBase_simple{T1,T2,T3} <: cCycleBase
    annk::T1 = Float64[1, 0.03, 0.03, 1, 14.8, 3.9, 18.5, 4.8, 0.2424, 0.2424, 6, 7.3, 0.2, 0.0045] | (Float64[0.05, 0.002, 0.002, 0.05, 1.48, 0.39, 1.85, 0.48, 0.02424, 0.02424, 0.6, 0.73, 0.02, 0.0045], Float64[3.3, 0.5, 0.5, 3.3, 148.0, 39.0, 185.0, 48.0, 2.424, 2.424, 60.0, 73.0, 2.0, 0.045]) | "turnover rate of ecosystem carbon pools" | "yr-1"
    c_flow_A_array::T2 = Float64[
                     -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
                     0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
                     0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
                     0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
                     0.0 0.0 0.0 0.54 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
                     0.0 0.0 0.0 0.46 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
                     0.54 0.0 0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
                     0.46 0.0 0.0 0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0
                     0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0
                     0.0 1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0
                     0.0 0.0 0.0 0.0 0.4 0.15 0.0 0.0 0.24 0.0 -1.0 0.0 0.0 0.0
                     0.0 0.0 0.0 0.0 0.0 0.0 0.45 0.17 0.0 0.24 0.0 -1.0 0.0 0.0
                     0.0 0.0 0.0 0.0 0.0 0.43 0.0 0.43 0.28 0.28 0.4 0.43 -1.0 0.0
                     0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.005 0.0026 -1.0
                 ] | (nothing, nothing) | "Transfer matrix for carbon at ecosystem level" | ""
    p_C_to_N_cVeg::T3 = Float64[25.0, 260.0, 260.0, 25.0] | (nothing, nothing) | "carbon to nitrogen ratio in vegetation pools" | "gC/gN"
end
#! format: on

function define(p_struct::cCycleBase_simple, forcing, land, helpers)
    @unpack_cCycleBase_simple p_struct

    @unpack_land begin
        cEco ∈ land.pools
    end
    ## instantiate variables
    C_to_N_cVeg = zero(cEco) .+ one(first(cEco)) #sujan

    ## pack land variables
    @pack_land begin
        (C_to_N_cVeg, c_flow_A_array) => land.cCycleBase
    end
    return land
end

function compute(p_struct::cCycleBase_simple, forcing, land, helpers)
    ## unpack parameters
    @unpack_cCycleBase_simple p_struct

    ## unpack land variables
    @unpack_land begin
        C_to_N_cVeg ∈ land.cCycleBase
        o_one ∈ land.wCycleBase
    end

    ## calculate variables
    #carbon to nitrogen ratio [gC.gN-1]
    C_to_N_cVeg[getzix(land.pools.cVeg, helpers.pools.zix.cVeg)] .= p_C_to_N_cVeg

    # turnover rates
    TSPY = helpers.dates.timesteps_in_year
    c_eco_k_base = o_one .- (exp.(-o_one .* annk) .^ (o_one / TSPY))

    ## pack land variables
    @pack_land (C_to_N_cVeg, c_eco_k_base, c_flow_A_array) => land.cCycleBase

    return land
end

@doc """
Compute carbon to nitrogen ratio & annual turnover rates

# Parameters
$(PARAMFIELDS)

---

# compute:
Pool structure of the carbon cycle using cCycleBase_simple

*Inputs*

*Outputs*

# instantiate:
instantiate/instantiate time-invariant variables for cCycleBase_simple


---

# Extended help

*References*
 - Potter; C. S.; J. T. Randerson; C. B. Field; P. A. Matson; P. M.  Vitousek; H. A. Mooney; & S. A. Klooster. 1993. Terrestrial ecosystem  production: A process model based on global satellite & surface data.  Global Biogeochemical Cycles. 7: 811-841.

*Versions*
 - 1.0.0 on 28.02.2020.0 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cCycleBase_simple
