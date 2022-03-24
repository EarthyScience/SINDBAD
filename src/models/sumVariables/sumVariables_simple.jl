@with_kw struct sumVariables_simple{T} <: sumVariables
    doSum::T = true
end

function compute(o::sumVariables_simple, forcing, out, info)
    @unpack_sumVariables_simple o
    @show info.modelRun
    for varib in keys(info.modelRun.varsToSum)
        @eval tmp=info.modelRun.varsToSum.$varib
        tarfield = Symbol(tmp.destination)
        tmpSum = 0.0
        for comp in tmp.components
            fieldname=Symbol(split(comp, ".")[1])
            compname=Symbol(split(comp, ".")[2])
            ofields = propertynames(@eval out.$fieldname)
            if compname in ofields
                @eval tmpComp = out.$fieldname.$compname
                if fieldname == Symbol("states")
                    tmpComp = sum(tmpComp)
                end
                tmpSum = tmpSum + tmpComp
                @show compname, tmpComp, tmpSum
                # @show @eval $compname
            end
            # @show fieldname, compname, ofields
        end
        @show tmpSum, varib
        @eval $varib = $tmpSum
        @show evapTotal
        # (; outsp[1].fluxes..., evapTotal)
        # outsp = (; outsp..., fluxes = (; outsp.fluxes..., evapTotal))
        # @eval outsp = (; outsp..., $String(tarfield) = (; outsp[1].$tarfield..., $varib))
    end
    @show "done done"
    return out
end

function update(o::sumVariables_simple, forcing, out, info)
    return out
end

export sumVariables_simple