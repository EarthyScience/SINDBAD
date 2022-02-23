export updateState_wSimple
@with_kw struct updateState_wSimple{type} <: TerEcosystem
    calcFlux :: type = true
end

function run(o::updateState_wSimple, forcing, out)
    @unpack_updateState_wSimple o # repetition
    (; fracTranspiration, fracEvapSoil, fracSnowMelt, rain, snow, wSnow, wSoil) = out
    snowMelt = fracSnowMelt * wSnow
    transpiration = fracTranspiration * wSoil
    evapSoil = fracEvapSoil * wSoil
    wSnow = wSnow + snow - fracSnowMelt * wSnow
    wSoil = wSoil + rain + snowMelt - evapSoil - transpiration
    return (; out..., wSnow, wSoil, snowMelt, evapSoil, transpiration)
end