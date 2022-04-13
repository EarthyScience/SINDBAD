export cAllocationSoilW_Friedlingstein1999, cAllocationSoilW_Friedlingstein1999_h
"""
Compute partial computation for the moisture effect on decomposition/mineralization

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cAllocationSoilW_Friedlingstein1999{T1, T2} <: cAllocationSoilW
	mifW::T1 = 0.5 | (0.0, 1.0) | "" | ""
	maxL_fW::T2 = 0.5 | (0.0, 1.0) | "" | ""
end

function precompute(o::cAllocationSoilW_Friedlingstein1999, forcing, land, infotem)
	# @unpack_cAllocationSoilW_Friedlingstein1999 o
	return land
end

function compute(o::cAllocationSoilW_Friedlingstein1999, forcing, land, infotem)
	@unpack_cAllocationSoilW_Friedlingstein1999 o

	## unpack variables
	@unpack_land begin
		fW ∈ land.cTauSoilW
	end
	# computation for the moisture effect on decomposition/mineralization
	fW[fW >= maxL_fW] = maxL_fW
	fW[fW <= mifW] = mifW
	# fW[fW >= maxL_fW] = maxL_fW(fW >=
	# maxL_fW); #sujan
	# fW[fW <= mifW] = mifW[fW <= mifW]; #sujan

	## pack variables
	@pack_land begin
		fW ∋ land.cAllocationSoilW
	end
	return land
end

function update(o::cAllocationSoilW_Friedlingstein1999, forcing, land, infotem)
	# @unpack_cAllocationSoilW_Friedlingstein1999 o
	return land
end

"""
Compute partial computation for the moisture effect on decomposition/mineralization

# precompute:
precompute/instantiate time-invariant variables for cAllocationSoilW_Friedlingstein1999

# compute:
Effect of soil moisture on carbon allocation using cAllocationSoilW_Friedlingstein1999

*Inputs:*
 - land.cTauSoilW.fW: values for effect of moisture on soil decomposition

*Outputs:*
 - land.cAllocationSoilW.fW: values for moisture stressor on C allocation

# update
update pools and states in cAllocationSoilW_Friedlingstein1999
 - land.cAllocationSoilW.fW

# Extended help

*References:*
 - Friedlingstein; P.; G. Joel; C.B. Field; & I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.

*Versions:*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
function cAllocationSoilW_Friedlingstein1999_h end