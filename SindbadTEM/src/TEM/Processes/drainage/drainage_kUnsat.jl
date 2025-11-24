export drainage_kUnsat

struct drainage_kUnsat <: drainage end

function define(params::drainage_kUnsat, forcing, land, helpers)
    @unpack_nt soilW ⇐ land.pools
    ## Instantiate drainage
    drainage = zero(soilW)
    ## pack land variables
    @pack_nt drainage ⇒ land.fluxes
    return land
end

function compute(params::drainage_kUnsat, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt begin
        drainage ⇐ land.fluxes
        unsat_k_model ⇐ land.models
        (w_sat, w_fc, soil_β, k_fc, k_sat) ⇐ land.properties
        soilW ⇐ land.pools
        ΔsoilW ⇐ land.pools
        (z_zero, o_one) ⇐ land.constants
        tolerance ⇐ helpers.numbers
    end

    ## calculate drainage
    for sl ∈ 1:(length(soilW)-1)
        holdCap = w_sat[sl+1] - (soilW[sl+1] + ΔsoilW[sl+1])
        max_drain = w_sat[sl] - w_fc[sl]
        lossCap = min(soilW[sl] + ΔsoilW[sl], max_drain)
        k = unsatK(land, helpers, sl, unsat_k_model)
        drain = min(k, holdCap, lossCap)
        drainage[sl] = drain > tolerance ? drain : zero(drain)
        ΔsoilW[sl] = ΔsoilW[sl] - drainage[sl]
        ΔsoilW[sl+1] = ΔsoilW[sl+1] + drainage[sl]
    end

    ## pack land variables
    # @pack_nt begin
    # 	drainage ⇒ land.fluxes
    # 	# ΔsoilW ⇒ land.pools
    # end
    return land
end

purpose(::Type{drainage_kUnsat}) = "Drainage flux based on unsaturated hydraulic conductivity."

@doc """

$(getProcessDocstring(drainage_kUnsat))

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala | @dr-ko]

*Created by*
 - skoirala | @dr-ko
"""
drainage_kUnsat
