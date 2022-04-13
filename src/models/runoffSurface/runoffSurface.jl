export runoffSurface
"""
Runoff from surface water storages

# Approaches:
 - all: calculate the runoff from surface water storage
 - directIndirect: calculate the runoff from surface water storage
 - directIndirectFroSoil: calculate the runoff from surface water storage considering frozen soil fraction
 - indirect: calculate the runoff from surface water storage
 - none: sets surface runoff [runoffSurface] from the storage to zeros
 - Orth2013: calculates the delay coefficient of first 60 days as a precomputation. calculates the base runoff
 - Trautmann2018: calculates the delay coefficient of first 60 days as a precomputation based on Orth et al. 2013 & as it is used in Trautmannet al. 2018. calculates the base runoff based on Orth et al. 2013 & as it is used in Trautmannet al. 2018
"""
abstract type runoffSurface <: LandEcosystem end
include("runoffSurface_all.jl")
include("runoffSurface_directIndirect.jl")
include("runoffSurface_directIndirectFroSoil.jl")
include("runoffSurface_indirect.jl")
include("runoffSurface_none.jl")
include("runoffSurface_Orth2013.jl")
include("runoffSurface_Trautmann2018.jl")
