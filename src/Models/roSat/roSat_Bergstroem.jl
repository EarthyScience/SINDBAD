export roSat_Bergstroem

@with_kw struct roSat_Bergstroem{type} <: LandEcosystem
    beta::type = 0.5
    s_max::type = 1000.0
    frac_ro::type = 0.2
end

function compute(o::roSat_Bergstroem, forcing, out)
    @unpack_roSat_Bergstroem o 
    (; wSoil, WBP) = out
    # fracRoSat = minimum([maximum([(wSoil / s_max) .^ beta, 0]), 1.0])
    # roSat = fracRoSat * WBP
    roSat = frac_ro * WBP
    return (; out..., roSat)
end