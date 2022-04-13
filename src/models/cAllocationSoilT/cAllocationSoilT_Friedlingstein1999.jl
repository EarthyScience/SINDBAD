export cAllocationSoilT_Friedlingstein1999, cAllocationSoilT_Friedlingstein1999_h
"""
Compute partial computation for the temperature effect on decomposition/mineralization

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cAllocationSoilT_Friedlingstein1999{T1, T2} <: cAllocationSoilT
	mifT::T1 = 0.5 | (0.0, 1.0) | "" | ""
	maxL_fT::T2 = 1.0 | (0.0, 1.0) | "" | ""
end

function precompute(o::cAllocationSoilT_Friedlingstein1999, forcing, land, infotem)
	# @unpack_cAllocationSoilT_Friedlingstein1999 o
	return land
end

function compute(o::cAllocationSoilT_Friedlingstein1999, forcing, land, infotem)
	@unpack_cAllocationSoilT_Friedlingstein1999 o

	## unpack variables
	@unpack_land begin
		fT ∈ land.cTauSoilT
	end
	# Compute partial computation for the temperature effect on
	# decomposition/mineralization
	#sujan the right hand side of equation below has p which has one value but
	#LHS is nPix;nTix
	fT[fT >= maxL_fT] = maxL_fT
	fT[fT <= mifT] = mifT
	# fT[fT >= maxL_fT] = maxL_fT[fT >= maxL_fT]
	# fT[fT <= mifT] = mifT[fT <= mifT]

	## pack variables
	@pack_land begin
		fT ∋ land.cAllocationSoilT
	end
	return land
end

function update(o::cAllocationSoilT_Friedlingstein1999, forcing, land, infotem)
	# @unpack_cAllocationSoilT_Friedlingstein1999 o
	return land
end

"""
Compute partial computation for the temperature effect on decomposition/mineralization

# precompute:
precompute/instantiate time-invariant variables for cAllocationSoilT_Friedlingstein1999

# compute:
Effect of soil temperature on carbon allocation using cAllocationSoilT_Friedlingstein1999

*Inputs:*
 - land.cTauSoilT.fT: values for effect of temperature on soil decomposition

*Outputs:*
 - land.cAllocationSoilT.fT: values for temperature stressor on C allocation

# update
update pools and states in cAllocationSoilT_Friedlingstein1999
 - land.cAllocationSoilT.fT

# Extended help

*References:*
 - Friedlingstein; P.; G. Joel; C.B. Field; & I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.

*Versions:*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
function cAllocationSoilT_Friedlingstein1999_h end