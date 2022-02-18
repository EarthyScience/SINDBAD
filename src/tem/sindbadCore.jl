using Revise
using Sinbad
using Test

"""
getOrderedModels(info)
provides the core modules of sindbad over which the TEM is run. The list is ordered and that order is maintained in the call of sindbad.
"""
function getOrderedModels()
    orderedCoreModelsAll = NamedTuple()
    orderedCoreModelsAll = (; rainSnow = "set rain and snow to fe.rainSnow.")
    orderedCoreModelsAll = (; orderedCoreModelsAll..., rainSnow = "set rain and snow to fe.rainSnow.")
    # ---------------------------------------------------------------------
    # Climate: rainfall, snowfall, rainfall intensities, PET, ambCO2
    # ---------------------------------------------------------------------
    orderedCoreModelsAll = (; orderedCoreModelsAll...,rainSnow = "set rain and snow to fe.rainSnow.")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,rainInt = "set rainfall intensity")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,PET = "set potential evapotranspiration")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,ambCO2 = "set/get ambient CO2 concentration")
    # ---------------------------------------------------------------------
    # Get variables for previous time step and keep in s.prev. or d.prev
    # ---------------------------------------------------------------------
    orderedCoreModelsAll = (; orderedCoreModelsAll...,keepStates = "keep states from previous time step to s.prev")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,getStates = "get the amount of water at the beginning of timestep")
    # ---------------------------------------------------------------------
    # Terrain: terrain/topography params
    # ---------------------------------------------------------------------
    orderedCoreModelsAll = (; orderedCoreModelsAll...,pTopo = "topographic properties")
    # ---------------------------------------------------------------------
    # Soil properties: texture, hydr. params, distribution per soil layers
    # ---------------------------------------------------------------------
    orderedCoreModelsAll = (; orderedCoreModelsAll...,soilTexture = "soil texture (sand,silt,clay, and organic matter fraction)")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,pSoil = "soil properties (hydraulic properties)")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,wSoilBase = "distribution of soil hydraulic properties over depth")
    # ---------------------------------------------------------------------
    # Veg. properties: structural, phenology, disturbances, LULCC, etc.
    # ---------------------------------------------------------------------
    orderedCoreModelsAll = (; orderedCoreModelsAll...,pVeg = "vegetation/structural properties")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,vegFrac = "fractional coverage of vegetation")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,fAPAR = "fraction of Absorbed Photosynthetically Active Radiation")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,EVI = "EVI")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,LAI = "leaf area index")
    # ---------------------------------------------------------------------
    # Root properties: root depth and distribution
    # ---------------------------------------------------------------------
    orderedCoreModelsAll = (; orderedCoreModelsAll...,rootMaxD = "maximum rooting depth")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,rootFrac = "distribution of maximum water uptake by root per soil layer")
    # ---------------------------------------------------------------------
    # Snow processes
    # ---------------------------------------------------------------------
    orderedCoreModelsAll = (; orderedCoreModelsAll...,wSnowFrac = "calculate snow cover fraction")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,evapSub = "calculate sublimation and update snow water equivalent")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,snowMelt = "calculate snowmelt and update s.w.wSnow")
    # ---------------------------------------------------------------------
    # Water fluxes: runoff and evaporation processes
    # ---------------------------------------------------------------------
    orderedCoreModelsAll = (; orderedCoreModelsAll...,evapInt = "interception evaporation")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,roInf= "infiltration excess runoff")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,wSoilSatFrac = "saturated fraction of a grid cell")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,roSat = "saturation runoff")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,roInt = "interflow")
    # orderedCoreModelsAll = (; orderedCoreModelsAll...,roOverland = """land over flow sum of saturation and    
    # infiltration excess runoff] if e.g. infiltration excess runoff
    # and or saturation runoff are not explicitly modelled then assign a none 
    # handle that returnes zeros and lump the FastRunoff into interflow"""

    orderedCoreModelsAll = (; orderedCoreModelsAll...,roSurf = "runoff from surface water storages")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,wSoilPerc = "calculate the soil percolation = WBP at this point")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,evapSoil = "soil evaporation")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,wSoilRec = "recharge the soil")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,gwRec  = "recharge the groundwater")
    # ---------------------------------------------------------------------
    # Water transfer: upward flow from GW through soil
    # ---------------------------------------------------------------------
    orderedCoreModelsAll = (; orderedCoreModelsAll...,wGW2wSoil = "Groundwater soil moisture interactions (e.g. capilary flux,  water")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,wSoilUpflow = "Flux of water from lower to upper soil layers (upward soil moisture movement)")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,wGW2wSurf = "water exchange between surface and groundwatertable in root zone etc")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,roBase = "baseflow")

    # ---------------------------------------------------------------------
    # Water-carbon processes: demand and supply GPP and transpiration
    # ---------------------------------------------------------------------
    orderedCoreModelsAll = (; orderedCoreModelsAll...,pawAct = "plant available water")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,gppPot = "maximum instantaneous radiation use efficiency")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,gppfRdiff = "effect of diffuse radiation")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,gppfRdir = "effect of direct radiation")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,gppfTair = "effect of temperature")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,gppfVPD = "VPD effect")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,gppDem = "combine effects as multiplicative or minimum")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,gppfwSoil = "GPP as a function of wSoil; should be set to none if coupled with transpiration")
    # ---------------------------------------------------------------------
    # Water-carbon interaction: GPP, transpiration, and water uptake
    # ---------------------------------------------------------------------
    orderedCoreModelsAll = (; orderedCoreModelsAll...,tranDem = "demand-driven Transpiration")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,tranSup = "supply-limited Transpiration")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,WUE = "estimate WUE")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,gppAct = "combine effects as multiplicative or minimum; if coupled, uses tranSup")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,transpiration = "if coupled, computed from GPP and AOE from WUE")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,wRootUptake = "root water uptake (extract water from soil)")
    # ---------------------------------------------------------------------
    # Climate + additional effects: carbon metabolic processes
    # ---------------------------------------------------------------------
    orderedCoreModelsAll = (; orderedCoreModelsAll...,cCycleBase = "pool structure of the carbon cycle")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,cTaufTsoil = "effect of soil temperature on decomposition rates")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,cTaufwSoil = "effect of soil moisture on decomposition rates")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,cTaufLAI = "calculate litterfall scalars (that affect the changes in the vegetation k)")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,cTaufpSoil = "effect of soil texture on soil decomposition rates")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,cTaufpVeg = "effect of vegetation properties on soil decomposition rates")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,cTauAct = "combine effects of different factors on decomposition rates")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,rafTair = "temperature effect on autotrophic maintenance respiration")
    # ---------------------------------------------------------------------
    # Climate + additional effects: carbon allocation to plant organs
    # ---------------------------------------------------------------------
    orderedCoreModelsAll = (; orderedCoreModelsAll...,cAllocfLAI = "effect of LAI on carbon allocation ")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,cAllocfwSoil = "effect of soil moisture on carbon allocation ")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,cAllocfTsoil = "effect of soil temperature on carbon allocation ")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,cAllocfNut = "(pseudo)effect of nutrients on carbon allocation ")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,cAlloc = "combine the different effects of carbon allocation ")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,cAllocfTreeFrac = "adjustment of carbon allocation according to tree cover")
    # ---------------------------------------------------------------------
    # Autotrophic respiration
    # ---------------------------------------------------------------------
    orderedCoreModelsAll = (; orderedCoreModelsAll...,raAct = "determine growth and maintenance respiration -> NPP")
    # ---------------------------------------------------------------------
    # Carbon transfers: among different carbon pools
    # ---------------------------------------------------------------------
    orderedCoreModelsAll = (; orderedCoreModelsAll...,cFlowfpSoil = "effect of soil properties on the C transfers between pools")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,cFlowfpVeg = "effect of vegetation properties on the C transfers between pools")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,cFlowAct = "actual transfers of C between pools (of diagonal components)")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,cCycle = "allocate carbon to vegetation components")
    # litterfall and litter scalars
    # calculate carbon cycle/decomposition/respiration in soil
    # ---------------------------------------------------------------------
    # sum up components (fluxes/states), river routing, and water balance
    # ---------------------------------------------------------------------
    orderedCoreModelsAll = (; orderedCoreModelsAll...,sumVariables = "sum variables (through modelRun.json)")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,riverRouting = "routing of runoff through river networks")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,wBalance = "calculate the water balance")
    # ---------------------------------------------------------------------
    # Store the time series of selected state variables
    # ---------------------------------------------------------------------
    orderedCoreModelsAll = (; orderedCoreModelsAll...,storeStates = "store the full time series of selected state variables")
    orderedCoreModelsAll = (; orderedCoreModelsAll...,updateState = "update water state variables")
    return orderedCoreModelsAll

end
