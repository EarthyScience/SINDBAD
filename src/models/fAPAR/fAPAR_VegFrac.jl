export fAPAR_VegFrac, fAPAR_VegFrac_h
"""
# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct fAPAR_VegFrac{T} <: fAPAR
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::fAPAR_VegFrac, forcing, land, infotem)
	# @unpack_fAPAR_VegFrac o
	return land
end

function compute(o::fAPAR_VegFrac, forcing, land, infotem)
	@unpack_fAPAR_VegFrac o

	## unpack variables

	## calculate variables

	## pack variables
	return land
end

function update(o::fAPAR_VegFrac, forcing, land, infotem)
	# @unpack_fAPAR_VegFrac o
	return land
end

"""
# Extended help
"""
function fAPAR_VegFrac_h end