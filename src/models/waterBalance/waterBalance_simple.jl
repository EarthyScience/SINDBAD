export waterBalance_simple

struct waterBalance_simple <: waterBalance
end

function precompute(o::waterBalance_simple, forcing, land, infotem)

	## unpack variables
	@unpack_land totalW ∈ land.TWS
	totalW_prev = totalW
	## pack land variables
	@pack_land begin
		totalW_prev => land.waterBalance
	end
	return land
end


function compute(o::waterBalance_simple, forcing, land, infotem)
	@unpack_land begin
		precip ∈ land.rainSnow
		(totalW) ∈ land.TWS
		(totalW_prev) ∈ land.waterBalance
		(evapotranspiration, runoff) ∈ land.fluxes
	end

	## calculate variables
	dS = totalW - totalW_prev
	waterBalance = precip - runoff - evapotranspiration - dS
	totalW_prev = totalW
	if abs(waterBalance) > 1e-4
		@show waterBalance, land.states.WBP, precip, runoff, evapotranspiration
	end

	## pack land variables
	@pack_land (totalW_prev, waterBalance) => land.waterBalance
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
 -

*Versions*
 - 1.0 on 11.11.2019
 - 1.1 on 20.11.2019 [skoirala]:

*Created by:*
 - skoirala
"""
waterBalance_simple