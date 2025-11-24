export sublimation

abstract type sublimation <: LandEcosystem end

purpose(::Type{sublimation}) = "Snow sublimation."

includeApproaches(sublimation, @__DIR__)

@doc """ 
	$(getProcessDocstring(sublimation))
"""
sublimation

# define a common interface for updating for all sublimation models
function update(params::sublimation, forcing, land, helpers)
    ## unpack variables
    @unpack_nt begin
        snowW ⇐ land.pools
        ΔsnowW ⇐ land.pools
    end
	@add_to_elem ΔsnowW[1] ⇒ (snowW, 1, :snowW)
    # update snow pack
	@add_to_elem -ΔsnowW[1] ⇒ (ΔsnowW, 1, :snowW)
    ## pack land variables
    @pack_nt begin
        snowW ⇒ land.pools
        ΔsnowW ⇒ land.pools
    end
    return land
end