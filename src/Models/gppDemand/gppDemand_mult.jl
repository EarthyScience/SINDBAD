export gppDemand_mult

struct gppDemand_mult <: gppDemand end

function define(params::gppDemand_mult, forcing, land, helpers)
    @unpack_forcing f_VPD_day ∈ forcing
    gpp_climate_stressors = ones(typeof(f_VPD_day), 4)

    if hasproperty(land.pools, :soilW)
        @unpack_land soilW ∈ land.pools
        if soilW isa SVector
            gpp_climate_stressors = SVector{4}(gpp_climate_stressors)
        end
    end

    @pack_land (gpp_climate_stressors) => land.gppDemand

    return land
end

function compute(params::gppDemand_mult, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        gpp_f_cloud ∈ land.gppDiffRadiation
        fAPAR ∈ land.states
        gpp_potential ∈ land.gppPotential
        gpp_f_light ∈ land.gppDirRadiation
        gpp_climate_stressors ∈ land.gppDemand
        gpp_f_airT ∈ land.gppAirT
        gpp_f_vpd ∈ land.gppVPD
    end

    # @show gpp_f_airT, gpp_f_vpd, gpp_climate_stressors
    # set 3d scalar matrix with current scalars
    gpp_climate_stressors = repElem(gpp_climate_stressors, gpp_f_airT, gpp_climate_stressors, gpp_climate_stressors, 1)
    gpp_climate_stressors = repElem(gpp_climate_stressors, gpp_f_vpd, gpp_climate_stressors, gpp_climate_stressors, 2)
    gpp_climate_stressors = repElem(gpp_climate_stressors, gpp_f_light, gpp_climate_stressors, gpp_climate_stressors, 3)
    gpp_climate_stressors = repElem(gpp_climate_stressors, gpp_f_cloud, gpp_climate_stressors, gpp_climate_stressors, 4)

    # compute the product of all the scalars
    gpp_f_climate = gpp_f_light * gpp_f_cloud * gpp_f_airT * gpp_f_vpd

    # compute demand GPP
    gpp_demand = fAPAR * gpp_potential * gpp_f_climate

    ## pack land variables
    @pack_land (gpp_climate_stressors, gpp_f_climate, gpp_demand) => land.gppDemand
    return land
end

@doc """
compute the demand GPP as multipicative stress scalars

---

# compute:
Combine effects as multiplicative or minimum using gppDemand_mult

*Inputs*
 - land.gppAirT.gpp_f_airT: temperature effect on GPP [-], between 0-1
 - land.gppDiffRadiation.gpp_f_cloud: cloudiness scalar [-], between 0-1
 - land.gppDirRadiation.gpp_f_light: light saturation scalar [-], between 0-1
 - land.gppPotential.gpp_potential: maximum potential GPP based on radiation use efficiency
 - land.gppVPD.gpp_f_vpd: VPD effect on GPP [-], between 0-1
 - land.states.fAPAR: fraction of absorbed photosynthetically active radiation  [-] (equivalent to "canopy cover" in Gash & Miralles)

*Outputs*
 - land.gppDemand.gpp_f_climate [effective scalar, 0-1]
 - land.gppDemand.gpp_demand: demand GPP [gC/m2/time]

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarval

*Notes*
"""
gppDemand_mult
