export cAllocationRadiation_GSI, cAllocationRadiation_GSI_h
"""
computation for the radiation effect on decomposition/mineralization using a GSI method

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cAllocationRadiation_GSI{T1, T2, T3} <: cAllocationRadiation
	τ_Rad::T1 = 0.02 | (0.001, 1.0) | "temporal change rate for the light-limiting function" | ""
	slope_Rad::T2 = 1.0 | (0.01, 200.0) | "slope parameters of a logistic function based on mean daily y shortwave downward radiation" | ""
	base_Rad::T3 = 10.0 | (0.0, 100.0) | "inflection point parameters of a logistic function based on mean daily y shortwave downward radiation" | ""
end

function precompute(o::cAllocationRadiation_GSI, forcing, land, infotem)
	# @unpack_cAllocationRadiation_GSI o
	return land
end

function compute(o::cAllocationRadiation_GSI, forcing, land, infotem)
	@unpack_cAllocationRadiation_GSI o

	## unpack variables
	@unpack_land begin
		PAR ∈ forcing
		fR_prev ∈ land.cAllocationRadiation
	end
	# computation for the radiation effect on decomposition/mineralization
	pfR = fR_prev
	fR = (1 / (1 + exp(-slope_Rad * (PAR - base_Rad))))
	fR = pfR + (fR - pfR) * τ_Rad

	## pack variables
	@pack_land begin
		fR ∋ land.cAllocationRadiation
	end
	return land
end

function update(o::cAllocationRadiation_GSI, forcing, land, infotem)
	# @unpack_cAllocationRadiation_GSI o
	return land
end

"""
computation for the radiation effect on decomposition/mineralization using a GSI method

# precompute:
precompute/instantiate time-invariant variables for cAllocationRadiation_GSI

# compute:
Effect of radiation on carbon allocation using cAllocationRadiation_GSI

*Inputs:*
 - base:
 - forcing.PAR: values for PAR
 - land.cAllocationRadiation.fR_prev: previous values for the radiation effect on decomposition/mineralization
 - slope:
 - τ:

*Outputs:*
 - land.cAllocationRadiation.fR: values for the radiation effect on decomposition/mineralization

# update
update pools and states in cAllocationRadiation_GSI
 - land.cAllocationRadiation.fR

# Extended help

*References:*
 - Forkel M, Carvalhais N, Schaphoff S, von Bloh W, Migliavacca M, Thurner M, Thonicke K [2014] Identifying environmental controls on vegetation greenness phenology through model–data integration. Biogeosciences, 11, 7025–7050.
 - Forkel, M., Migliavacca, M., Thonicke, K., Reichstein, M., Schaphoff, S., Weber, U., Carvalhais, N. (2015).  Codominant water control on global interannual variability and trends in land surface phenology & greenness.
 - Jolly, William M., Ramakrishna Nemani, & Steven W. Running. "A generalized, bioclimatic index to predict foliar phenology in response to climate." Global Change Biology 11.4 [2005]: 619-632.

*Versions:*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais & sbesnard
"""
function cAllocationRadiation_GSI_h end