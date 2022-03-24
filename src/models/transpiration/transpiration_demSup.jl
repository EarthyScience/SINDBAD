export transpiration_demSup

@with_kw struct transpiration_demSup{T1, T2} <: transpiration
    α::T1 = 0.15
    supLim::T2 = 0.50
end

function compute(o::transpiration_demSup, forcing, out, info)
    @unpack_transpiration_demSup o
    (; Rn) = forcing
    (; wSoil) = out.states
    PETveg = Rn * α
    PETveg = PETveg < 0.0 ? 0.0 : PETveg
    fracTranspiration = min(PETveg/sum(wSoil[:,1]), supLim)
    transpiration = fracTranspiration * sum(wSoil[:, 1])
    out = (; out..., diagnostics = (; out.diagnostics..., fracTranspiration))
    out = (; out..., fluxes = (; out.fluxes..., transpiration, PETveg))
    return out
end

function update(o::transpiration_demSup, forcing, out, info)
    (; transpiration) = out.fluxes
    (; wSoil) = out.states
    wSoil[1] = wSoil[1] - transpiration
    out = (; out..., states = (; out.states..., wSoil))
    return out
end
