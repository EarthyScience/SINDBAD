"""
            getEcoProcess(info)

provides the core modules of sindbad over which the TEM is run. The list is ordered and that order is maintained in the call of sindbad.
"""

function getEcoProcess()
    ecoProcess = NamedTuple()
    # ---------------------------------------------------------------------
    # Climate: rainfall, snowfall, rainfall intensities, PET, ambCO2
    # ---------------------------------------------------------------------
    ecoProcess = (; ecoProcess..., rainSnow = "set rain and snow to fe.rainSnow.")
    ecoProcess = (; ecoProcess..., rainInt = "set rainfall intensity")
    ecoProcess = (; ecoProcess..., PET = "set potential evapotranspiration")
    ecoProcess = (; ecoProcess..., ambCO2 = "set/get ambient CO2 concentration")
    # ---------------------------------------------------------------------
    # Get variables for previous time step and keep in s.prev. or d.prev
    # ---------------------------------------------------------------------
    ecoProcess = (; ecoProcess..., keepStates = "keep states from previous time step to s.prev")
    ecoProcess = (; ecoProcess..., getStates = "get the amount of water at the beginning of timestep")
    # ---------------------------------------------------------------------
    # Terrain: terrain/topography params
    # ---------------------------------------------------------------------
    ecoProcess = (; ecoProcess..., pTopo = "topographic properties")
    # ---------------------------------------------------------------------
    # Soil properties: texture, hydr. params, distribution per soil layers
    # ---------------------------------------------------------------------
    ecoProcess = (; ecoProcess..., soilTexture = "soil texture (sand,silt,clay, and organic matter fraction)")
    ecoProcess = (; ecoProcess..., pSoil = "soil properties (hydraulic properties)")
    ecoProcess = (; ecoProcess..., wSoilBase = "distribution of soil hydraulic properties over depth")
    # ---------------------------------------------------------------------
    # Veg. properties: structural, phenology, disturbances, LULCC, etc.
    # ---------------------------------------------------------------------
    ecoProcess = (; ecoProcess..., pVeg = "vegetation/structural properties")
    ecoProcess = (; ecoProcess..., vegFrac = "fractional coverage of vegetation")
    ecoProcess = (; ecoProcess..., fAPAR = "fraction of Absorbed Photosynthetically Active Radiation")
    ecoProcess = (; ecoProcess..., EVI = "EVI")
    ecoProcess = (; ecoProcess..., LAI = "leaf area index")
    # ---------------------------------------------------------------------
    # Root properties: root depth and distribution
    # ---------------------------------------------------------------------
    ecoProcess = (; ecoProcess..., rootMaxD = "maximum rooting depth")
    ecoProcess = (; ecoProcess..., rootFrac = "distribution of maximum water uptake by root per soil layer")
    # ---------------------------------------------------------------------
    # Snow processes
    # ---------------------------------------------------------------------
    ecoProcess = (; ecoProcess..., wSnowFrac = "calculate snow cover fraction")
    ecoProcess = (; ecoProcess..., evapSub = "calculate sublimation and update snow water equivalent")
    ecoProcess = (; ecoProcess..., snowMelt = "calculate snowmelt and update s.w.wSnow")
    # ---------------------------------------------------------------------
    # Water fluxes: runoff and evaporation processes
    # ---------------------------------------------------------------------
    ecoProcess = (; ecoProcess..., evapInt = "interception evaporation")
    ecoProcess = (; ecoProcess..., roInf = "infiltration excess runoff")
    ecoProcess = (; ecoProcess..., wSoilSatFrac = "saturated fraction of a grid cell")
    ecoProcess = (; ecoProcess..., roSat = "saturation runoff")
    ecoProcess = (; ecoProcess..., roInt = "interflow")
    ecoProcess = (; ecoProcess..., roOverland = "land over flow : sum of roSat and  roInf, if exists, else zero")
    ecoProcess = (; ecoProcess..., roSurf = "runoff from surface water storages")
    ecoProcess = (; ecoProcess..., wSoilPerc = "calculate the soil percolation = WBP at this point")
    ecoProcess = (; ecoProcess..., evapSoil = "soil evaporation")
    ecoProcess = (; ecoProcess..., wSoilRec = "recharge the soil")
    ecoProcess = (; ecoProcess..., gwRec = "recharge the groundwater")
    # ---------------------------------------------------------------------
    # Water transfer: upward flow from GW through soil
    # ---------------------------------------------------------------------
    ecoProcess = (; ecoProcess..., wGW2wSoil = "Groundwater soil moisture interactions (e.g. capilary flux,  water)")
    ecoProcess = (; ecoProcess..., wSoilUpflow = "Flux of water from lower to upper soil layers (upward soil moisture movement)")
    ecoProcess = (; ecoProcess..., wGW2wSurf = "water exchange between surface and groundwatertable in root zone etc")
    ecoProcess = (; ecoProcess..., roBase = "baseflow")
    # ---------------------------------------------------------------------
    # Water-carbon processes: demand and supply GPP and transpiration
    # ---------------------------------------------------------------------
    ecoProcess = (; ecoProcess..., pawAct = "plant available water")
    ecoProcess = (; ecoProcess..., gppPot = "maximum instantaneous radiation use efficiency")
    ecoProcess = (; ecoProcess..., gppfRdiff = "effect of diffuse radiation")
    ecoProcess = (; ecoProcess..., gppfRdir = "effect of direct radiation")
    ecoProcess = (; ecoProcess..., gppfTair = "effect of temperature")
    ecoProcess = (; ecoProcess..., gppfVPD = "VPD effect")
    ecoProcess = (; ecoProcess..., gppDem = "combine effects as multiplicative or minimum")
    ecoProcess = (; ecoProcess..., gppfwSoil = "GPP as a function of wSoil; should be set to none if coupled with transpiration")
    # ---------------------------------------------------------------------
    # Water-carbon interaction: GPP, transpiration, and water uptake
    # ---------------------------------------------------------------------
    ecoProcess = (; ecoProcess..., tranDem = "demand-driven Transpiration")
    ecoProcess = (; ecoProcess..., tranSup = "supply-limited Transpiration")
    ecoProcess = (; ecoProcess..., WUE = "estimate WUE")
    ecoProcess = (; ecoProcess..., gppAct = "combine effects as multiplicative or minimum; if coupled, uses tranSup")
    ecoProcess = (; ecoProcess..., transpiration = "if coupled, computed from GPP and AOE from WUE")
    ecoProcess = (; ecoProcess..., wRootUptake = "root water uptake (extract water from soil)")
    # ---------------------------------------------------------------------
    # Climate + additional effects: carbon metabolic processes
    # ---------------------------------------------------------------------
    ecoProcess = (; ecoProcess..., cCycleBase = "pool structure of the carbon cycle")
    ecoProcess = (; ecoProcess..., cTaufTsoil = "effect of soil temperature on decomposition rates")
    ecoProcess = (; ecoProcess..., cTaufwSoil = "effect of soil moisture on decomposition rates")
    ecoProcess = (; ecoProcess..., cTaufLAI = "calculate litterfall scalars (that affect the changes in the vegetation k)")
    ecoProcess = (; ecoProcess..., cTaufpSoil = "effect of soil texture on soil decomposition rates")
    ecoProcess = (; ecoProcess..., cTaufpVeg = "effect of vegetation properties on soil decomposition rates")
    ecoProcess = (; ecoProcess..., cTauAct = "combine effects of different factors on decomposition rates")
    ecoProcess = (; ecoProcess..., rafTair = "temperature effect on autotrophic maintenance respiration")
    # ---------------------------------------------------------------------
    # Climate + additional effects: carbon allocation to plant organs
    # ---------------------------------------------------------------------
    ecoProcess = (; ecoProcess..., cAllocfLAI = "effect of LAI on carbon allocation ")
    ecoProcess = (; ecoProcess..., cAllocfwSoil = "effect of soil moisture on carbon allocation ")
    ecoProcess = (; ecoProcess..., cAllocfTsoil = "effect of soil temperature on carbon allocation ")
    ecoProcess = (; ecoProcess..., cAllocfNut = "(pseudo)effect of nutrients on carbon allocation ")
    ecoProcess = (; ecoProcess..., cAlloc = "combine the different effects of carbon allocation ")
    ecoProcess = (; ecoProcess..., cAllocfTreeFrac = "adjustment of carbon allocation according to tree cover")
    # ---------------------------------------------------------------------
    # Autotrophic respiration
    # ---------------------------------------------------------------------
    ecoProcess = (; ecoProcess..., raAct = "determine growth and maintenance respiration -> NPP")
    # ---------------------------------------------------------------------
    # Carbon transfers: among different carbon pools
    # ---------------------------------------------------------------------
    ecoProcess = (; ecoProcess..., cFlowfpSoil = "effect of soil properties on the C transfers between pools")
    ecoProcess = (; ecoProcess..., cFlowfpVeg = "effect of vegetation properties on the C transfers between pools")
    ecoProcess = (; ecoProcess..., cFlowAct = "actual transfers of C between pools (of diagonal components)")
    ecoProcess = (; ecoProcess..., cCycle = "allocate carbon to vegetation components")
    # ---------------------------------------------------------------------
    # sum up components (fluxes/states), river routing, and water balance
    # ---------------------------------------------------------------------
    ecoProcess = (; ecoProcess..., sumVariables = "sum variables (through modelRun.json)")
    ecoProcess = (; ecoProcess..., riverRouting = "routing of runoff through river networks")
    ecoProcess = (; ecoProcess..., wBalance = "calculate the water balance")
    # ---------------------------------------------------------------------
    # Store the time series of selected state variables
    # ---------------------------------------------------------------------
    ecoProcess = (; ecoProcess..., storeStates = "store the full time series of selected state variables")
    ecoProcess = (; ecoProcess..., updateState = "update water state variables")
    return ecoProcess

end
