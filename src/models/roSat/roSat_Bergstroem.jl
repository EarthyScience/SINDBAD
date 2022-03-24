export roSat_Bergstroem

@with_kw struct roSat_Bergstroem{T1, T2} <: roSat
    β::T1 = 0.5
    s_max::T2 = 1000.0
end

function compute(o::roSat_Bergstroem, forcing, diagflux, states, info)
    @unpack_roSat_Bergstroem o
    (; wSoil) = states
    #fracRoSat = (sum(wSoil[:,1]) / s_max)^β
    fracRoSat = 0.2
    #fracRoSat = fracRoSat < 0.0 ? 0.0 : fracRoSat > 1.0 ? 1.0 : fracRoSat
    return (; diagflux..., fracRoSat; states)
end

function update(o::roSat_Bergstroem, forcing, diagflux, states, info)
    (; fracRoSat, WBP) = diagflux
    (; wSoil) = states
    roSat = fracRoSat * WBP
    WBP = WBP - roSat
    wSoil[1] = wSoil[1] + WBP
    return (; diagflux..., roSat, WBP; states..., wSoil)
end
