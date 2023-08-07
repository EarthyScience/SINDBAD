export mapRunEcosystem


"""
    doRunEcosystem(args; land_init::NamedTuple, tem::NamedTuple, forward_models::Tuple, forcing_variables::AbstractArray)

DOCSTRING

# Arguments:
- `args`: DESCRIPTION
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem`: DESCRIPTION
- `forward_models`: DESCRIPTION
- `forcing_variables`: DESCRIPTION
"""
function doRunEcosystem(args...;
    land_init::NamedTuple,
    tem::NamedTuple,
    forward_models::Tuple,
    forcing_variables::AbstractArray)
    #@show "doRun", Threads.threadid()
    outputs, inputs = unpackYaxForward(args; tem, forcing_variables)
    forcing = (; Pair.(forcing_variables, inputs)...)
    land_out = runEcosystem(forward_models, forcing, land_init, tem)
    i = 1
    tem_variables = tem.variables
    for group ∈ keys(tem_variables)
        data = land_out[group]
        for k ∈ tem_variables[group]
            viewCopyYax(outputs[i], data[k])
            i += 1
        end
    end
end

"""
    mapRunEcosystem(forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, forward_models::Tuple; max_cache = 1.0e9)

DOCSTRING

# Arguments:
- `forcing`: a forcing NT that contain the forcing time series set for ALL locations
- `output`: DESCRIPTION
- `tem`: DESCRIPTION
- `forward_models`: DESCRIPTION
- `max_cache`: DESCRIPTION
"""
function mapRunEcosystem(forcing::NamedTuple,
    output::NamedTuple,
    tem::NamedTuple,
    forward_models::Tuple;
    max_cache=1e9)
    incubes = forcing.data
    indims = forcing.dims
    forcing_variables = collect(forcing.variables)
    outdims = output.dims
    land_init = deepcopy(output.land_init)
    #additionaldims = setdiff(keys(tem.helpers.run.loop),[:time])
    #nthreads = 1 ? !isempty(additionaldims) : Threads.nthreads()

    outcubes = mapCube(doRunEcosystem,
        (incubes...,);
        land_init=land_init,
        tem=tem,
        forward_models=forward_models,
        forcing_variables=forcing_variables,
        indims=indims,
        outdims=outdims,
        max_cache=max_cache,
        ispar=true
        #nthreads = [1],
    )
    return outcubes
end


"""
    unpackYaxForward(args; tem::NamedTuple, forcing_variables::AbstractArray)

DOCSTRING

# Arguments:
- `args`: DESCRIPTION
- `tem`: DESCRIPTION
- `forcing_variables`: DESCRIPTION
"""
function unpackYaxForward(args; tem::NamedTuple, forcing_variables::AbstractArray)
    nin = length(forcing_variables)
    nout = sum(length, tem.variables)
    outputs = args[1:nout]
    inputs = args[(nout+1):(nout+nin)]
    return outputs, inputs
end