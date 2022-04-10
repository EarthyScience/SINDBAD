export transpiration_demSup

@bounds @describe @units @with_kw struct transpiration_demSup{T1,T2} <: transpiration
    α::T1 = 0.075 | (0.051, 3.0) | "alpha parameter for vegetation" | ""
    supLim::T2 = 0.5 | (0.01, 0.99) | "supLim parameter for transpiration" | ""
end

function compute(o::transpiration_demSup, forcing, out, modelInfo)
    @unpack_transpiration_demSup o
    
    @unpack_land begin
        Rn ∈ forcing
        wSoil ∈ out.pools
    end

    PETveg = Rn * α
    PETveg = PETveg < 0.0 ? 0.0 : PETveg
    ∑wSoil = sum(wSoil[:, 1])
    fracTranspiration = min(PETveg / ∑wSoil, supLim)
    transpiration = fracTranspiration * ∑wSoil

    @pack_land begin
        fracTranspiration ∋ out.diagnostics
        (transpiration, PETveg) ∋ out.fluxes
    end

    return out
end

function update(o::transpiration_demSup, forcing, out, modelInfo)
    @unpack_land begin
        transpiration ∈ out.fluxes
        wSoil ∈ out.pools
    end

    wSoil[1] = wSoil[1] - transpiration

    @pack_land begin
        wSoil ∋ out.pools
    end

    return out
end
