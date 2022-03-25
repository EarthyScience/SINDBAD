@with_kw struct sumVariables_simple{T} <: sumVariables
    doSum::T = true
end

function compute(o::sumVariables_simple, forcing, out, info)
    @unpack_sumVariables_simple o
    vars2sum = info.modelRun.varsToSum
    tarr=propertynames(vars2sum)
    # @show out
    for tarname in tarr
        comps = Symbol.(getfield(vars2sum, tarname).components)
        outfield = Symbol.(getfield(vars2sum, tarname).outfield)
        datasubfields = getfield(out, outfield)
        dat = sum([getfield(datasubfields, compname) for compname in comps if compname in propertynames(datasubfields)])
        # @eval $tarname = $dat
        # out.computed.evapTotal
        # out.computed.wTotal
        # out.computed.roTotal
        # a="out = (; out..., $outfield = (; out.$outfield..., $tarname))"
        # b = Meta.parse(a)
        # @eval $b
        # @show a, b
        # "out = (; out..., fluxes = (; out.fluxes..., roSat))"
        # @set! out.computed = (; out..., computed = (; out.computed..., tarname))

    end
    return out
end

function update(o::sumVariables_simple, forcing, out, info)
    return out
end

export sumVariables_simple