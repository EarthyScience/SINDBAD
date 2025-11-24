export plantForm_fixed

#! format: off
@bounds @describe @units @timescale @with_kw struct plantForm_fixed{T1} <: plantForm
	plant_form_type::T1 = 1 | (1, 2) | "plant form type" | "categorical" | ""
end
#! format: on

function precompute(params::plantForm_fixed, forcing, land, helpers)
	@unpack_plantForm_fixed params # unpack the model parameters

	plant_form = params.plant_form_type

	@pack_nt plant_form ⇒ land.states

	return land
end

purpose(::Type{plantForm_fixed}) = "Sets plant form to a fixed form with 1: tree, 2: shrub, 3:herb. Assumes tree as default."

@doc """ 

	$(getProcessDocstring(plantForm_fixed))

---

# Extended help

*References*

*Versions*
 - 1.0 on 24.04.2025 [skoirala]

*Created by*
 - skoirala

"""
plantForm_fixed

