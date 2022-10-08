export getObservations

function getObservations(info::NamedTuple, ::Val{:zarr})
    dataPath = info.opti.constraints.oneDataPath
    ds = YAXArrays.open_dataset(dataPath)
    varnames = Symbol.(info.opti.variables2constrain)
    obscubes = map(varnames) do k
        dsk = ds[k]
        # flag to indicate if subsets are needed.
        dim = YAXArrayBase.yaxconvert(DimArray, dsk) 
        # site, lon, lat should be options to consider here
        subset = dim[site=1:info.forcing.size.site, time = 1:info.forcing.size.time]
        # support for subsets by name and numbers is also supported. Option to be added later.
        YAXArrayBase.yaxconvert(YAXArray, subset)
    end
    nts = length(obscubes[1].time) # look for time instead of using the first yaxarray
    indims = getDataDims.(obscubes, Ref(info.modelRun.mapping.yaxarray))
    return (; data=obscubes, dims=indims, n_timesteps=nts, variables=varnames)
end