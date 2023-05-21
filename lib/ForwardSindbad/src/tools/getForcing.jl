export getForcing

"""
    getVariableInfo(default_info, var_info)
combines the property values of the default forcing with the properties set for the particular variable
"""
function getVariableInfo(default_info::NamedTuple, var_info::NamedTuple)
    combined_info = (;)
    default_fields = propertynames(default_info)
    for var_field in default_fields
        if hasproperty(var_info, var_field)
            var_prop = getfield(var_info, var_field)
            # @show var_prop, var_info, var_field
            if !isnothing(var_prop) && length(var_prop) > 0
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
function getForcing(info::NamedTuple, ::Val{:table})
    doOnePath = false
    if !isnothing(info.forcing.defaultForcing.dataPath)
        doOnePath = true
        if isabspath(info.forcing.defaultForcing.dataPath)
            dataPath = info.forcing.defaultForcing.dataPath
        else
            dataPath = joinpath(info.experiment_root, info.forcing.defaultForcing.dataPath)
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

function get_forcing_sel_mask(mask_path::String)
    mask = NetCDF.open(mask_path)
    mask_data = mask["mask"]
    return mask_data
end

function getForcing(info::NamedTuple, ::Val{:yaxarray})
    doOnePath = false
    dataPath = info.forcing.defaultForcing.dataPath
    nc = Any
    if !isnothing(dataPath)
        doOnePath = true
        dataPath = getAbsDataPath(info, dataPath)
        @show dataPath
        nc = NetCDF.open(dataPath)
    end

    forcing_mask = nothing
    if :sel_mask ∈ keys(info.forcing)
        if !isnothing(info.forcing.sel_mask)
            mask_path = getAbsDataPath(info, info.forcing.sel_mask)
            forcing_mask = get_forcing_sel_mask(mask_path)
        end
    end

    default_info = info.forcing.defaultForcing
    forcing_variables = keys(info.forcing.variables)
    @info "getForcing: getting forcing variables..."
    incubes = map(forcing_variables) do k
        vinfo = getVariableInfo(default_info, info.forcing.variables[k])
        if !doOnePath
            dataPath = getAbsDataPath(info, getfield(vinfo, :dataPath))
            nc = NetCDF.open(dataPath)
        end
        v = nc[vinfo.sourceVariableName]
        atts = v.atts
        if any(in(keys(atts)), ["missing_value", "scale_factor", "add_offset"])
            v = CFDiskArray(v, atts)
        end
        ax = map(v.dim) do d
            dn = d.name
            if dn in keys(nc)
                dv = nc[dn][:]
            else
                dv=1:getfield(info.forcing.size, Symbol(dn))
            end
            RangeAxis(dn, dv)
        end
        if !isnothing(forcing_mask)
            v = v #todo: mask the forcing variables here depending on the mask of 1 and 0
        end
        @info "     $(k): source_var: $(vinfo.sourceVariableName), source_file: $(dataPath)"
        yax = YAXArray(ax, YAXArrayBase.NetCDFVariable{eltype(v),ndims(v)}(dataPath, vinfo.sourceVariableName, size(v)))
        #todo: slice the time series using dates in helpers
        # if hasproperty(yax,:time)
        #     yax = yax[time=info.tem.helpers.dates.vector]
        # end
        numtype = Val{info.tem.helpers.numbers.numType}()
        map(v -> cleanInputData(v, vinfo, numtype), yax)
    end
    @info "getForcing: getting forcing dimensions..."
    indims = getDataDims.(incubes, Ref(info.modelRun.mapping.yaxarray))
    @info "getForcing: getting number of time steps..."
    nts = getNumberOfTimeSteps(incubes, info.forcing.dimensions.time)
    @info "getForcing: getting variable names..."
    forcing_variables = keys(info.forcing.variables)
    println("----------------------------------------------")
    return (; data=incubes, dims=indims, n_timesteps=nts, variables=forcing_variables)
end


function getForcing(info::NamedTuple, ::Val{:zarr})
    doOnePath = false
    dataPath = info.forcing.defaultForcing.dataPath
    nc = Any
    if !isnothing(dataPath)
        doOnePath = true
        dataPath = getAbsDataPath(info, dataPath)
        @show dataPath
        nc = YAXArrays.open_dataset(zopen(dataPath))
    end

    forcing_mask = nothing
    if :sel_mask ∈ keys(info.forcing)
        if !isnothing(info.forcing.sel_mask)
            mask_path = getAbsDataPath(info, info.forcing.sel_mask)
            forcing_mask = get_forcing_sel_mask(mask_path)
        end
    end

    default_info = info.forcing.defaultForcing
    forcing_variables = keys(info.forcing.variables)
    @info "getForcing: getting forcing variables..."
    incubes = map(forcing_variables) do k
        vinfo = getVariableInfo(default_info, info.forcing.variables[k])
        if !doOnePath
            dataPath = getAbsDataPath(info, getfield(vinfo, :dataPath))
            nc = YAXArrays.open_dataset(zopen(dataPath))
        end
        dv = nc[vinfo.sourceVariableName]
        v = YAXArrayBase.yaxconvert(DimArray, dv) 
        # site, lon, lat should be options to consider here
        if !isnothing(forcing_mask)
            v = v #todo: mask the forcing variables here depending on the mask of 1 and 0
        end
        subset = v
        if !isnothing(info.forcing.size.site)
            subset = subset[site=1:info.forcing.size.site]
        end
        if !isnothing(info.forcing.size.time)
            subset = subset[time=1:info.forcing.size.time]
        end
        # subset = v[site=1:info.forcing.size.site, time = 1:info.forcing.size.time] # info.tem.helpers.dates.range

        @info "     $(k): source_var: $(vinfo.sourceVariableName), source_file: $(dataPath)"
        yax = YAXArrayBase.yaxconvert(YAXArray, Float64.(subset))
        #todo: slice the time series using dates in helpers
        # if hasproperty(yax,:time)
        #     yax = yax[time=info.tem.helpers.dates.vector]
        # end
        numtype = Val{info.tem.helpers.numbers.numType}()
        map(v -> cleanInputData(v, vinfo, numtype), yax)
    end
    @info "getForcing: getting forcing dimensions..."
    indims = getDataDims.(incubes, Ref(info.modelRun.mapping.yaxarray))
    @info "getForcing: getting number of time steps..."
    nts = length(incubes[1].time) # look for time instead of using the first yaxarray
    # nts = getNumberOfTimeSteps(incubes, info.forcing.dimensions.time)
    @info "getForcing: getting variable names..."
    forcing_variables = keys(info.forcing.variables)
    println("----------------------------------------------")
    return (; data=incubes, dims=indims, n_timesteps=nts, variables=forcing_variables)
end


function getForcing(info::NamedTuple, dpath, ::Val{:zarr})

    #dataPath = info.forcing.defaultForcing.dataPath
    ds = YAXArrays.open_dataset(zopen(dpath))
    forcing_variables = propertynames(info.forcing.variables)
    incubes = map(forcing_variables) do k
        dsk = ds[k]
        # flag to indicate if subsets are needed.
        dim = YAXArrayBase.yaxconvert(DimArray, dsk) 
        # site, lon, lat should be options to consider here
        subset = dim
        if !isnothing(info.forcing.size.site)
            subset = subset[site=1:info.forcing.size.site]
        end
        if !isnothing(info.forcing.size.time)
            subset = subset[time=1:info.forcing.size.time]
        end
        # support for subsets by name and numbers is also supported. Option to be added later.
        YAXArrayBase.yaxconvert(YAXArray, Float64.(subset))
    end
    nts = length(incubes[1].time) # look for time instead of using the first yaxarray
    indims = getDataDims.(incubes, Ref(info.modelRun.mapping.yaxarray))
    return (; data=incubes, dims=indims, n_timesteps=nts, variables=forcing_variables)
end