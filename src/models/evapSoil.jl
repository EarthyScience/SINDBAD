@with_kw struct evapSoil{type} <: EarthEcosystem
    α :: type = 0.05
    supLim :: type = 0.25
end

function run(o::evapSoil, forcing, out)
    @unpack_evapSoil o
    (; Rn) = forcing
    (; wSoil) = out
    PETsoil = Rn * α
    PETsoil = PETsoil < 0.0 ? 0.0 : PETsoil
    fracEvapSoil = minimum([PETsoil/wSoil, supLim])
    return (; out..., fracEvapSoil)
end