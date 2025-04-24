export plantForm_fixed

#! format: off
@bounds @describe @units @timescale @with_kw struct plantForm_fixed{T1} <: plantForm
	P1::T1 = Inf | (-Inf, Inf) | "parameter 1" | "parameter 1 unit" | "parameter 1 timescale"
end
#! format: on

function define(params::plantForm_fixed, forcing, land, helpers)
	return land
end

function precompute(params::plantForm_fixed, forcing, land, helpers)
	return land
end

function compute(params::plantForm_fixed, forcing, land, helpers)
	## Automatically generated sample code for basis. Modify, correct, and use. define, precompute, and update methods can use similar coding when needed. When not, they can simply be deleted. 
	@unpack_plantForm_fixed params # unpack the model parameters
	## unpack NT forcing
	# @unpack_nt f_variable ⇐ forcing

	## unpack NT land
	# @unpack_nt begin
		# flux_variable ⇐ land.fluxes
		# state_variable ⇐ land.states
	# end

	## Do calculations

	## pack land variables
	# @pack_nt new_diagnostic_variable ⇒ land.diagnostics

	return land
end

function update(params::plantForm_fixed, forcing, land, helpers)
	return land
end

purpose(::Type{plantForm_fixed}) = "use a fixed plant form with 1: tree, 2: shrub, 3:herb"

@doc """ 

	$(getBaseDocString(plantForm_fixed))

---

# Extended help

*References*

*Versions*
 - 1.0 on 24.04.2025 [skoirala]

*Created by*
 - skoirala

"""
plantForm_fixed

