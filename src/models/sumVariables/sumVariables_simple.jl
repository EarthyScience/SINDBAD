@with_kw struct sumVariables_simple{T} <: sumVariables
    doSum::T = true
end

function compute(o::sumVariables_simple, forcing, out)
    @unpack_sumVariables_simple o

    function setsubfield(out, varname = :fluxes, vals = (:a, 1))
        return @eval (; $out..., $varname = (; $out.$varname...,$(vals[1]) = $vals[2]))
    end

    vars2sum = info.modelRun.varsToSum
    tarr=propertynames(vars2sum)
    for tarname in tarr
        comps = Symbol.(getfield(vars2sum, tarname).components)
        outfield = Symbol.(getfield(vars2sum, tarname).outfield)
        datasubfields = getfield(out, outfield)
        dat = sum([getfield(datasubfields, compname) for compname in comps if compname in propertynames(datasubfields)])
        out = setsubfield(out, outfield, (tarname, dat))
    end
    return out
end

function update(o::sumVariables_simple, forcing, out)
    return out
end



export sumVariables_simple