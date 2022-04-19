export drainage_dos

@bounds @describe @units @with_kw struct drainage_dos{T1} <: drainage
	dos_exp::T1 = 1.0 | (0.1, 3.0) | "exponent of non-linearity for dos influence on drainage in soil" | ""
end

function compute(o::drainage_dos, forcing, land, infotem)
	## unpack parameters
	@unpack_drainage_dos o

	## unpack land variables
	@unpack_land begin
		(p_wSat, p_β) ∈ land.soilWBase
		soilW ∈ land.pools
	end

	# get the number of soil layers
	# @show soilW
	drainage = ((soilW ./ p_wSat) .^ (dos_exp .* p_β)) .* soilW
	drainage[end] = infotem.helpers.zero

	#
	#
	# for sl = 1:infotem.pools.water.nZix.soilW-1
	# # get the drainage flux
	# dosSoil = soilW[sl] / p_wSat[sl]
	#
	# drain = ((dosSoil) ^ (dos_exp * p_β[sl])) * soilW[sl]
	#
	# # k_unsat = feval(kUnsatFuncH, s, p, info, sl)
	# # drain = min(k_unsat, soilW[sl])
	# # store the drainage flux
	# soilWFlow[sl+1] = drain
	# drain = min(drain, p_wSat[sl+1] - soilW[sl+1])
	# soilW[sl] = soilW[sl] - drain
	# soilW[sl+1] = soilW[sl+1]+drain
	# end

	## pack land variables
	@pack_land begin
		drainage => land.drainage
	end
	return land
end

@doc """
computes the downward flow of moisture [drainage] in soil layers based on unsaturated hydraulic conductivity

# Parameters
$(PARAMFIELDS)

---

# compute:
Recharge the soil using drainage_dos

*Inputs*
 - land.pools.soilW: soil moisture in different layers
 - land.soilProperties.kUnsatFuncH: function handle to calculate unsaturated hydraulic conduct.

*Outputs*
 - drainage from the last layer is saved as groundwater recharge [gwRec]
 - land.states.soilWFlow: drainage flux between soil layers (same as nZix, from percolation  into layer 1 & the drainage to the last layer)

# update

update pools and states in drainage_dos

 - land.pools.soilW

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 18.11.2019 [skoirala]:  

*Created by:*
 - skoirala
"""
drainage_dos