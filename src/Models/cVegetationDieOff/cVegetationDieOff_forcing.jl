export cVegetationDieOff_forcing

struct cVegetationDieOff_forcing <: cVegetationDieOff end

function define(params::cVegetationDieOff_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_dist_intensity ⇐ forcing
    c_fVegDieOff = f_dist_intensity
    @pack_nt c_fVegDieOff ⇒ land.diagnostics
    return land
end

function compute(params::cVegetationDieOff_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_dist_intensity ⇐ forcing
    c_fVegDieOff = f_dist_intensity
    @pack_nt c_fVegDieOff ⇒ land.diagnostics
    return land
end

@doc """
reads and passes along to the land diagnostics the fraction of vegetation pools that die off 

# Parameters
$(SindbadParameters)

---

# compute:
nothing

*Inputs*
 - f_dist_intensity -> bad name... f_veg_dieoff

*Outputs*

# update

- c_fVegDieOff ⇒ land.diagnostics

---

# Extended help

*References*
 - Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance & inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].

*Versions*
 - 1.0 on summer 2024

*Created by:*
 - Nuno
"""
cVegetationDieOff_forcing
