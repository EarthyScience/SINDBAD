export groundWRecharge_kUnsat, groundWRecharge_kUnsat_h
"""
calculates GW recharge as the unsaturated hydraulic conductivity of lowermost soil layer

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct groundWRecharge_kUnsat{T} <: groundWRecharge
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::groundWRecharge_kUnsat, forcing, land, infotem)
	# @unpack_groundWRecharge_kUnsat o
	return land
end

function compute(o::groundWRecharge_kUnsat, forcing, land, infotem)
	@unpack_groundWRecharge_kUnsat o

	## unpack variables
	@unpack_land begin
		p_wSat ∈ land.soilWBase
		kUnsatFuncH ∈ land.soilProperties
		(groundW, soilW) ∈ land.pools
	end
	# index of the last soil layer
	soilWend = infotem.pools.water.nZix.soilW
	soilWExc = max(soilW[soilWend] - p_wSat[soilWend], 0.0)
	#--> get the drainage
	# kSat = p_kSat[soilWend]
	# β = p_β[soilWend]
	# soilDOS = soilW[soilWend] / p_wSat[soilWend]
	k_unsat = feval(kUnsatFuncH, s, p, info, soilWend)
	drain = min(k_unsat, soilW[soilWend])
	gwRec = drain
	gwRec = gwRec + soilWExc

	## pack variables
	@pack_land begin
		gwRec ∋ land.fluxes
	end
	return land
end

function update(o::groundWRecharge_kUnsat, forcing, land, infotem)
	@unpack_groundWRecharge_kUnsat o

	## unpack variables
	@unpack_land begin
		groundW ∈ land.pools
		gwRec ∈ land.fluxes
	end

	## update variables
	soilW[soilWend] = soilW[soilWend]-soilWExc
	# update storages
	soilW[soilWend] = soilW[soilWend]-gwRec
	groundW[1] = groundW[1] + gwRec

	## pack variables
	@pack_land begin
		(groundW, soilW) ∋ land.pools
	end
	return land
end

"""
calculates GW recharge as the unsaturated hydraulic conductivity of lowermost soil layer

# precompute:
precompute/instantiate time-invariant variables for groundWRecharge_kUnsat

# compute:
Recharge the groundwater using groundWRecharge_kUnsat

*Inputs:*
 - land.pools.soilW: soil moisture
 - land.soilProperties.kUnsatFuncH: function handle to calculate unsaturated hydraulic conduct.
 - land.soilWBase.p_wSat: moisture at saturation

*Outputs:*
 - land.fluxes.gwRec

# update
update pools and states in groundWRecharge_kUnsat
 - land.pools.groundW[1]
 - land.pools.soilW

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]: clean up  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function groundWRecharge_kUnsat_h end