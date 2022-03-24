@bounds @describe @units @with_kw struct evapSoil_demSup{T1, T2} <: evapSoil
    α::T1 = 0.075 | (0.051, 3.0) | "alpha parameter" | ""
    supLim::T2 = 0.5 | (0.01, 0.99) | "supLim parameter" | ""
end

function compute(o::evapSoil_demSup, forcing, diagflux, states, info)
    @unpack_evapSoil_demSup o
    (; Rn) = forcing
    (; wSoil) = states # unpack.out, unpack.states
    PETsoil = Rn * α
    PETsoil = PETsoil < 0.0 ? 0.0 : PETsoil
    fracEvapSoil = min(PETsoil / wSoil[1], supLim) # wSoil[index]
    (; fluxes..., PETsoil; diagnostics..., fracEvapSoil; states)

    return (; diagflux..., PETsoil, fracEvapSoil; states)
end

function update(o::evapSoil_demSup, forcing, diagflux, states, info)
    (; fracEvapSoil) = diagflux
    (; wSoil) = states
    evapSoil = fracEvapSoil * wSoil[1]
    wSoil[1] = wSoil[1] - evapSoil
    return (; diagflux..., evapSoil; states..., wSoil)
end

export evapSoil_demSup
