export groundWRecharge_dos

#! format: off
@bounds @describe @units @with_kw struct groundWRecharge_dos{T1} <: groundWRecharge
    dos_exp::T1 = 1.5 | (1.1, 3.0) | "exponent of non-linearity for dos influence on drainage to groundwater" | ""
end
#! format: on

function define(p_struct::groundWRecharge_dos, forcing, land, helpers)
    ## unpack land variables
    @unpack_land begin
        z_zero ∈ land.wCycleBase
    end

    gw_recharge = z_zero

    ## pack land variables
    @pack_land begin
        gw_recharge => land.fluxes
    end
    return land
end

function compute(p_struct::groundWRecharge_dos, forcing, land, helpers)
    ## unpack parameters
    @unpack_groundWRecharge_dos p_struct

    ## unpack land variables
    @unpack_land begin
        (p_wSat, p_β) ∈ land.soilWBase
        (groundW, soilW) ∈ land.pools
        (ΔsoilW, ΔgroundW) ∈ land.states
        (z_zero, o_one) ∈ land.wCycleBase
        n_groundW ∈ land.wCycleBase
    end
    # calculate recharge
    dosSoilEnd = clamp_01((soilW[end] + ΔsoilW[end]) / p_wSat[end])
    recharge_fraction = clamp_01((dosSoilEnd)^(dos_exp * p_β[end]))
    gw_recharge = recharge_fraction * (soilW[end] + ΔsoilW[end])

    ΔgroundW = add_to_each_elem(ΔgroundW, gw_recharge / n_groundW)
    @add_to_elem -gw_recharge => (ΔsoilW, lastindex(ΔsoilW), :soilW)

    ## pack land variables
    @pack_land begin
        gw_recharge => land.fluxes
        (ΔsoilW, ΔgroundW) => land.states
    end
    return land
end

function update(p_struct::groundWRecharge_dos, forcing, land, helpers)

    ## unpack variables
    @unpack_land begin
        (soilW, groundW) ∈ land.pools
        (ΔsoilW, ΔgroundW) ∈ land.states
    end

    ## update storage pools
    soilW[end] = soilW[end] + ΔsoilW[end]
    groundW .= groundW .+ ΔgroundW

    # reset ΔsoilW[end] and ΔgroundW to zero
    ΔsoilW[end] = ΔsoilW[end] - ΔsoilW[end]
    ΔgroundW .= ΔgroundW .- ΔgroundW

    ## pack land variables
    @pack_land begin
        (groundW, soilW) => land.pools
        (ΔsoilW, ΔgroundW) => land.states
    end
    return land
end

@doc """
GW recharge as a exponential functions of the degree of saturation of the lowermost soil layer

# Parameters
$(PARAMFIELDS)

---

# compute:
Recharge the groundwater using groundWRecharge_dos

*Inputs*
 - land.pools.soilW
 - rf

*Outputs*
 - land.fluxes.gw_recharge

# update

update pools and states in groundWRecharge_dos

 - land.pools.groundW[1]

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: clean up  

*Created by:*
 - skoirala
"""
groundWRecharge_dos
