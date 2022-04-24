export cAllocationSoilT_gppGSI

@bounds @describe @units @with_kw struct cAllocationSoilT_gppGSI{T1} <: cAllocationSoilT
	τ_Tsoil::T1 = 0.2 | (0.001, 1.0) | "temporal change rate for the temperature-limiting function" | ""
end

function compute(o::cAllocationSoilT_gppGSI, forcing, land, helpers)
	## unpack parameters
	@unpack_cAllocationSoilT_gppGSI o

	## unpack land variables
	@unpack_land begin
		TempScGPP ∈ land.gppAirT
		fT_prev ∈ land.cAllocationSoilT
	end
	# computation for the temperature effect on decomposition/mineralization
	pfT = fT_prev
	fT = pfT + (TempScGPP - pfT) * τ_Tsoil

	## pack land variables
	@pack_land fT => land.cAllocationSoilT
	return land
end

@doc """
compute the temperature effect on C allocation based on GSI approach.

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of soil temperature on carbon allocation using cAllocationSoilT_gppGSI

*Inputs*
 - land.cAllocationSoilT.fT_prev: previous temperature stressor value
 - land.gppAirT.TempScGPP: temperature stressors on GPP
 - τ: temporal change rate for the light-limiting function

*Outputs*
 - land.cAllocationSoilT.fT: values for the temperature effect on decomposition/mineralization

---

# Extended help

*References*
 - Forkel M, Carvalhais N, Schaphoff S, von Bloh W, Migliavacca M, Thurner M, Thonicke K [2014] Identifying environmental controls on vegetation greenness phenology through model–data integration. Biogeosciences, 11, 7025–7050.
 - Forkel, M., Migliavacca, M., Thonicke, K., Reichstein, M., Schaphoff, S., Weber, U., Carvalhais, N. (2015).  Codominant water control on global interannual variability and trends in land surface phenology & greenness.
 - Jolly, William M., Ramakrishna Nemani, & Steven W. Running. "A generalized, bioclimatic index to predict foliar phenology in response to climate." Global Change Biology 11.4 [2005]: 619-632.

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais & sbesnard
"""
cAllocationSoilT_gppGSI