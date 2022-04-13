export cAllocationSoilW_gppGSI, cAllocationSoilW_gppGSI_h
"""
compute the moisture effect on C allocation computed from GSI approach.

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cAllocationSoilW_gppGSI{T1} <: cAllocationSoilW
	τ_wSoil::T1 = 0.8 | (0.001, 1.0) | "temporal change rate for the water-limiting function" | ""
end

function precompute(o::cAllocationSoilW_gppGSI, forcing, land, infotem)
	# @unpack_cAllocationSoilW_gppGSI o
	return land
end

function compute(o::cAllocationSoilW_gppGSI, forcing, land, infotem)
	@unpack_cAllocationSoilW_gppGSI o

	## unpack variables
	@unpack_land begin
		SMScGPP ∈ land.gppSoilW
		fW_prev ∈ land.cAllocationSoilW
	end
	# computation for the moisture effect on decomposition/mineralization
	pfW = fW_prev
	fW = pfW + (SMScGPP - pfW) * τ_soilW

	## pack variables
	@pack_land begin
		fW ∋ land.cAllocationSoilW
	end
	return land
end

function update(o::cAllocationSoilW_gppGSI, forcing, land, infotem)
	# @unpack_cAllocationSoilW_gppGSI o
	return land
end

"""
compute the moisture effect on C allocation computed from GSI approach.

# precompute:
precompute/instantiate time-invariant variables for cAllocationSoilW_gppGSI

# compute:
Effect of soil moisture on carbon allocation using cAllocationSoilW_gppGSI

*Inputs:*
 - land.cAllocationSoilW.fW_prev: previous moisture stressor value
 - land.gppSoilW.SMScGPP: moisture stressors on GPP
 - τ: parameter for turnover times

*Outputs:*
 - land.cAllocationSoilW.fW: values for the moisture effect  on decomposition/mineralization

# update
update pools and states in cAllocationSoilW_gppGSI
 - land.cAllocationSoilW.fW

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
function cAllocationSoilW_gppGSI_h end