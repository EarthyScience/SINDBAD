export runTEMYAX


"""
    TEMYax(args; land_init::NamedTuple, tem::NamedTuple, selected_models::Tuple, forcing_variables::AbstractArray)



# Arguments:
- `args`: DESCRIPTION
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing_variables`: DESCRIPTION
"""
function TEMYax(args...;
    land_init::NamedTuple,
    tem::NamedTuple,
    selected_models::Tuple,
    forcing_variables::AbstractArray)
    outputs, inputs = unpackYaxForward(args; tem, forcing_variables)
    forcing = (; Pair.(forcing_variables, inputs)...)

    land_out = coreTEM(selected_models, forcing, forcing_one_timestep, land_init, tem.helpers, tem.models, tem.spinup, tem.helpers.run.spinup.spinup_TEM)

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
    runTEMYAX(forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, selected_models::Tuple; max_cache = 1.0e9)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `selected_models`: a tuple of all models selected in the given model structure
- `max_cache`: DESCRIPTION
"""
function runTEMYAX(forcing::NamedTuple,
    output::NamedTuple,
    tem::NamedTuple,
    selected_models::Tuple;
    max_cache=1e9)
    incubes = forcing.data
    indims = forcing.dims
    # innames = get_indim_symbiols
    forcing_variables = collect(forcing.variables)
    outdims = output.dims
    land_init = deepcopy(output.land_init)
    #additionaldims = setdiff(keys(tem.helpers.run.loop),[:time])
    #nthreads = 1 ? !isempty(additionaldims) : Threads.nthreads()
    # @show "I am here"
    # @show indims
    # @show outdims
    outcubes = mapCube(TEMYax,
        (incubes...,);
        land_init=land_init,
        tem=tem,
        selected_models=selected_models,
        forcing_variables=forcing_variables,
        indims=indims,
        outdims=outdims,
        max_cache=max_cache,
        ispar=false,
        #nthreads = [1],
    )
    return outcubes
end


"""
    unpackYaxForward(args; tem::NamedTuple, forcing_variables::AbstractArray)



# Arguments:
- `args`: DESCRIPTION
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `forcing_variables`: DESCRIPTION
"""
function unpackYaxForward(args; tem::NamedTuple, forcing_variables::AbstractArray)
    nin = length(forcing_variables)
    nout = sum(length, tem.variables)
    outputs = args[1:nout]
    inputs = args[(nout+1):(nout+nin)]
    return outputs, inputs
end