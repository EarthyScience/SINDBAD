export evapSoil_demSup

@bounds @describe @units @with_kw struct evapSoil_demSup{T1, T2} <: evapSoil
    α::T1 = 0.075 | (0.051, 3.0) | "alpha parameter" | ""
    supLim::T2 = 0.5 | (0.01, 0.99) | "supLim parameter" | ""
end

function compute(o::evapSoil_demSup, forcing, out, modelInfo)
    @unpack_evapSoil_demSup o
    @unpack_land begin
        wSoil ∈ out.pools
        Rn ∈ forcing
    end

    PETsoil = Rn * α
    PETsoil = PETsoil < 0.0 ? 0.0 : PETsoil
    fracEvapSoil = min(PETsoil / wSoil[1], supLim)
    evapSoil = fracEvapSoil * wSoil[1]

    @pack_land begin
        (PETsoil, evapSoil) ∋ out.fluxes
        fracEvapSoil ∋ out.diagnostics
    end
    return out
end

function update(o::evapSoil_demSup, forcing, out, modelInfo)
    @unpack_land begin
        evapSoil ∈ out.fluxes
        wSoil ∈ out.pools
    end
    wSoil[1] = wSoil[1] - evapSoil

    @pack_land begin
        wSoil ∋ out.pools
    end

    return out
end

