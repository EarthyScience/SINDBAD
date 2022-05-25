export wCycle_combined

struct wCycle_combined <: wCycle
end

function compute(o::wCycle_combined, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack variables
	@unpack_land begin
		TWS ∈ land.pools
		ΔTWS  ∈ land.states
		p_wSat ∈ land.soilWBase
		(𝟘, tolerance) ∈ helpers.numbers
	end
	TWS_old = deepcopy(TWS)
	## update variables
	TWS .= TWS .+ ΔTWS

    # reset soil moisture changes to zero
	if minimum(TWS) < 𝟘
		if abs(minimum(TWS)) < tolerance
		    @warn "Numerically small negative TWS $(TWS) were replaced with tolerance $(tolerance)"
			# @show TWS, TWS_old, ΔTWS
			pprint(land)
			# @show land.rootFraction.p_fracRoot2SoilD, land.fluxes, land.percolation, land.drainage, land.capillaryFlow, land.states.WBP
			# pprint(land)
		    TWS .= max.(TWS, 𝟘)
		else
		    @error "TWS is negative. Cannot continue. $(TWS)"
		end
	end
	ΔTWS .= zero(ΔTWS)

	## pack land variables
	# @pack_land begin
	# 	(groundW, snowW, soilW, surfaceW) => land.pools
	# 	(ΔgroundW, ΔsnowW, ΔsoilW, ΔsurfaceW)  => land.states
	# end
	return land
end

@doc """
computes the algebraic sum of storage and delta storage


---

# compute:
- apply the delta storage changes
- check if there is overflow or over extraction

*Inputs*
- land.pools.storages: water storages
- land.states.Δstorages: water storage changes
- land.soilWBase.p_wSat: water holding capacity

*Outputs*
 - land.states.Δstorages: soil percolation

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
wCycle_combined