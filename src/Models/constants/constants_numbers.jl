export constants_numbers


struct constants_numbers <: constants end

function define(params::constants_numbers, forcing, land, helpers)

	z_zero = oftype(helpers.numbers.tolerance, 0.0)
	o_one = oftype(helpers.numbers.tolerance, 1.0)
	t_two = oftype(helpers.numbers.tolerance, 2.0)
	t_three = oftype(helpers.numbers.tolerance, 3.0)

	@pack_nt (z_zero, o_one, t_two, t_three) ⇒ land.constants

	return land
end

purpose(::Type{constants_numbers}) = "constants of numbers such as 1 to 10"

@doc """ 

	$(getModelDocString(constants_numbers))

---

# Extended help

*References*

*Versions*
 - 1.0 on 14.05.2025 [skoirala]

*Created by*
 - skoirala

"""
constants_numbers

