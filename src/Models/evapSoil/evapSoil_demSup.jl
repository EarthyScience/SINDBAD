<<<<<<< HEAD
@with_kw struct evapSoil{type} <: TerEcosystem
=======
export evapSoil_demSup

@with_kw struct evapSoil_demSup{type} <: LandEcosystem
>>>>>>> 726b9fd (merge of main and tools_skoirala; cleanup, unit conversion)
    α::type = 0.075
    supLim::type = 0.5
end

function run(o::evapSoil, forcing, out)
    @unpack_evapSoil o
    (; Rn) = forcing
    (; wSoil) = out
    PETsoil = Rn * α
    PETsoil = PETsoil < 0.0 ? 0.0 : PETsoil
    fracEvapSoil = minimum([PETsoil / wSoil, supLim])
    return (; out..., PETsoil, fracEvapSoil)
end
