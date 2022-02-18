@with_kw struct updateState{type} <: EarthEcosystem
    calcFlux :: type = true
end

function run(o::updateState, forcing, out)
    @unpack_updateState o # repetition
    (; fracTranspiration, fracEvapSoil, fracSnowMelt, rain, snow, wSnow, wSoil) = out
    snowMelt = fracSnowMelt * wSnow
    transpiration = fracTranspiration * wSoil
    evapSoil = fracEvapSoil * wSoil
    wSnow = wSnow + snow - fracSnowMelt * wSnow
    wSoil = wSoil + rain + snowMelt - evapSoil - transpiration
    return (; out..., wSnow, wSoil, snowMelt, evapSoil, transpiration)
end