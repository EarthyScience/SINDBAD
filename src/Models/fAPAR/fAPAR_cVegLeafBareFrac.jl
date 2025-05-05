export fAPAR_cVegLeafBareFrac

#! format: off
@bounds @describe @units @timescale @with_kw struct fAPAR_cVegLeafBareFrac{T1} <: fAPAR
    k_extinction::T1 = 0.005 | (0.0005, 0.05) | "effective light extinction coefficient" | "" | ""
end
#! format: on

function compute(params::fAPAR_cVegLeafBareFrac, forcing, land, helpers)
    ## unpack parameters
    @unpack_fAPAR_cVegLeaf params

    ## unpack land variables
    @unpack_nt begin
        cVegLeaf ⇐ land.pools
        frac_vegetation ⇐ land.states
    end
    ## calculate variables
    cVegLeaf_sum = totalS(cVegLeaf)
    fAPAR = one(k_extinction) - exp(-(cVegLeaf_sum * k_extinction))
    fAPAR_bare = fAPAR * frac_vegetation # ?  frac_vegetation -> (1 - frac_B_soil) 
    # Cross check frac_vegetation from NetCDF files! 
    # TODO:  tree_frac (1km), Ranits's, mix, use table is available if not keep it!
    # 
    # ? make sure that frac_vegetation is consistent with Ranit's table!
    ## pack land variables
    @pack_nt begin
        (fAPAR_bare, fAPAR) ⇒ land.states # TODO: now use fAPAR_bare as the output for the cost function!
    end
    return land
end

purpose(::Type{fAPAR_cVegLeafBareFrac}) = "Compute FAPAR based on carbon pool of the leaf, but only for the vegetation fraction"

@doc """

$(getBaseDocString(fAPAR_cVegLeafBareFrac))

---

# Extended help

*References*

*Versions*
 - 1.0 on 24.04.2021 [skoirala | @dr-ko]

*Created by:*
 - Nuno & skoirala
"""
fAPAR_cVegLeafBareFrac
