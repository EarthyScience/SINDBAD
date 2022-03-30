@with_kw struct sumVariables_simple{T} <: sumVariables
    doSum::T = true
end

function setsubfield(out, varname = :fluxes, vals = (:a, 1))
    return @eval (; $out..., $varname = (; $out.$varname...,$(vals[1]) = $vals[2]))
end

function compute(o::sumVariables_simple, forcing, out, modelInfo)
    @unpack_sumVariables_simple o
    variablestosum = modelInfo.compute.sum
    tarr=propertynames(variablestosum)
    for tarname in tarr
        comps = getfield(variablestosum, tarname).components
        outfield = getfield(variablestosum, tarname).fieldname
        datasubfields = getfield(out, outfield)
        dat = sum([getfield(datasubfields, compname) for compname in comps if compname in propertynames(datasubfields)])
        # out = @eval (; $out..., $outfield = (; $out.$outfield...,$(tarname) = $dat))
                # out = setsubfield(out, outfield, (tarname, dat))
    end
    return out
end

function update(o::sumVariables_simple, forcing, out, modelInfo)
    return out
end



export sumVariables_simple