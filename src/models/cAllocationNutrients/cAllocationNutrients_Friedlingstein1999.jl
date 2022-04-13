export cAllocationNutrients_Friedlingstein1999, cAllocationNutrients_Friedlingstein1999_h
"""
pseudo-nutrient limitation [NL] calculation: "There is no explicit estimate of soil mineral nitrogen in the version of CASA used for these simulations. As a surrogate; we assume that spatial variability in nitrogen mineralization & soil organic matter decomposition are identical [Townsend et al. 1995]. Nitrogen availability; N; is calculated as the product of the temperature & moisture abiotic factors used in CASA for the calculation of microbial respiration [Potter et al. 1993]." in Friedlingstein et al., 1999.#

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct cAllocationNutrients_Friedlingstein1999{T1, T2} <: cAllocationNutrients
	minL::T1 = 0.1 | (0.0, 1.0) | "" | ""
	maxL::T2 = 1.0 | (0.0, 1.0) | "" | ""
end

function precompute(o::cAllocationNutrients_Friedlingstein1999, forcing, land, infotem)
	@unpack_cAllocationNutrients_Friedlingstein1999 o

	## instantiate variables
	NL = minL * ones(size(PET))

	## pack variables
	@pack_land begin
		NL ∋ land.cAllocationNutrients
	end
	return land
end

function compute(o::cAllocationNutrients_Friedlingstein1999, forcing, land, infotem)
	@unpack_cAllocationNutrients_Friedlingstein1999 o

	## unpack variables
	@unpack_land begin
		NL ∈ land.cAllocationNutrients
		pawAct ∈ land.states
		p_wAWC ∈ land.soilWBase
		fW ∈ land.cAllocationSoilW
		fT ∈ land.cAllocationSoilT
		PET ∈ land.PET
	end
	# estimate NL
	ndx = PET > 0.0
	NL[ndx] = fT[ndx] * fW[ndx]
	NL[NL <= minL] = minL; #(NL <= minL)
	NL[NL >= maxL] = maxL; #(NL >= maxL)
	#sujan NL[NL <= minL] = minL[NL <= minL]
	#sujan NL[NL >= maxL] = maxL[NL >= maxL]
	# sujan consider root fractions
	# water limitation calculation
	# WL = sum(soilW * p_fracRoot2SoilD) / sum(p_wAWC * p_fracRoot2SoilD)
	WL = sum(pawAct) / sum(p_wAWC)
	# WL = sum(soilW) / sum(p_wAWC)
	WL[WL <= minL] = minL; #(WL <= minL)
	WL[WL >= maxL] = maxL; #(WL >= maxL);## check if maxL & minL should used maxL_fW?
	#sujan WL[WL <= minL] = minL[WL <= minL]
	#sujan WL[WL >= maxL] = maxL[WL >= maxL]; ## check if maxL & minL should used maxL_fW?
	# minimum of WL & NL
	minWLNL = NL
	minWLNL[WL < NL] = WL[WL < NL]

	## pack variables
	@pack_land begin
		minWLNL ∋ land.cAllocationNutrients
	end
	return land
end

function update(o::cAllocationNutrients_Friedlingstein1999, forcing, land, infotem)
	# @unpack_cAllocationNutrients_Friedlingstein1999 o
	return land
end

"""
pseudo-nutrient limitation [NL] calculation: "There is no explicit estimate of soil mineral nitrogen in the version of CASA used for these simulations. As a surrogate; we assume that spatial variability in nitrogen mineralization & soil organic matter decomposition are identical [Townsend et al. 1995]. Nitrogen availability; N; is calculated as the product of the temperature & moisture abiotic factors used in CASA for the calculation of microbial respiration [Potter et al. 1993]." in Friedlingstein et al., 1999.#

# precompute:
precompute/instantiate time-invariant variables for cAllocationNutrients_Friedlingstein1999

# compute:
(pseudo)effect of nutrients on carbon allocation using cAllocationNutrients_Friedlingstein1999

*Inputs:*
 - land.PET.PET: values for potential evapotranspiration
 - land.cAllocationSoilT.fT: values for partial computation for the temperature effect on  decomposition/mineralization
 - land.cAllocationSoilW.fW: values for partial computation for the moisture effect on  decomposition/mineralization
 - land.soilWBase.p_wAWC: values for the plant water available
 - land.states.pawAct: values for maximum fraction of water that root can uptake from soil layers as constant

*Outputs:*
 - land.cAllocationNutrients.minWLNL: the pseudo-nutrient limitation [NL] calculation

# update
update pools and states in cAllocationNutrients_Friedlingstein1999
 - land.cAllocationNutrients.minWLNL

# Extended help

*References:*
 - Friedlingstein; P.; G. Joel; C.B. Field; & I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.

*Versions:*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
function cAllocationNutrients_Friedlingstein1999_h end