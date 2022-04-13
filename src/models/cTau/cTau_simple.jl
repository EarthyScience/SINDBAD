export cTau_simple, cTau_simple_h
"""
combine all the effects that change the turnover rates [k]. combine all the effects that change the turnover rates [k]

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cTau_simple{T} <: cTau
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cTau_simple, forcing, land, infotem)
	@unpack_cTau_simple o

	## instantiate variables
	p_k = ones(size(infotem.pools.carbon.initValues.cEco))

	## pack variables
	@pack_land begin
		p_k ∋ land.cTau
	end
	return land
end

function compute(o::cTau_simple, forcing, land, infotem)
	@unpack_cTau_simple o

	## unpack variables
	@unpack_land begin
		p_k ∈ land.cTau
		p_kfVeg ∈ land.cTauVegProperties
		p_fsoilW ∈ land.cTauSoilW
		fT ∈ land.cTauSoilT
		p_kfSoil ∈ land.cTauSoilProperties
		p_kfLAI ∈ land.cTauLAI
		p_k ∈ land.cCycleBase
	end
	p_k = p_k * p_kfLAI * p_kfSoil * p_kfVeg * fT * p_fsoilW
	p_k = min(max(p_k, 0), 1)

	## pack variables
	@pack_land begin
		p_k ∋ land.cTau
	end
	return land
end

function update(o::cTau_simple, forcing, land, infotem)
	# @unpack_cTau_simple o
	return land
end

"""
combine all the effects that change the turnover rates [k]. combine all the effects that change the turnover rates [k]

# precompute:
precompute/instantiate time-invariant variables for cTau_simple

# compute:
Combine effects of different factors on decomposition rates using cTau_simple

*Inputs:*
 - land.cCycleBase.p_k:
 - land.cTauLAI.p_kfLAI: LAI stressor values on the the turnover rates
 - land.cTauSoilProperties.p_kfSoil: Soil texture stressor values on the the turnover rates
 - land.cTauSoilT.fT: Air temperature stressor values on the the turnover rates
 - land.cTauSoilW.fsoilW: Soil moisture stressor values on the the turnover rates
 - land.cTauVegProperties.p_kfVeg: Vegetation type stressor values on the the turnover rates

*Outputs:*
 - land.cTau.p_k: values for actual turnover rates

# update
update pools and states in cTau_simple
 - land.cTau.p_k

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais

Notes:  we are multiplying [nPix, nZix]x[nPix, 1] should be OK!
"""
function cTau_simple_h end