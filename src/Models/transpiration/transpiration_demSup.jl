export transpiration_demSup

@with_kw struct transpiration_demSup{T1, T2} <: transpiration
    α::T1 = 0.15
    supLim::T2 = 0.50
end

function compute(o::transpiration_demSup, forcing, out)
    @unpack_transpiration_demSup o
    (; Rn) = forcing
    (; wSoil) = out
    PETveg = Rn * α
    PETveg = PETveg < 0.0 ? 0.0 : PETveg
    fracTranspiration = min(PETveg/sum(wSoil[:,1]), supLim)
    return (; out..., fracTranspiration)
end

function update(o::transpiration_demSup, forcing, out)
    (; wSoil, fracTranspiration) = out
    transpiration = fracTranspiration * sum(wSoil[:, 1])
    wSoil[1] = wSoil[1] - transpiration
    return (; out..., wSoil, transpiration)
end
