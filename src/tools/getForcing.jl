export getForcing

function cleanInputData(datapoint, vinfo, ::Val{T}) where {T}
    datapoint = applyUnitConversion(datapoint, vinfo.source2sindbadUnit, vinfo.additiveUnitConversion)
    bounds = vinfo.bounds
    datapoint = clamp(datapoint, bounds[1], bounds[2])
    return ismissing(datapoint) ? T(NaN) : T(datapoint)
end

"""
    getVariableInfo(default_info, var_info)
combines the property values of the default forcing with the properties set for the particular variable
"""
function getVariableInfo(default_info, var_info)
    combined_info = (;)
    default_fields = propertynames(default_info)
    for var_field in default_fields
        if hasproperty(var_info, var_field)
            var_prop = getfield(var_info, var_field)
            if !isempty(var_prop) || length(var_prop) > 0
                combined_info = setTupleField(combined_info, (var_field, getfield(var_info, var_field)))
            end
        else
            combined_info = setTupleField(combined_info, (var_field, getfield(default_info, var_field)))
        end
    end
    return combined_info
end

"""
getForcing(info)
"""
function getForcing(info, ::Val{:table})
    doOnePath = false
    if !isempty(info.forcing.defaultForcing.dataPath)
        doOnePath = true
        if isabspath(info.forcing.defaultForcing.dataPath)
            dataPath = info.forcing.defaultForcing.dataPath
        else
            dataPath = joinpath(info.Sindbad_root, info.forcing.defaultForcing.dataPath)
        end
    end
    varnames = propertynames(info.forcing.variables)
    varlist = []
    dataAr = []

    default_info = info.forcing.defaultForcing
    for v in varnames
        vinfo = getVariableInfo(default_info, getproperty(info.forcing.variables, v))
        if !doOnePath
            dataPath = vinfo.dataPath
            #ds = Dataset(dataPath)
        end
        srcVar = vinfo.sourceVariableName
        ds = NetCDF.ncread(dataPath, srcVar)

        tarVar = Symbol(v)
        ds_dat = ds[:, :, :]
        data_to_push = cleanInputData.(ds_dat, Ref(vinfo), Val{info.tem.helpers.numbers.numType}())[1, 1, :]
        if vinfo.spaceTimeType == "spatiotemporal"
            push!(varlist, tarVar)
            push!(dataAr, data_to_push)
        else
            push!(varlist, tarVar)
            push!(dataAr, fill(data_to_push, info.forcing.size.time))
        end
    end
    forcing = Table((; zip(varlist, dataAr)...))
    return forcing
end

function getForcing(info, ::Val{:yaxarray})
    doOnePath = false
    if !isempty(info.forcing.defaultForcing.dataPath)
        doOnePath = true
        if isabspath(info.forcing.defaultForcing.dataPath)
            dataPath = info.forcing.defaultForcing.dataPath
        else
            dataPath = joinpath(info.Sindbad_root, info.forcing.defaultForcing.dataPath)
        end
    end
    nc = Any
    if doOnePath
        file = joinpath(info.Sindbad_root, info.forcing.defaultForcing.dataPath)
        nc = NetCDF.open(file)
    end
    file = joinpath(info.Sindbad_root, info.forcing.defaultForcing.dataPath)
    default_info = info.forcing.defaultForcing
    forcing_variables = keys(info.forcing.variables)
    nc = NetCDF.open(file)
    incubes = map(forcing_variables) do k
        vinfo = getVariableInfo(default_info, info.forcing.variables[k])
        if !doOnePath
            file = joinpath(info.Sindbad_root, getfield(vinfo, :dataPath))
            nc = NetCDF.open(file)
        end
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
        numtype = Val{info.tem.helpers.numbers.numType}()
        map(v -> Sindbad.cleanInputData(v, vinfo, numtype), yax)
    end
    indims = getInDims.(incubes, Ref(info.modelRun.mapping.yaxarray))
    nts = getNumberOfTimeSteps(incubes, info.forcing.dimensions.time)
    forcing_variables = keys(info.forcing.variables)
    return (; data=incubes, dims=indims, n_timesteps=nts, variables = forcing_variables)
end

function getInDims(c,mappinginfo)
    inax = String[]
    axnames = YAXArrays.Axes.axname.(caxes(c))
    inollt = findall(∉(mappinginfo), axnames)
    !isempty(inollt) && append!(inax, axnames[inollt])
    InDims(inax...; artype=KeyedArray, filter=AllNaN())
end

function getNumberOfTimeSteps(incubes, time_name)
    i1 = findfirst(c -> YAXArrays.Axes.findAxis(time_name, c) !== nothing, incubes)
    length(getAxis(time_name, incubes[i1]).values)
end
