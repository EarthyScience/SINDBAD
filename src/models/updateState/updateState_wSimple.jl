export updateState_wSimple
@with_kw struct updateState_wSimple{T} <: updateState
    calcFlux :: T = true
end

function compute(o::updateState_wSimple, forcing, out, info)
    @unpack_updateState_wSimple o
    (; fracTranspiration, fracEvapSoil) = out.diagnostics
    (; snowMelt, transpiration, evapSoil, rain, roSat, snow) = out.fluxes
    (; wSnow, wSoil) = out.states
    # assert fracTranspiration + fracEvapSoil < 1
    # assert
    if fracTranspiration + fracEvapSoil >= 1.0
        fracEvapSoil = 1.0 - fracTranspiration
        evapSoil = fracEvapSoil * sum(wSoil[:, 1])
    end

    roTotal = roSat
    evapTotal = evapSoil + transpiration
    wSnow[1] = wSnow[1] + snow - snowMelt
    wSoil[1] = wSoil[1] + rain + snowMelt - roTotal - evapTotal
    out = (; out..., states = (; out.states..., wSoil, wSnow))
    out = (; out..., fluxes = (; out.fluxes..., evapSoil, evapTotal, roTotal))
    return out
end

function update(o::updateState_wSimple, forcing, out, info)
    return out
end
