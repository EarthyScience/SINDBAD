export cAllocationSoilT_Friedlingstein1999

@bounds @describe @units @with_kw struct cAllocationSoilT_Friedlingstein1999{T1, T2} <: cAllocationSoilT
	mifT::T1 = 0.5 | (0.0, 1.0) | "" | ""
	maxL_fT::T2 = 1.0 | (0.0, 1.0) | "" | ""
end

function compute(o::cAllocationSoilT_Friedlingstein1999, forcing, land, infotem)
	## unpack parameters
	@unpack_cAllocationSoilT_Friedlingstein1999 o

	## unpack land variables
	@unpack_land fT ∈ land.cTauSoilT


	## calculate variables
	# Compute partial computation for the temperature effect on
	# decomposition/mineralization
	#sujan the right hand side of equation below has p which has one value but
	#LHS is nPix;nTix
	fT[fT >= maxL_fT] = maxL_fT
	fT[fT <= mifT] = mifT
	# fT[fT >= maxL_fT] = maxL_fT[fT >= maxL_fT]
	# fT[fT <= mifT] = mifT[fT <= mifT]

	## pack land variables
	@pack_land fT => land.cAllocationSoilT
	return land
end

@doc """
Compute partial computation for the temperature effect on decomposition/mineralization

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of soil temperature on carbon allocation using cAllocationSoilT_Friedlingstein1999

*Inputs*
 - land.cTauSoilT.fT: values for effect of temperature on soil decomposition

*Outputs*
 - land.cAllocationSoilT.fT: values for temperature stressor on C allocation
 - land.cAllocationSoilT.fT

---

# Extended help

*References*
 - Friedlingstein; P.; G. Joel; C.B. Field; & I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cAllocationSoilT_Friedlingstein1999