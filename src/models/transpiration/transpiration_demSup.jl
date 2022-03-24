export transpiration_demSup

@with_kw struct transpiration_demSup{T1, T2} <: transpiration
    α::T1 = 0.15
    supLim::T2 = 0.50
end

function compute(o::transpiration_demSup, forcing, diagflux, states, info)
    @unpack_transpiration_demSup o
    (; Rn) = forcing
    (; wSoil) = states
    PETveg = Rn * α
    PETveg = PETveg < 0.0 ? 0.0 : PETveg
    fracTranspiration = min(PETveg/sum(wSoil[:,1]), supLim)
    return (; diagflux..., fracTranspiration; states)
end

function update(o::transpiration_demSup, forcing, diagflux, states, info)
    (; fracTranspiration) = diagflux
    (; wSoil) = states
    transpiration = fracTranspiration * sum(wSoil[:, 1])
    wSoil[1] = wSoil[1] - transpiration


    return (;diagflux..., transpiration), (;states..., wSoil)
end
