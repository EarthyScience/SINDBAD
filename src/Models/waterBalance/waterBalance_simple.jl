export waterBalance_simple

struct waterBalance_simple <: waterBalance end


function compute(o::waterBalance_simple, forcing, land, helpers)
    @unpack_land begin
        precip ∈ land.rainSnow
        (totalW_prev, totalW) ∈ land.states
        (evapotranspiration, runoff) ∈ land.fluxes
        tolerance ∈ helpers.numbers
    end

    ## calculate variables
    dS = totalW - totalW_prev
    waterBalance = precip - runoff - evapotranspiration - dS
    if abs(waterBalance) > tolerance
        if helpers.run.catchErrors && !helpers.run.runOpti
            msg = "water balance error:, waterBalance: $(waterBalance), totalW: $(totalW), totalW_prev: $(totalW_prev), WBP: $(land.states.WBP), precip: $(precip), runoff: $(runoff), evapotranspiration: $(evapotranspiration)"
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
    end

    ## pack land variables
    @pack_land begin
        (waterBalance) => land.waterBalance
    end
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
 - land.waterBalance.waterBalance

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
