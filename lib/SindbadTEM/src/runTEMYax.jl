export runTEMYax


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
    selected_models::Tuple,
    forcing_variables::AbstractArray,
    forcing_one_timestep,
    land_init::NamedTuple,
    tem::NamedTuple,
    out_variables)
    outputs, inputs = unpackYaxForward(args; out_variables, forcing_variables)
    forcing = (; Pair.(forcing_variables, inputs)...)

    land_out = coreTEM(selected_models, forcing, forcing_one_timestep, land_init, tem.helpers, tem.models, tem.spinup, tem.helpers.run.spinup.spinup_TEM)

    i = 1
    foreach(out_variables) do var_pair
        data = land_out[first(var_pair)][last(var_pair)]
            viewCopyYax(outputs[i], data)
            i += 1
    end
end

"""
    runTEMYax(forcing::NamedTuple, output::NamedTuple, tem::NamedTuple, selected_models::Tuple; max_cache = 1.0e9)



# Arguments:
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `output`: an output NT including the data arrays, as well as information of variables and dimensions
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `selected_models`: a tuple of all models selected in the given model structure
- `max_cache`: DESCRIPTION
"""
function runTEMYax(
    selected_models::Tuple;
    forcing::NamedTuple,
    info::NamedTuple)

    # forcing/input information
    incubes = forcing.data
    indims = forcing.dims
    forcing_variables = collect(forcing.variables)

    # information for running model
    run_helpers = prepTEM(forcing, info)
    outdims = run_helpers.output.dims
    land_one = deepcopy(run_helpers.land_one)
    out_variables = valToSymbol(run_helpers.tem_with_types.helpers.vals.output_vars)
    #additionaldims = setdiff(keys(tem.helpers.run.loop),[:time])
    #nthreads = 1 ? !isempty(additionaldims) : Threads.nthreads()
    # @show "I am here"
    # @show indims
    # @show outdims
    outcubes = mapCube(TEMYax,
        (incubes...,);
        land_init=land_one,
        tem=run_helpers.tem_with_types,
        selected_models=selected_models,
        forcing_variables=forcing_variables,
        out_variables = out_variables,
        indims=indims,
        outdims=outdims,
        max_cache=info.experiment.exe_rules.yax_max_cache,
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
function unpackYaxForward(args; out_variables::NamedTuple, forcing_variables::AbstractArray)
    nin = length(forcing_variables)
    nout = length(out_variables)
    outputs = args[1:nout]
    inputs = args[(nout+1):(nout+nin)]
    return outputs, inputs
end