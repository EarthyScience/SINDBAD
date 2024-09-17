export drainage_dos

#! format: off
@bounds @describe @units @with_kw struct drainage_dos{T1} <: drainage
    dos_exp::T1 = 1.5 | (0.1, 3.0) | "exponent of non-linearity for dos influence on drainage in soil" | ""
end
#! format: on

function define(params::drainage_dos, forcing, land, helpers)
    ## unpack parameters

    ## unpack land variables
    @unpack_nt begin
        ΔsoilW ⇐ land.pools
    end
    drainage = zero(ΔsoilW)

    ## pack land variables
    @pack_nt begin
        drainage ⇒ land.fluxes
    end
    return land
end

function compute(params::drainage_dos, forcing, land, helpers)
    ## unpack parameters
    @unpack_drainage_dos params

    ## unpack land variables
    @unpack_nt begin
        drainage ⇐ land.fluxes
        (w_sat, soil_β, w_fc) ⇐ land.properties
        (soilW, ΔsoilW) ⇐ land.pools
        (z_zero, o_one) ⇐ land.constants
        tolerance ⇐ helpers.numbers
    end

    ## calculate drainage
    for sl ∈ 1:(length(land.pools.soilW)-1)
        soilW_sl = min(maxZero(soilW[sl] + ΔsoilW[sl]), w_sat[sl])
        drain_fraction = clampZeroOne(((soilW_sl) / w_sat[sl])^(dos_exp * soil_β[sl]))
        drainage_tmp = drain_fraction * (soilW_sl)
        max_drain = w_sat[sl] - w_fc[sl]
        lossCap = min(soilW_sl, max_drain)
        holdCap = w_sat[sl+1] - (soilW[sl+1] + ΔsoilW[sl+1])
        drain = min(drainage_tmp, holdCap, lossCap)
        tmp = drain > tolerance ? drain : zero(drain)
        @rep_elem tmp ⇒ (drainage, sl, :soilW)
        @add_to_elem -tmp ⇒ (ΔsoilW, sl, :soilW)
        @add_to_elem tmp ⇒ (ΔsoilW, sl + 1, :soilW)
    end
    @rep_elem z_zero ⇒ (drainage, lastindex(drainage), :soilW)
    ## pack land variables
    @pack_nt begin
        drainage ⇒ land.fluxes
        ΔsoilW ⇒ land.pools
    end
    return land
end

function update(params::drainage_dos, forcing, land, helpers)

    ## unpack variables
    @unpack_nt begin
        soilW ⇐ land.pools
        ΔsoilW ⇐ land.pools
    end

    ## update variables
    # update soil moisture
    soilW .= soilW .+ ΔsoilW

    # reset soil moisture changes to zero
    ΔsoilW .= ΔsoilW .- ΔsoilW

    ## pack land variables
    # @pack_nt begin
    # 	soilW ⇒ land.pools
    # 	ΔsoilW ⇒ land.pools
    # end
    return land
end

@doc """
downward flow of moisture [drainage] in soil layers based on exponential function of soil moisture degree of saturation

# Parameters
$(SindbadParameters)

---

# compute:
Recharge the soil using drainage_dos

*Inputs*
 - land.pools.soilW: soil moisture in different layers
 - land.soilProperties.unsatK: function to calculate unsaturated hydraulic conduct.

*Outputs*
 - drainage from the last layer is saved as groundwater recharge [gw_recharge]
 - land.states.soilWFlow: drainage flux between soil layers (same as nZix, from percolation  into layer 1 & the drainage to the last layer)

# update

update pools and states in drainage_dos

 - land.pools.soilW

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
drainage_dos
