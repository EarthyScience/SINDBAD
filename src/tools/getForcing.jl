export getForcing

function clean_inputs(datapoint, vinfo, ::Val{T}) where {T}
    datapoint = applyUnitConversion(datapoint, vinfo.source2sindbadUnit, vinfo.additiveUnitConversion)
    bounds = vinfo.bounds
    datapoint = clamp(datapoint, bounds[1], bounds[2])
    return ismissing(datapoint) ? T(NaN) : T(datapoint)
end

"""
getForcing(info)
"""
function getForcing(info, ::Val{:table})
    doOnePath = false
    if !isempty(info.forcing.oneDataPath)
        doOnePath = true
        if isabspath(info.forcing.oneDataPath)
            dataPath = info.forcing.oneDataPath
        else
            dataPath = joinpath(info.sinbad_root, info.forcing.oneDataPath)
        end
    end
    varnames = propertynames(info.forcing.variables)
    varlist = []
    dataAr = []
    # forcing = (;)
    #if doOnePath
    #    ds = Dataset(dataPath)
    #end
    for v in varnames
        vinfo = getproperty(info.forcing.variables, v)
        if !doOnePath
            dataPath = vinfo.dataPath
            #ds = Dataset(dataPath)
        end
        srcVar = vinfo.sourceVariableName
        ds = NetCDF.ncread(dataPath, srcVar)

        tarVar = Symbol(v)
        ds_dat = ds[:, :, :]
        data_to_push = clean_inputs.(ds_dat, Ref(vinfo), Val{info.tem.helpers.numbers.numType}())[1, 1, :]
        if vinfo.spaceTimeType == "normal"
            push!(varlist, tarVar)
            push!(dataAr, data_to_push)
        else
            push!(varlist, tarVar)
            push!(dataAr, fill(data_to_push, 14245))
        end
    end
    println("forcing is still replicating the static variables 14245 times. Needs refinement and automation.")
    forcing = Table((; zip(varlist, dataAr)...))
    return forcing
end

function getForcing(info, ::Val{:yaxarray})
    file = joinpath(info.sinbad_root, info.forcing.oneDataPath)
    forcing_variables = keys(info.forcing.variables)
    nc = NetCDF.open(file)
    incubes = map(forcing_variables) do k
        v = nc[info.forcing.variables[k].sourceVariableName]
        atts = v.atts
        if any(in(keys(atts)), ["missing_value", "scale_factor", "add_offset"])
            v = CFDiskArray(v, atts)
        end
        ax = map(v.dim) do d
            dn = d.name
            dv = nc[dn][:]
            RangeAxis(dn, dv)
        end
        yax = YAXArray(ax, v)
        vinfo = info.forcing.variables[k]
        numtype = Val{info.tem.helpers.numbers.numType}()
        map(v -> Sinbad.clean_inputs(v, vinfo, numtype), yax)
    end
    indims = getInDims.(incubes)
    nts = getnts(incubes)
    forcing_variables = keys(info.forcing.variables)
    return (; data=incubes, dims=indims, n_timesteps=nts, variables = forcing_variables)
end
function getInDims(c)
    inax = String[]
    YAXArrays.Axes.findAxis("Time", c) === nothing || push!(inax, "Time")
    #Look for remaining axes
    islonlattime(n) = lowercase(n[1:min(3, length(n))]) in ("lon", "lat", "tim")
    axnames = YAXArrays.Axes.axname.(caxes(c))
    inollt = findall(!islonlattime, axnames)
    !isempty(inollt) && append!(inax, axnames[inollt])
    InDims(inax...; artype=KeyedArray, filter=AllNaN())
end

function getnts(incubes)
    i1 = findfirst(c -> YAXArrays.Axes.findAxis("Time", c) !== nothing, incubes)
    length(getAxis("Time", incubes[i1]).values)
end