export wCycle_combined

struct wCycle_combined <: wCycle
end

function precompute(o::wCycle_combined, forcing, land, helpers)
	## unpack variables
	@unpack_land begin
		ΔTWS ∈ land.states
	end
	zeroΔTWS = zero(ΔTWS)

	@pack_land zeroΔTWS => land.states
	return land
end

function compute(o::wCycle_combined, forcing, land, helpers)
	## unpack variables
	@unpack_land begin
		TWS ∈ land.pools
		(ΔTWS, zeroΔTWS)  ∈ land.states
		(𝟘, tolerance) ∈ helpers.numbers
	end
	#TWS_old = deepcopy(TWS)
	## update variables
	TWS = add_vec(TWS, ΔTWS)

    # reset soil moisture changes to zero
	if minimum(TWS) < 𝟘
		if abs(minimum(TWS)) < tolerance
		    @error "Numerically small negative TWS ($(TWS)) smaller than tolerance ($(tolerance)) were replaced with absolute value of the storage"
			# @assert(false, "Numerically small negative TWS ($(TWS)) smaller than tolerance ($(tolerance)) were replaced with absolute value of the storage") 
		    TWS = abs.(TWS)
		else
		    error("TWS is negative. Cannot continue. $(TWS)")
		end
	end
	ΔTWS = zeroΔTWS
	# pack land variables
	@pack_land begin
		(TWS) => land.pools
		(ΔTWS)  => land.states
	end
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