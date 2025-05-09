export groundWRecharge_fraction

#! format: off
@bounds @describe @units @timescale @with_kw struct groundWRecharge_fraction{T1} <: groundWRecharge
    rf::T1 = 0.1 | (0.02, 0.98) | "fraction of land runoff that percolates to groundwater" | "" | ""
end
#! format: on

function compute(params::groundWRecharge_fraction, forcing, land, helpers)
    ## unpack parameters
    @unpack_groundWRecharge_fraction params

    ## unpack land variables
    @unpack_nt begin
        (ΔsoilW, soilW, ΔgroundW, groundW) ⇐ land.pools
        n_groundW ⇐ land.constants
    end

    ## calculate variables
    # calculate recharge
    gw_recharge = rf * (soilW[end] + ΔsoilW[end])

    ΔgroundW .= ΔgroundW .+ gw_recharge / n_groundW
    ΔsoilW[end] = ΔsoilW[end] - gw_recharge

    ## pack land variables
    @pack_nt begin
        gw_recharge ⇒ land.fluxes
        (ΔsoilW, ΔgroundW) ⇒ land.pools
    end
    return land
end

purpose(::Type{groundWRecharge_fraction}) = "GW recharge as a fraction of moisture of the lowermost soil layer"

@doc """

$(getModelDocString(groundWRecharge_fraction))

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala | @dr-ko]: clean up  

*Created by*
 - skoirala | @dr-ko
"""
groundWRecharge_fraction
