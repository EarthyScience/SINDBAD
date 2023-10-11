export runoffInfiltrationExcess_Jung

struct runoffInfiltrationExcess_Jung <: runoffInfiltrationExcess end

function compute(params::runoffInfiltrationExcess_Jung, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        (WBP, fAPAR) ∈ land.states
        kSat ∈ land.soilWBase
        rain ∈ land.fluxes
        rainInt ∈ land.states
        (z_zero, o_one) ∈ land.wCycleBase
    end
    # assumes infiltration capacity is unlimited in the vegetated fraction [infiltration flux = P*fpar] the infiltration flux for the unvegetated fraction is given as the minimum of the precip & the min of precip intensity [P] & infiltration capacity [I] scaled with rain duration [P/R]

    # get infiltration capacity of the first layer
    pInfCapacity = kSat[1] / helpers.dates.timesteps_in_day in mm / hr
    InfExcess =
        rain - (rain * fAPAR +
                (o_one - fAPAR) * min(rain, min(pInfCapacity, rainInt) * rain / rainInt))
    inf_excess_runoff = rain > z_zero ? InfExcess : zero(InfExcess)
    WBP = WBP - inf_excess_runoff

    ## pack land variables
    @pack_land begin
        inf_excess_runoff => land.fluxes
        WBP => land.states
    end
    return land
end

@doc """
infiltration excess runoff as a function of rainintensity and vegetated fraction

---

# compute:
Infiltration excess runoff using runoffInfiltrationExcess_Jung

*Inputs*
 - land.states.rainInt: rain intensity [mm/h]
 - land.fluxes.rain : rainfall [mm/time]
 - land.soilWBase.kSat: infiltration capacity [mm/day]
 - land.states.fAPAR: fraction of absorbed photosynthetically active radiation  (equivalent to "canopy cover" in Gash & Miralles)

*Outputs*
 - land.fluxes.runoffInfiltration: infiltration excess runoff [mm/time] - what runs off because  the precipitation intensity is to high for it to inflitrate in  the soil

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code
 - 1.1 on 22.11.2019 [skoirala]: moved from prec to dyna to handle land.states.fAPAR which is nPix, 1  

*Created by:*
 - mjung
"""
runoffInfiltrationExcess_Jung
