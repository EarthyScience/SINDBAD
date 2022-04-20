export cAllocationSoilW_Friedlingstein1999

@bounds @describe @units @with_kw struct cAllocationSoilW_Friedlingstein1999{T1, T2} <: cAllocationSoilW
	mifW::T1 = 0.5 | (0.0, 1.0) | "" | ""
	maxL_fW::T2 = 0.5 | (0.0, 1.0) | "" | ""
end

function compute(o::cAllocationSoilW_Friedlingstein1999, forcing, land, helpers)
	## unpack parameters
	@unpack_cAllocationSoilW_Friedlingstein1999 o

	## unpack land variables
	@unpack_land fW ∈ land.cTauSoilW


	## calculate variables
	# computation for the moisture effect on decomposition/mineralization
	fW[fW >= maxL_fW] = maxL_fW
	fW[fW <= mifW] = mifW
	# fW[fW >= maxL_fW] = maxL_fW(fW >=
	# maxL_fW); #sujan
	# fW[fW <= mifW] = mifW[fW <= mifW]; #sujan

	## pack land variables
	@pack_land fW => land.cAllocationSoilW
	return land
end

@doc """
Compute partial computation for the moisture effect on decomposition/mineralization

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of soil moisture on carbon allocation using cAllocationSoilW_Friedlingstein1999

*Inputs*
 - land.cTauSoilW.fW: values for effect of moisture on soil decomposition

*Outputs*
 - land.cAllocationSoilW.fW: values for moisture stressor on C allocation
 - land.cAllocationSoilW.fW

---

# Extended help

*References*
 - Friedlingstein; P.; G. Joel; C.B. Field; & I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cAllocationSoilW_Friedlingstein1999