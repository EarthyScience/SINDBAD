export updateState_wSimple
@with_kw struct updateState_wSimple{T} <: updateState
    calcFlux :: T = true
end

function compute(o::updateState_wSimple, forcing, diagflux, states, info)
    @unpack_updateState_wSimple o
    (; fracTranspiration, fracEvapSoil, snowMelt, fracRoSat, rain, snow, wSnow, wSoil) = out
    # assert fracTranspiration + fracEvapSoil < 1
    # assert 
    if fracTranspiration + fracEvapSoil >= 1.0
        fracEvapSoil = 1.0 - fracTranspiration
    end

    transpiration = fracTranspiration * sum(wSoil[:, 1])
    evapSoil = fracEvapSoil * sum(wSoil[:, 1])
    roSat = fracRoSat * sum(wSoil[:, 1])
    roTotal = roSat
    evapTotal = evapSoil + transpiration
    wSnow[1] = wSnow[1] + snow - snowMelt
    wSoil[1] = wSoil[1] + rain + snowMelt - roTotal - evapTotal
    return (; out..., wSnow, wSoil, roTotal, evapTotal, evapSoil, transpiration)
end

function update(o::updateState_wSimple, forcing, diagflux, states, info)
    return out
end
