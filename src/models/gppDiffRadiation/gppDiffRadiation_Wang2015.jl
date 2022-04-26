export gppDiffRadiation_Wang2015

@bounds @describe @units @with_kw struct gppDiffRadiation_Wang2015{T1} <: gppDiffRadiation
	μ::T1 = 0.46 | (0.0001, 1.0) | "" | ""
end

function precompute(o::gppDiffRadiation_Wang2015, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppDiffRadiation_Wang2015 o
    @unpack_forcing (Rg, RgPot) ∈ forcing

    ## calculate variables
    CI = 1 - Rg / RgPot #@needscheck: this is different to Turner which does not have 1- . So, need to check if this correct
    CI_min = CI
    CI_max = CI
    ## pack land variables
    @pack_land (CI_min, CI_max) => land.gppDiffRadiation
    return land
end

function compute(o::gppDiffRadiation_Wang2015, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppDiffRadiation_Wang2015 o

    @unpack_forcing (Rg, RgPot) ∈ forcing

    @unpack_land begin
        (CI_min, CI_max) ∈ land.gppDiffRadiation
        (𝟘, 𝟙, tolerance) ∈ helpers.numbers
    end



    ## calculate variables
    ## FROM SHANNING

    CI = 1 - Rg / RgPot #@needscheck: this is different to Turner which does not have 1- . So, need to check if this correct

    # update the minimum and maximum on the go
    CI_min = min(CI, CI_min)
    CI_max = min(CI, CI_max)

    CI_nor = (CI - CI_min) / (CI_max - CI_min + tolerance) # @needscheck: originally, CI_min and max were based on the year's data. see below.

    # yearsVec = helpers.dates.year
    # yearsVec = yearsVec[1:size(CI, 2)]
    # for i in unique(yearsVec)
    #     ndx = yearsVec == i
    #     CImin = min(CI[ndx], 2) #CImin is the minimum CI value of present year
    #     CImax = max(CI[ndx], 2)
    #     CI_nor[ndx] = (CI[ndx] - CImin) / (CImax - CImin)
    # end


    cScGPP = 𝟙 - μ * (𝟙 - CI_nor)
    CloudScGPP = RgPot > 𝟘  ? cScGPP : 𝟘

    ## pack land variables
    @pack_land (CloudScGPP, CI_min, CI_max) => land.gppDiffRadiation
    return land
end

@doc """
cloudiness scalar [radiation diffusion] on gppPot based on Wang2015

# Parameters
$(PARAMFIELDS)

---

# compute:

*Inputs*
 - forcing.Rg: Global radiation [SW incoming] [MJ/m2/time]
 - forcing.RgPot: Potential radiation [MJ/m2/time]
 - rueRatio : ratio of clear sky LUE to max LUE  in turner et al., appendix A, e_[g_cs] / e_[g_max], should be between 0 & 1

*Outputs*
 - land.gppDiffRadiation.CloudScGPP: effect of cloudiness on potential GPP

---

# Extended help

*References*
 - Turner, D. P., Ritts, W. D., Styles, J. M., Yang, Z., Cohen, W. B., Law, B. E., & Thornton, P. E. (2006).  A diagnostic carbon flux model to monitor the effects of disturbance & interannual variation in  climate on regional NEP. Tellus B: Chemical & Physical Meteorology, 58[5], 476-490.  DOI: 10.1111/j.1600-0889.2006.00221.x

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up [changed the output to nPix, nTix]
 - 1.1 on 22.01.2021 [skoirala]: minimum & maximum function had []  missing & were not working  

*Created by:*
 - mjung
 - ncarval
"""
gppDiffRadiation_Wang2015