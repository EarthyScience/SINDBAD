@bounds @describe @units @with_kw struct evapSoil_demSup{T1, T2} <: evapSoil
    α::T1 = 0.075 | (0.051, 3.0) | "alpha parameter" | ""
    supLim::T2 = 0.5 | (0.01, 0.99) | "supLim parameter" | ""
end

function compute(o::evapSoil_demSup, forcing, out, info)
    @unpack_evapSoil_demSup o
    (; wSoil) = out.states
    (; Rn) = forcing
    PETsoil = Rn * α
    PETsoil = PETsoil < 0.0 ? 0.0 : PETsoil
    fracEvapSoil = min(PETsoil / wSoil[1], supLim) # wSoil[index]
    evapSoil = fracEvapSoil * wSoil[1]

    out = (; out..., fluxes = (; out.fluxes..., PETsoil, evapSoil))
    out = (; out..., diagnostics = (; out.diagnostics..., fracEvapSoil))
    return out
end

function update(o::evapSoil_demSup, forcing, out, info)
    (; evapSoil) = out.fluxes
    (; wSoil) = out.states
    wSoil[1] = wSoil[1] - evapSoil
    out = (; out..., states = (; out.states..., wSoil))
    return out
end

export evapSoil_demSup
