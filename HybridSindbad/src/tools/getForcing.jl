export getForcing

function getForcing(info::NamedTuple, ::Val{:zarr})
    dataPath = info.forcing.defaultForcing.dataPath
    ds = YAXArrays.open_dataset(dataPath)
    forcing_variables = propertynames(info.forcing.variables)
    incubes = map(forcing_variables) do k
        dsk = ds[k]
        # flag to indicate if subsets are needed.
        dim = YAXArrayBase.yaxconvert(DimArray, dsk) 
        # site, lon, lat should be options to consider here
        subset = dim[site=1:info.forcing.size.site, time = 1:info.forcing.size.time] # info.tem.helpers.dates.range
        # support for subsets by name and numbers is also supported. Option to be added later.
        YAXArrayBase.yaxconvert(YAXArray, subset)
    end
    nts = length(incubes[1].time) # look for time instead of using the first yaxarray
    indims = getDataDims.(incubes, Ref(info.modelRun.mapping.yaxarray))
    return (; data=incubes, dims=indims, n_timesteps=nts, variables=forcing_variables)
end