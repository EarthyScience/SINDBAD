export gppSoilW_CASA

@bounds @describe @units @with_kw struct gppSoilW_CASA{T1} <: gppSoilW
    Bwe::T1 = 0.5 | (0, 1) | "base water stress" | ""
end


function precompute(o::gppSoilW_CASA, forcing, land, helpers)
    ## unpack parameters and forcing
    ## unpack land variables
    @unpack_land begin
        𝟘  ∈ helpers.numbers
    end
    SMScGPP_prev = 𝟘

    ## pack land variables
    @pack_land SMScGPP_prev => land.gppSoilW
    return land
end

function compute(o::gppSoilW_CASA, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppSoilW_CASA o
    @unpack_forcing Tair ∈ forcing


    ## unpack land variables
    @unpack_land begin
        SMScGPP_prev ∈ land.gppSoilW
        PAW ∈ land.vegAvailableWater
        PET ∈ land.PET
        (𝟘, 𝟙) ∈ helpers.numbers
    end

    OmBweOPET = (𝟙 - Bwe) / PET

    We = Bwe + OmBweOPET * sum(PAW) #@needscheck: originally, transpiration was used here but that does not make sense, as it is not calculated yet for this time step. This has been replaced by sum of plant available water.

    SMScGPP = (Tair > 𝟘) & (PET > 𝟘) ? We : SMScGPP_prev # use the current We if the temperature and PET are favorable, else use the previous one.

    SMScGPP_prev = SMScGPP

    ## pack land variables
    @pack_land (OmBweOPET, SMScGPP, SMScGPP_prev) => land.gppSoilW
    return land
end

@doc """
soil moisture stress on gppPot based on base stress and relative ratio of PET and PAW (CASA)

# Parameters
$(PARAMFIELDS)

---

# compute:

*Inputs*
 - land.vegAvailableWater.PAW: values of soil moisture current time step
 - land.PET.PET: potential ET

*Outputs*
 - land.gppSoilW.SMScGPP: soil moisture stress on gppPot (0-1)

---

# Extended help

*References*
 - Forkel; M.; Carvalhais; N.; Schaphoff; S.; v. Bloh; W.; Migliavacca; M.  Thurner; M.; & Thonicke; K.: Identifying environmental controls on  vegetation greenness phenology through model–data integration  Biogeosciences; 11; 7025–7050; https://doi.org/10.5194/bg-11-7025-2014;2014.

*Versions*
 - 1.1 on 22.01.2021 [skoirala]

*Created by:*
 - skoirala

*Notes*
"""
gppSoilW_CASA