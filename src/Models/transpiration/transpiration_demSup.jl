export transpiration_demSup

@with_kw struct transpiration_demSup{type} <: TerEcosystem
    α :: type = 0.15
    supLim :: type = 0.50
end

function compute(o::transpiration_demSup, forcing, out)
    @unpack_transpiration_demSup o
    (; Rn) = forcing
    (; wSoil) = out
    PETveg = Rn * α
    PETveg = PETveg < 0.0 ? 0.0 : PETveg
    fracTranspiration = minimum([PETveg/wSoil, supLim])
    return (; out..., fracTranspiration)
end