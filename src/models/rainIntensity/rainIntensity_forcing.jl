export rainIntensity_forcing

struct rainIntensity_forcing <: rainIntensity
end

function compute(o::rainIntensity_forcing, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack forcing
	@unpack_forcing rainInt ∈ forcing

	## pack land variables
	@pack_land rainInt => land.rainIntensity
	return land
end

@doc """
stores the time series of rainfall & snowfall from forcing

---

# compute:
Set rainfall intensity using rainIntensity_forcing

*Inputs*
 - land.rainIntensity.rainInt

*Outputs*
 - land.rainIntensity.rainInt: liquid rainfall from forcing input  threshold
 - forcing.Snow using the snowfall scaling parameter which can be optimized

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: creation of approach  

*Created by:*
 - skoirala
"""
rainIntensity_forcing