export runoffSurface

abstract type runoffSurface <: LandEcosystem end

include("runoffSurface_all.jl")
include("runoffSurface_directIndirect.jl")
include("runoffSurface_directIndirectFroSoil.jl")
include("runoffSurface_indirect.jl")
include("runoffSurface_none.jl")
include("runoffSurface_Orth2013.jl")
include("runoffSurface_Trautmann2018.jl")

@doc """
Surface runoff generation process
# Approaches:
 - all: assumes all overland runoff is lost as surface runoff
 - directIndirect: assumes surface runoff is the sum of direct fraction of overland runoff and indirect fraction of surface water storage
 - directIndirectFroSoil: assumes surface runoff is the sum of direct fraction of overland runoff and indirect fraction of surface water storage. Direct fraction is additionally dependent on frozen fraction of the grid
 - indirect: assumes all overland runoff is recharged to surface water first, which then generates surface runoff
 - none: sets surface runoff to zero
 - Orth2013: delay coefficient of first 60 days to delay the runoff generation
 - Trautmann2018: based on Orth2013, as used in Trautmannet al. 2018
"""
runoffSurface
