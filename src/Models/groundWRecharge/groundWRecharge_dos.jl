export groundWRecharge_dos

#! format: off
@bounds @describe @units @timescale @with_kw struct groundWRecharge_dos{T1} <: groundWRecharge
    dos_exp::T1 = 1.5 | (1.0, 3.0) | "exponent of non-linearity for dos influence on drainage to groundwater" | "" | ""
end
#! format: on

function define(params::groundWRecharge_dos, forcing, land, helpers)
    ## unpack land variables
    @unpack_nt begin
        z_zero ⇐ land.constants
    end

    gw_recharge = z_zero

    ## pack land variables
    @pack_nt begin
        gw_recharge ⇒ land.fluxes
    end
    return land
end

function compute(params::groundWRecharge_dos, forcing, land, helpers)
    ## unpack parameters
    @unpack_groundWRecharge_dos params

    ## unpack land variables
    @unpack_nt begin
        (w_sat, soil_β) ⇐ land.properties
        (ΔsoilW, soilW, ΔgroundW, groundW) ⇐ land.pools
        (z_zero, o_one) ⇐ land.constants
        n_groundW ⇐ land.constants
    end
    # calculate recharge
    dos_soil_end = clampZeroOne((soilW[end] + ΔsoilW[end]) / w_sat[end])
    recharge_fraction = clampZeroOne((dos_soil_end)^(dos_exp * soil_β[end]))
    gw_recharge = recharge_fraction * (soilW[end] + ΔsoilW[end])

    ΔgroundW = addToEachElem(ΔgroundW, gw_recharge / n_groundW)
    @add_to_elem -gw_recharge ⇒ (ΔsoilW, lastindex(ΔsoilW), :soilW)

    ## pack land variables
    @pack_nt begin
        gw_recharge ⇒ land.fluxes
        (ΔsoilW, ΔgroundW) ⇒ land.pools
    end
    return land
end

function update(params::groundWRecharge_dos, forcing, land, helpers)

    ## unpack variables
    @unpack_nt begin
        (soilW, groundW) ⇐ land.pools
        (ΔsoilW, ΔgroundW) ⇐ land.states
    end

    ## update storage pools
    soilW[end] = soilW[end] + ΔsoilW[end]
    groundW .= groundW .+ ΔgroundW

    # reset ΔsoilW[end] and ΔgroundW to zero
    ΔsoilW[end] = ΔsoilW[end] - ΔsoilW[end]
    ΔgroundW .= ΔgroundW .- ΔgroundW

    ## pack land variables
    @pack_nt begin
        (groundW, soilW) ⇒ land.pools
        (ΔsoilW, ΔgroundW) ⇒ land.pools
    end
    return land
end

@doc """
GW recharge as a exponential functions of the degree of saturation of the lowermost soil layer

# Parameters
$(SindbadParameters)

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
