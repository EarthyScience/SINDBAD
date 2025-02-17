export transpirationSupply_Federer1982

#! format: off
@bounds @describe @units @timescale @with_kw struct transpirationSupply_Federer1982{T1} <: transpirationSupply
    max_t_loss::T1 = 5.0 | (0.1, 20.0) | "Maximum rate of transpiration in mm/day" | "mm/day" | ""
end
#! format: on

function compute(params::transpirationSupply_Federer1982, forcing, land, helpers)
    ## unpack parameters
    @unpack_transpirationSupply_Federer1982 params

    ## unpack land variables
    @unpack_nt begin
        PAW ⇐ land.states
        ∑w_sat ⇐ land.properties
    end
    transpiration_supply = max_t_loss * sum(PAW) / ∑w_sat

    ## pack land variables
    @pack_nt transpiration_supply ⇒ land.diagnostics
    return land
end

@doc """
calculate the supply limited transpiration as a function of max rate parameter & avaialable water

# Parameters
$(SindbadParameters)

---

# compute:
Supply-limited transpiration using transpirationSupply_Federer1982

*Inputs*
 - land.pools.soilW : total soil moisture
 - land.properties.w_awc: total maximum plant available water [_fc-_wp]
 - land.states.PAW: actual extractable water

*Outputs*
 - land.states.transpiration_supply: demand driven transpiration

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
transpirationSupply_Federer1982
