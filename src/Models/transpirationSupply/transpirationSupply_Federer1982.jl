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

purpose(::Type{transpirationSupply_Federer1982}) = "calculate the supply limited transpiration as a function of max rate parameter & avaialable water"

@doc """

$(getBaseDocString(transpirationSupply_Federer1982))

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala | @dr-ko]

*Created by*
 - skoirala | @dr-ko
"""
transpirationSupply_Federer1982
