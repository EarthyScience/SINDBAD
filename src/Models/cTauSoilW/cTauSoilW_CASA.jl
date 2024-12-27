export cTauSoilW_CASA

#! format: off
@bounds @describe @units @timescale @with_kw struct cTauSoilW_CASA{T1} <: cTauSoilW
    Aws::T1 = 1.0 | (0.001, 1000.0) | "curve (expansion/contraction) controlling parameter" | "" | ""
end
#! format: on

function define(params::cTauSoilW_CASA, forcing, land, helpers)
    @unpack_cTauSoilW_CASA params
    @unpack_nt cEco ⇐ land.pools

    ## instantiate variables
    c_eco_k_f_soilW = one.(cEco)

    ## pack land variables
    @pack_nt c_eco_k_f_soilW ⇒ land.diagnostics
    return land
end

function compute(params::cTauSoilW_CASA, forcing, land, helpers)
    ## unpack parameters
    @unpack_cTauSoilW_CASA params

    ## unpack land variables
    @unpack_nt c_eco_k_f_soilW ⇐ land.diagnostics

    ## unpack land variables
    @unpack_nt begin
        rain ⇐ land.fluxes
        soilW_prev ⇐ land.pools
        fsoilW_prev ⇐ land.diagnostics
        PET ⇐ land.fluxes
        (z_zero, o_one) ⇐ land.constants
    end
    # NUMBER OF TIME STEPS PER YEAR -> TIME STEPS PER MONTH
    TSPY = helpers.dates.timesteps_in_year #sujan
    TSPM = TSPY / 12
    # BELOW GROUND RATIO [BGRATIO] AND BELOW GROUND MOISTURE EFFECT [BGME]
    BGRATIO = z_zero
    BGME = o_one
    # PREVIOUS TIME STEP VALUES
    pBGME = fsoilW_prev #sujan
    # FOR PET > 0
    ndx = (PET > 0)
    # COMPUTE BGRATIO
    BGRATIO[ndx] = (soilW_prev[ndx, 1] / TSPM + rain[ndx, tix]) / PET[ndx, tix]
    # ADJUST ACCORDING TO Aws
    BGRATIO = BGRATIO * Aws
    # COMPUTE BGME
    ndx1 = ndx & (BGRATIO >= 0.0 & BGRATIO < 1)
    BGME[ndx1] = 0.1 + (0.9 * BGRATIO[ndx1])
    ndx2 = ndx & (BGRATIO >= 1 & BGRATIO <= 2)
    BGME[ndx2] = 1.0
    ndx3 = ndx & (BGRATIO > 2 & BGRATIO <= 30)
    BGME[ndx3] = 1 + 1 / 28 - 0.5 / 28 * BGRATIO[ndx[ndx3]]
    ndx4 = ndx & (BGRATIO > 30)
    BGME[ndx4] = 0.5
    # WHEN PET IS 0; SET THE BGME TO THE PREVIOUS TIME STEPS VALUE
    ndxn = (PET <= 0.0)
    BGME[ndxn] = pBGME[ndxn]
    BGME = maxZero(minOne(BGME))
    # FEED IT TO THE STRUCTURE
    fsoilW = BGME
    # set the same moisture stress to all carbon pools
    c_eco_k_f_soilW[helpers.pools.zix.cEco] = fsoilW

    ## pack land variables
    @pack_nt fsoilW ⇒ land.diagnostics
    return land
end

@doc """
Compute effect of soil moisture on soil decomposition as modelled in CASA [BGME - below grounf moisture effect]. The below ground moisture effect; taken directly from the century model; uses soil moisture from the previous month to determine a scalar that is then used to determine the moisture effect on below ground carbon fluxes. BGME is dependent on PET; Rainfall. This approach is designed to work for Rainfall & PET values at the monthly time step & it is necessary to scale it to meet that criterion.

# Parameters
$(SindbadParameters)

---

# compute:
Effect of soil moisture on decomposition rates using cTauSoilW_CASA

*Inputs*
 - helpers.dates.timesteps_in_year: number of time steps per year
 - land.fluxes.PET: potential evapotranspiration [mm]
 - land.diagnostics.fsoilW_prev: previous time step below ground moisture effect on decomposition processes
 - soilW_prev: soil moisture sum of all layers of previous time step [mm]
 - land.fluxes.rain: rainfall

*Outputs*
 - land.diagnostics.fsoilW: values for below ground moisture effect on decomposition processes

# instantiate:
instantiate/instantiate time-invariant variables for cTauSoilW_CASA


---

# Extended help

*References*
 - Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance & inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
 - Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., & Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data & ecosystem  modeling 1982–1998. Global & Planetary Change, 39[3-4], 201-213.
 - Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite & surface data. Global Biogeochemical Cycles, 7[4], 811-841.

*Versions*
 - 1.0 on 12.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais

Notesthe BGME is used as a scalar dependent on soil moisture; as the  sum of soil moisture for all layers. This can be partitioned into  different soil layers in the soil & affect independently the  decomposition processes of pools that are at the surface & deeper in  the soils.
"""
cTauSoilW_CASA
