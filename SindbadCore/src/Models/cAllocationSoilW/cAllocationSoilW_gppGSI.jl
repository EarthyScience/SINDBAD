export cAllocationSoilW_gppGSI

#! format: off
@bounds @describe @units @timescale @with_kw struct cAllocationSoilW_gppGSI{T1} <: cAllocationSoilW
    τ_soilW::T1 = 0.8 | (0.001, 1.0) | "temporal change rate for the water-limiting function" | "" | ""
end
#! format: on

function define(params::cAllocationSoilW_gppGSI, forcing, land, helpers)
    @unpack_nt begin
        soilW ⇐ land.pools
        ∑w_sat ⇐ land.properties
    end
    c_allocation_f_soilW_prev = sum(soilW) / ∑w_sat

    ## pack land variables
    @pack_nt c_allocation_f_soilW_prev ⇒ land.diagnostics
    return land
end

function compute(params::cAllocationSoilW_gppGSI, forcing, land, helpers)
    ## unpack parameters
    @unpack_cAllocationSoilW_gppGSI params

    ## unpack land variables
    @unpack_nt begin
        gpp_f_soilW ⇐ land.diagnostics
        c_allocation_f_soilW_prev ⇐ land.diagnostics
    end
    # computation for the moisture effect on decomposition/mineralization
    c_allocation_f_soilW = c_allocation_f_soilW_prev + (gpp_f_soilW - c_allocation_f_soilW_prev) * τ_soilW

    # set the prev
    c_allocation_f_soilW_prev = c_allocation_f_soilW

    ## pack land variables
    @pack_nt (c_allocation_f_soilW, c_allocation_f_soilW_prev) ⇒ land.diagnostics
    return land
end

purpose(::Type{cAllocationSoilW_gppGSI}) = "Calculates the moisture effect on allocation as for GPP using the GSI approach."

@doc """

$(getModelDocString(cAllocationSoilW_gppGSI))

---

# Extended help

*References*
 - Forkel M, Carvalhais N, Schaphoff S, von Bloh W, Migliavacca M, Thurner M, Thonicke K [2014] Identifying environmental controls on vegetation greenness phenology through model–data integration. Biogeosciences, 11, 7025–7050.
 - Forkel, M., Migliavacca, M., Thonicke, K., Reichstein, M., Schaphoff, S., Weber, U., Carvalhais, N. (2015).  Codominant water control on global interannual variability and trends in land surface phenology & greenness.
 - Jolly, William M., Ramakrishna Nemani, & Steven W. Running. "A generalized, bioclimatic index to predict foliar phenology in response to climate." Global Change Biology 11.4 [2005]: 619-632.

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by*
 - ncarvalhais & sbesnard
"""
cAllocationSoilW_gppGSI
