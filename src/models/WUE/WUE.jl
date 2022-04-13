export WUE
"""
Estimate wue

# Approaches:
 - constant: calculates the WUE/AOE as a constant in space & time
 - expVPDDayCo2: calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD
 - fVPDDay: calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD
 - fVPDDayCo2: calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD
 - Medlyn2011: calculates the WUE/AOE ci/ca as a function of daytime mean VPD. calculates the WUE/AOE ci/ca as a function of daytime mean VPD & ambient co2
"""
abstract type WUE <: LandEcosystem end
include("WUE_constant.jl")
include("WUE_expVPDDayCo2.jl")
include("WUE_fVPDDay.jl")
include("WUE_fVPDDayCo2.jl")
include("WUE_Medlyn2011.jl")
