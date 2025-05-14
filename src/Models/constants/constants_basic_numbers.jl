export constants_basic_numbers


struct constants_basic_numbers <: constants end

function define(params::constants_basic_numbers, forcing, land, helpers)
	return land
end

function precompute(params::constants_basic_numbers, forcing, land, helpers)
	return land
end

function compute(params::constants_basic_numbers, forcing, land, helpers)
	## Automatically generated sample code for basis. Modify, correct, and use. define, precompute, and update methods can use similar coding when needed. When not, they can simply be deleted. 
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

function update(params::constants_basic_numbers, forcing, land, helpers)
	return land
end

purpose(::Type{constants_basic_numbers}) = "constants of numbers such as 1 to 10"

@doc """ 

	$(getModelDocString(constants_basic_numbers))

---

# Extended help

*References*

*Versions*
 - 1.0 on 14.05.2025 [skoirala]

*Created by*
 - skoirala

"""
constants_basic_numbers

