export updateState_wSimple
@with_kw struct updateState_wSimple{T} <: updateState
    calcFlux :: T = true
end

function compute(o::updateState_wSimple, forcing, out, modelInfo)
    @unpack_updateState_wSimple o
    @unpack_land begin
        (fracTranspiration, fracEvapSoil) ∈ out.diagnostics
        (snowMelt, transpiration, evapSoil, rain, roSat, snow) ∈ out.fluxes
        (wSnow, wSoil) ∈ out.pools
    end
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

    @pack_land begin
        (evapSoil, evapTotal, roTotal) ∋ out.fluxes
        (wSoil, wSnow) ∋ out.pools
    end

    return out
end

function update(o::updateState_wSimple, forcing, out, modelInfo)
    return out
end
