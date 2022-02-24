export evapSoil_demSup

@with_kw struct evapSoil_demSup{type} <: LandEcosystem
    α::type = 0.075
    supLim::type = 0.5
end

function compute(o::evapSoil_demSup, forcing, out)
    @unpack_evapSoil_demSup o
    (; Rn) = forcing
    (; wSoil) = out
    PETsoil = Rn * α
    PETsoil = PETsoil < 0.0 ? 0.0 : PETsoil
    fracEvapSoil = minimum([PETsoil / wSoil, supLim])
    return (; out..., PETsoil, fracEvapSoil)
end
