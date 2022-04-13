export cTauSoilT_none, cTauSoilT_none_h
"""
set the outputs to ones

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cTauSoilT_none{T} <: cTauSoilT
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::cTauSoilT_none, forcing, land, infotem)
	@unpack_cTauSoilT_none o

	## calculate variables
	fT = 1.0

	## pack variables
	@pack_land begin
		fT ∋ land.cTauSoilT
	end
	return land
end

function compute(o::cTauSoilT_none, forcing, land, infotem)
	# @unpack_cTauSoilT_none o
	return land
end

function update(o::cTauSoilT_none, forcing, land, infotem)
	# @unpack_cTauSoilT_none o
	return land
end

"""
set the outputs to ones

# Extended help
"""
function cTauSoilT_none_h end