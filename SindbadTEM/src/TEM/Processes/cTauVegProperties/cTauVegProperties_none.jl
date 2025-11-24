export cTauVegProperties_none

struct cTauVegProperties_none <: cTauVegProperties end

function define(params::cTauVegProperties_none, forcing, land, helpers)

    @unpack_nt begin
        (z_zero, o_one) ⇐ land.constants
        cEco ⇐ land.pools        
    end 

    ## calculate variables
    c_eco_k_f_veg_props = one.(cEco)
    LITC2N = z_zero
    LIGNIN = z_zero
    MTF = o_one
    SCLIGNIN = z_zero
    LIGEFF = z_zero

    ## pack land variables
    @pack_nt (LIGEFF, LIGNIN, LITC2N, MTF, SCLIGNIN) ⇒ land.properties
    @pack_nt c_eco_k_f_veg_props ⇒ land.diagnostics
    return land

end

purpose(::Type{cTauVegProperties_none}) = "Sets the effect of vegetation properties on decomposition rates to 1 (no vegetation effect)."

@doc """

$(getProcessDocstring(cTauVegProperties_none))

---

# Extended help
"""
cTauVegProperties_none
