@with_kw struct transpiration{type} <: TerEcosystem
    α :: type = 0.125
    supLim :: type = 0.50
end

function run(o::transpiration, forcing, out)
    @unpack_transpiration o
    (; Rn) = forcing
    (; wSoil) = out
    PETveg = Rn * α
    PETveg = PETveg < 0.0 ? 0.0 : PETveg
    fracTranspiration = minimum([PETveg/wSoil, supLim])
    return (; out..., fracTranspiration)
end