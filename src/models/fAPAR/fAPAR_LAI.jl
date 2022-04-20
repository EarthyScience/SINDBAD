export fAPAR_LAI

@bounds @describe @units @with_kw struct fAPAR_LAI{T1} <: fAPAR
	kEffExt::T1 = 0.5 | (0.00001, 0.99) | "effective light extinction coefficient" | ""
end


function compute(o::fAPAR_LAI, forcing, land, helpers)
	@unpack_fAPAR_LAI o

	## unpack land variables
	@unpack_land begin
		LAI ∈ land.states
		one ∈ helpers.numbers
	end
	## calculate variables
	fAPAR = one - exp(-(LAI * kEffExt))

	## pack land variables
	@pack_land fAPAR => land.states
	return land
end

@doc """
sets the value of fAPAR as a function of LAI

# Parameters
$(PARAMFIELDS)

---

# compute:
Fraction of absorbed photosynthetically active radiation from LAI

*Inputs*
 - kEffExt: light extinction coefficient
 - land.states.LAI: needs the LAI module to be activated

*Outputs*
 - land.states.fAPAR: fAPAR as a function of LAI

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 24.02.2021 [skoirala]  

*Created by:*
 - skoirala
"""
fAPAR_LAI