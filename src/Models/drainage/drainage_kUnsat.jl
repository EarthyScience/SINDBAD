export drainage_kUnsat

struct drainage_kUnsat <: drainage end

function define(params::drainage_kUnsat, forcing, land, helpers)
    ## instantiate drainage
    drainage = zero(land.pools.soilW)
    ## pack land variables
    @pack_land drainage => land.fluxes
    return land
end

function compute(params::drainage_kUnsat, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        drainage ∈ land.fluxes
        unsat_k_model ∈ land.soilProperties
        (wSat, wFC, soil_β, soil_kFC, kSat) ∈ land.soilWBase
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
        (z_zero, o_one) ∈ land.wCycleBase
        tolerance ∈ helpers.numbers
    end

    ## calculate drainage
    for sl ∈ 1:(length(land.pools.soilW)-1)
        holdCap = wSat[sl+1] - (soilW[sl+1] + ΔsoilW[sl+1])
        max_drain = wSat[sl] - wFC[sl]
        lossCap = min(soilW[sl] + ΔsoilW[sl], max_drain)
        k = unsatK(land, helpers, sl, unsat_k_model)
        drain = min(k, holdCap, lossCap)
        drainage[sl] = drain > tolerance ? drain : zero(drain)
        ΔsoilW[sl] = ΔsoilW[sl] - drainage[sl]
        ΔsoilW[sl+1] = ΔsoilW[sl+1] + drainage[sl]
    end

    ## pack land variables
    # @pack_land begin
    # 	drainage => land.fluxes
    # 	# ΔsoilW => land.states
    # end
    return land
end

function update(params::drainage_kUnsat, forcing, land, helpers)

    ## unpack variables
    @unpack_land begin
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
    end

    ## update variables
    # update soil moisture
    soilW .= soilW .+ ΔsoilW

    # reset soil moisture changes to zero
    ΔsoilW .= ΔsoilW .- ΔsoilW

    ## pack land variables
    @pack_land begin
        soilW => land.pools
        # ΔsoilW => land.states
    end
    return land
end

@doc """
downward flow of moisture [drainage] in soil layers based on unsaturated hydraulic conductivity

---

# compute:
Recharge the soil using drainage_kUnsat

*Inputs*
 - land.pools.soilW: soil moisture in different layers
 - land.soilProperties.unsatK: function to calculate unsaturated hydraulic conductivity.

*Outputs*
- land.fluxes.drainage
- drainage from the last layer is calculated in groundWrecharge


# update

update pools and states in drainage_kUnsat

 - land.pools.soilW

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
drainage_kUnsat
