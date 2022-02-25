export roSat_Bergstroem

@with_kw struct roSat_Bergstroem{type} <: LandEcosystem
    beta::type = 0.5
    s_max  ::type = 1000.0
end

function compute(o::roSat_Bergstroem, forcing, out)
    @unpack_roSat_Bergstroem o 
    (; wSoil, WBP) = out
    fracRoSat = minimum([(sum(wSoil) / s_max) ^ beta, 1])
    roSat = fracRoSat * WBP
    return (; out..., roSat)
end