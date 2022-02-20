"""
            getAllModels(info)

provides the core modules of sindbad over which the TEM is run. The list is ordered and that order is maintained in the call of sindbad.
"""
function getAllModels()
    allModels = NamedTuple()
    allModels = (; rainSnow = "set rain and snow to fe.rainSnow.")
    allModels = (; allModels..., rainSnow = "set rain and snow to fe.rainSnow.")
    # ---------------------------------------------------------------------
    # Climate: rainfall, snowfall, rainfall intensities, PET, ambCO2
    # ---------------------------------------------------------------------
    allModels = (; allModels..., rainSnow = "set rain and snow to fe.rainSnow.")
    allModels = (; allModels..., rainInt = "set rainfall intensity")
    allModels = (; allModels..., PET = "set potential evapotranspiration")
    allModels = (; allModels..., ambCO2 = "set/get ambient CO2 concentration")
    # ---------------------------------------------------------------------
    # Get variables for previous time step and keep in s.prev. or d.prev
    # ---------------------------------------------------------------------
    allModels = (; allModels..., keepStates = "keep states from previous time step to s.prev")
    allModels = (; allModels..., getStates = "get the amount of water at the beginning of timestep")
    # ---------------------------------------------------------------------
    # Terrain: terrain/topography params
    # ---------------------------------------------------------------------
    allModels = (; allModels..., pTopo = "topographic properties")
    # ---------------------------------------------------------------------
    # Soil properties: texture, hydr. params, distribution per soil layers
    # ---------------------------------------------------------------------
    allModels = (; allModels..., soilTexture = "soil texture (sand,silt,clay, and organic matter fraction)")
    allModels = (; allModels..., pSoil = "soil properties (hydraulic properties)")
    allModels = (; allModels..., wSoilBase = "distribution of soil hydraulic properties over depth")
    # ---------------------------------------------------------------------
    # Veg. properties: structural, phenology, disturbances, LULCC, etc.
    # ---------------------------------------------------------------------
    allModels = (; allModels..., pVeg = "vegetation/structural properties")
    allModels = (; allModels..., vegFrac = "fractional coverage of vegetation")
    allModels = (; allModels..., fAPAR = "fraction of Absorbed Photosynthetically Active Radiation")
    allModels = (; allModels..., EVI = "EVI")
    allModels = (; allModels..., LAI = "leaf area index")
    # ---------------------------------------------------------------------
    # Root properties: root depth and distribution
    # ---------------------------------------------------------------------
    allModels = (; allModels..., rootMaxD = "maximum rooting depth")
    allModels = (; allModels..., rootFrac = "distribution of maximum water uptake by root per soil layer")
    # ---------------------------------------------------------------------
    # Snow processes
    # ---------------------------------------------------------------------
    allModels = (; allModels..., wSnowFrac = "calculate snow cover fraction")
    allModels = (; allModels..., evapSub = "calculate sublimation and update snow water equivalent")
    allModels = (; allModels..., snowMelt = "calculate snowmelt and update s.w.wSnow")
    # ---------------------------------------------------------------------
    # Water fluxes: runoff and evaporation processes
    # ---------------------------------------------------------------------
    allModels = (; allModels..., evapInt = "interception evaporation")
    allModels = (; allModels..., roInf = "infiltration excess runoff")
    allModels = (; allModels..., wSoilSatFrac = "saturated fraction of a grid cell")
    allModels = (; allModels..., roSat = "saturation runoff")
    allModels = (; allModels..., roInt = "interflow")
    allModels = (; allModels..., roOverland = "land over flow : sum of roSat and  roInf, if exists, else zero")
    allModels = (; allModels..., roSurf = "runoff from surface water storages")
    allModels = (; allModels..., wSoilPerc = "calculate the soil percolation = WBP at this point")
    allModels = (; allModels..., evapSoil = "soil evaporation")
    allModels = (; allModels..., wSoilRec = "recharge the soil")
    allModels = (; allModels..., gwRec = "recharge the groundwater")
    # ---------------------------------------------------------------------
    # Water transfer: upward flow from GW through soil
    # ---------------------------------------------------------------------
    allModels = (; allModels..., wGW2wSoil = "Groundwater soil moisture interactions (e.g. capilary flux,  water)")
    allModels = (; allModels..., wSoilUpflow = "Flux of water from lower to upper soil layers (upward soil moisture movement)")
    allModels = (; allModels..., wGW2wSurf = "water exchange between surface and groundwatertable in root zone etc")
    allModels = (; allModels..., roBase = "baseflow")
    # ---------------------------------------------------------------------
    # Water-carbon processes: demand and supply GPP and transpiration
    # ---------------------------------------------------------------------
    allModels = (; allModels..., pawAct = "plant available water")
    allModels = (; allModels..., gppPot = "maximum instantaneous radiation use efficiency")
    allModels = (; allModels..., gppfRdiff = "effect of diffuse radiation")
    allModels = (; allModels..., gppfRdir = "effect of direct radiation")
    allModels = (; allModels..., gppfTair = "effect of temperature")
    allModels = (; allModels..., gppfVPD = "VPD effect")
    allModels = (; allModels..., gppDem = "combine effects as multiplicative or minimum")
    allModels = (; allModels..., gppfwSoil = "GPP as a function of wSoil; should be set to none if coupled with transpiration")
    # ---------------------------------------------------------------------
    # Water-carbon interaction: GPP, transpiration, and water uptake
    # ---------------------------------------------------------------------
    allModels = (; allModels..., tranDem = "demand-driven Transpiration")
    allModels = (; allModels..., tranSup = "supply-limited Transpiration")
    allModels = (; allModels..., WUE = "estimate WUE")
    allModels = (; allModels..., gppAct = "combine effects as multiplicative or minimum; if coupled, uses tranSup")
    allModels = (; allModels..., transpiration = "if coupled, computed from GPP and AOE from WUE")
    allModels = (; allModels..., wRootUptake = "root water uptake (extract water from soil)")
    # ---------------------------------------------------------------------
    # Climate + additional effects: carbon metabolic processes
    # ---------------------------------------------------------------------
    allModels = (; allModels..., cCycleBase = "pool structure of the carbon cycle")
    allModels = (; allModels..., cTaufTsoil = "effect of soil temperature on decomposition rates")
    allModels = (; allModels..., cTaufwSoil = "effect of soil moisture on decomposition rates")
    allModels = (; allModels..., cTaufLAI = "calculate litterfall scalars (that affect the changes in the vegetation k)")
    allModels = (; allModels..., cTaufpSoil = "effect of soil texture on soil decomposition rates")
    allModels = (; allModels..., cTaufpVeg = "effect of vegetation properties on soil decomposition rates")
    allModels = (; allModels..., cTauAct = "combine effects of different factors on decomposition rates")
    allModels = (; allModels..., rafTair = "temperature effect on autotrophic maintenance respiration")
    # ---------------------------------------------------------------------
    # Climate + additional effects: carbon allocation to plant organs
    # ---------------------------------------------------------------------
    allModels = (; allModels..., cAllocfLAI = "effect of LAI on carbon allocation ")
    allModels = (; allModels..., cAllocfwSoil = "effect of soil moisture on carbon allocation ")
    allModels = (; allModels..., cAllocfTsoil = "effect of soil temperature on carbon allocation ")
    allModels = (; allModels..., cAllocfNut = "(pseudo)effect of nutrients on carbon allocation ")
    allModels = (; allModels..., cAlloc = "combine the different effects of carbon allocation ")
    allModels = (; allModels..., cAllocfTreeFrac = "adjustment of carbon allocation according to tree cover")
    # ---------------------------------------------------------------------
    # Autotrophic respiration
    # ---------------------------------------------------------------------
    allModels = (; allModels..., raAct = "determine growth and maintenance respiration -> NPP")
    # ---------------------------------------------------------------------
    # Carbon transfers: among different carbon pools
    # ---------------------------------------------------------------------
    allModels = (; allModels..., cFlowfpSoil = "effect of soil properties on the C transfers between pools")
    allModels = (; allModels..., cFlowfpVeg = "effect of vegetation properties on the C transfers between pools")
    allModels = (; allModels..., cFlowAct = "actual transfers of C between pools (of diagonal components)")
    allModels = (; allModels..., cCycle = "allocate carbon to vegetation components")
    # ---------------------------------------------------------------------
    # sum up components (fluxes/states), river routing, and water balance
    # ---------------------------------------------------------------------
    allModels = (; allModels..., sumVariables = "sum variables (through modelRun.json)")
    allModels = (; allModels..., riverRouting = "routing of runoff through river networks")
    allModels = (; allModels..., wBalance = "calculate the water balance")
    # ---------------------------------------------------------------------
    # Store the time series of selected state variables
    # ---------------------------------------------------------------------
    allModels = (; allModels..., storeStates = "store the full time series of selected state variables")
    allModels = (; allModels..., updateState = "update water state variables")
    return allModels

end
