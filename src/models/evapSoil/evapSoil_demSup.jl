@bounds @describe @units @with_kw struct evapSoil_demSup{T1, T2} <: evapSoil
    α::T1 = 0.075 | (0.051, 3.0) | "alpha parameter" | ""
    supLim::T2 = 0.5 | (0.01, 0.99) | "supLim parameter" | ""
end

function compute(o::evapSoil_demSup, forcing, out, modelInfo)
    @unpack_evapSoil_demSup o
    (; wSoil) = out.pools
    (; Rn) = forcing

    PETsoil = Rn * α
    PETsoil = PETsoil < 0.0 ? 0.0 : PETsoil
    fracEvapSoil = min(PETsoil / wSoil[1], supLim)
    evapSoil = fracEvapSoil * wSoil[1]

    out = (; out..., fluxes = (; out.fluxes..., PETsoil, evapSoil))
    out = (; out..., diagnostics = (; out.diagnostics..., fracEvapSoil))
    return out
end

function update(o::evapSoil_demSup, forcing, out, modelInfo)
    (; evapSoil) = out.fluxes
    (; wSoil) = out.pools
    wSoil[1] = wSoil[1] - evapSoil
    # out = (; out..., pools = (; out.pools..., wSoil)) # for vectors, the unpacking is referencing the
    return out
end

export evapSoil_demSup
