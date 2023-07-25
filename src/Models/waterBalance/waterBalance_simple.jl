export waterBalance_simple

struct waterBalance_simple <: waterBalance end

function is_water_balance_valid(water_balance, tolerance, helpers)
    if helpers.run.catch_model_errors && !helpers.run.run_optimization
        if isnan(water_balance)
            pprint("water balance is nan")
            return false
        end
        if abs(water_balance) > tolerance
            pprint("water balance is larger than tolerance")
            return false
        end
    end
    return true
end

function compute(p_struct::waterBalance_simple, forcing, land, helpers)
    @unpack_land begin
        precip ∈ land.fluxes
        (totalW_prev, totalW) ∈ land.states
        (evapotranspiration, runoff) ∈ land.fluxes
        tolerance ∈ helpers.numbers
    end

    ## calculate variables
    dS = totalW - totalW_prev
    water_balance = precip - runoff - evapotranspiration - dS
    if !is_water_balance_valid(water_balance, tolerance, helpers)
        msg = "water balance error: water_balance: $(water_balance), totalW: $(totalW), totalW_prev: $(totalW_prev), WBP: $(land.states.WBP), precip: $(precip), runoff: $(runoff), evapotranspiration: $(evapotranspiration)"
        tcprint(land)
        tcprint(forcing)
        pprint(msg)
        if hasproperty(Sindbad, :error_catcher)
            push!(Sindbad.error_catcher, land)
            push!(Sindbad.error_catcher, msg)
        end
        pprint(land)
        error(msg)
    end

    ## pack land variables
    @pack_land water_balance => land.states
    return land
end

@doc """
check the water balance in every time step

---

# compute:
Calculate the water balance using waterBalance_simple

*Inputs*
 - variables to sum for runoff[total runoff] & evapotranspiration [total evap]
 - TWS and TWS_prev

*Outputs*
 - land.states.water_balance

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019
 - 1.1 on 20.11.2019 [skoirala]:

*Created by:*
 - skoirala
"""
waterBalance_simple
