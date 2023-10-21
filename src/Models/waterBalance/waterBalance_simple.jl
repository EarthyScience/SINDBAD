export waterBalance_simple

struct waterBalance_simple <: waterBalance end


"""
    isInvalid(num)

check if a data is an invalid number
"""
function isInvalid(_data)
    return isnothing(_data) || ismissing(_data) || isnan(_data) || isinf(_data)
end


function throwError(forcing, land, msg, water_balance, total_water, total_water_prev, WBP, precip, runoff, evapotranspiration)
    msg = "water balance error: $msg :: water_balance: $(water_balance), total_water: $(total_water), total_water_prev: $(total_water_prev), WBP: $(WBP), precip: $(precip), runoff: $(runoff), evapotranspiration: $(evapotranspiration)"
    @show land
    @show forcing
    println(msg)
    if hasproperty(Sindbad, :error_catcher)
        push!(Sindbad.error_catcher, land)
        push!(Sindbad.error_catcher, msg)
    end
    error(msg)
end
function checkWaterBalanceError(_, _, _, _, _, _, _, _, _, _, ::DoNotCatchModelErrors) # when catch_model_errors is false
    return nothing
end


function checkWaterBalanceError(forcing, land, water_balance, tolerance, total_water, total_water_prev, WBP, precip, runoff, evapotranspiration, ::DoCatchModelErrors) # when catch_model_errors is true
    if isInvalid(water_balance)
        throwError(forcing, land, "water balance is invalid", water_balance, total_water, total_water_prev, WBP, precip, runoff, evapotranspiration)
    end
    if abs(water_balance) > tolerance
        throwError(forcing, land, "water balance is larger than tolerance: $tolerance", water_balance, total_water, total_water_prev, WBP, precip, runoff, evapotranspiration)
    end
    return nothing
end

function compute(params::waterBalance_simple, forcing, land, helpers)
    @unpack_land begin
        precip ∈ land.fluxes
        (total_water_prev, total_water, WBP) ∈ land.states
        (evapotranspiration, runoff) ∈ land.fluxes
        tolerance ∈ helpers.numbers
    end

    ## calculate variables
    dS = total_water - total_water_prev
    water_balance = precip - runoff - evapotranspiration - dS

    checkWaterBalanceError(forcing, land, water_balance, tolerance, total_water, total_water_prev, WBP, precip, runoff, evapotranspiration, helpers.run.catch_model_errors)

    ## pack land variables
    @pack_land water_balance → land.diagnostics
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
 - land.diagnostics.water_balance

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
