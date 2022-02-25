export updateState_wSimple
@with_kw struct updateState_wSimple{type} <: LandEcosystem
    calcFlux :: type = true
end

function compute(o::updateState_wSimple, forcing, out)
    @unpack_updateState_wSimple o
    (; fracTranspiration, fracEvapSoil, snowMelt, roSat, rain, snow, wSnow, wSoil) = out
    transpiration = fracTranspiration * wSoil
    evapSoil = fracEvapSoil * wSoil
    roTotal = roSat
    evapTotal = evapSoil + transpiration
    wSnow = wSnow + snow - snowMelt
    wSoil = wSoil + rain + snowMelt - roTotal - evapTotal
    return (; out..., wSnow, wSoil, roTotal,  evapTotal, evapSoil, transpiration)
end