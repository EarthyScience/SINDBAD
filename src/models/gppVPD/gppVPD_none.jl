export gppVPD_none

struct gppVPD_none <: gppVPD end

function precompute(o::gppVPD_none, forcing, land, helpers)

    ## calculate variables
    # set scalar to a constant one [no effect on potential GPP]
    VPDScGPP = helpers.numbers.one

    ## pack land variables
    @pack_land VPDScGPP => land.gppVPD
    return land
end

@doc """
sets the VPD stress on gppPot to one (no stress)

---

# compute:

*Inputs*
 - helpers

*Outputs*
 - land.gppVPD.VPDScGPP: VPD effect on GPP between 0-1

# precompute:
precompute/instantiate time-invariant variables for gppVPD_none


---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarval
"""
gppVPD_none