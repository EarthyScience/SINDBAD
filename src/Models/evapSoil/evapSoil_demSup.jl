@bounds @describe @units @with_kw struct evapSoil_demSup{T1, T2} <: evapSoil
    α::T1 = 0.075 | (0.051, 3.0) | "alpha parameter" | ""
    supLim::T2 = 0.5 | (0.01, 0.99) | "supLim parameter" | ""
end

function compute(o::evapSoil_demSup, forcing, out)
    @unpack_evapSoil_demSup o
    (; Rn) = forcing
    (; wSoil) = out # unpack.out, unpack.states
    PETsoil = Rn * α
    PETsoil = PETsoil < 0.0 ? 0.0 : PETsoil
    fracEvapSoil = min(PETsoil / wSoil[1], supLim) # wSoil[index]
    return (; out..., PETsoil, fracEvapSoil)
end

function update(o::evapSoil_demSup, forcing, out)
    (; wSoil, fracEvapSoil) = out
    evapSoil = fracEvapSoil * wSoil[1]
    wSoil[1] = wSoil[1] - evapSoil
    return (; out..., wSoil, evapSoil)
end

export evapSoil_demSup
