export transpiration_demSup

@bounds @describe @units @with_kw struct transpiration_demSup{T1, T2} <: transpiration
    α::T1 = 0.075 | (0.051, 3.0) | "alpha parameter for vegetation" | ""
    supLim::T2 = 0.5 | (0.01, 0.99) | "supLim parameter for transpiration" | ""
end

function compute(o::transpiration_demSup, forcing, out, info)
    @unpack_transpiration_demSup o
    (; Rn) = forcing
    (; wSoil) = out.states
    PETveg = Rn * α
    PETveg = PETveg < 0.0 ? 0.0 : PETveg
    ∑wSoil = sum(wSoil[:,1])
    fracTranspiration = min(PETveg/∑wSoil, supLim)
    transpiration = fracTranspiration * ∑wSoil
    # @show α, supLim, fracTranspiration, PETveg, transpiration
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
