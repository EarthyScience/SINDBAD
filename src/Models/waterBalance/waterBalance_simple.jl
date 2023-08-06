export waterBalance_simple

struct waterBalance_simple <: waterBalance end

function cry_and_die(forcing, land, msg, water_balance, total_water, total_water_prev, WBP, precip, runoff, evapotranspiration)
    msg = "water balance error: $msg :: water_balance: $(water_balance), total_water: $(total_water), total_water_prev: $(total_water_prev), WBP: $(WBP), precip: $(precip), runoff: $(runoff), evapotranspiration: $(evapotranspiration)"
    tcPrint(land)
    tcPrint(forcing)
    pprint(msg)
    if hasproperty(Sindbad, :error_catcher)
        push!(Sindbad.error_catcher, land)
        push!(Sindbad.error_catcher, msg)
    end
    pprint(land)
    error(msg)
end

function check_water_balance_error(_, _, _, _, _, _, _, _, _, ::Val{:true}, ::Val{:true}) # when catch_model_errors is true and run_optimization is true -> never check for errors during optimization
    return nothing
end

function check_water_balance_error(_, _, _, _, _, _, _, _, _, ::Val{:false}, ::Val{:true}) # when catch_model_errors is true and run_optimization is false -> never check for errors when catch_model_errors is false
    return nothing
end

function check_water_balance_error(_, _, _, _, _, _, _, _, _, ::Val{:false}, ::Val{:false}) # when catch_model_errors is true and run_optimization is false -> never check for errors when catch_model_errors is false
    return nothing
end


function check_water_balance_error(forcing, land, water_balance, total_water, total_water_prev, WBP, precip, runoff, evapotranspiration, ::Val{:true}, ::Val{:false}) # when catch_model_errors is true and run_optimization is false
    if isnan(water_balance)
        cry_and_die(forcing, land, "water balance is nan", water_balance, total_water, total_water_prev, WBP, precip, runoff, evapotranspiration)
    end
    if abs(water_balance) > tolerance
        cry_and_die(forcing, land, "water balance is larger than tolerance", water_balance, total_water, total_water_prev, WBP, precip, runoff, evapotranspiration)
    end
    return nothing
end

function compute(p_struct::waterBalance_simple, forcing, land, helpers)
    @unpack_land begin
        precip ∈ land.fluxes
        (total_water_prev, total_water, WBP) ∈ land.states
        (evapotranspiration, runoff) ∈ land.fluxes
        tolerance ∈ helpers.numbers
    end

    ## calculate variables
    dS = total_water - total_water_prev
    water_balance = precip - runoff - evapotranspiration - dS

    check_water_balance_error(forcing, land, water_balance, total_water, total_water_prev, WBP, precip, runoff, evapotranspiration, helpers.run.catch_model_errors, helpers.run.run_optimization)

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
