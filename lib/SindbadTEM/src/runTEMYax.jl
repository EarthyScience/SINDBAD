export runTEMYax
export TEMYax


"""
    coreTEMYax(selected_models, forcing, forcing_one_timestep, land_init, tem_helpers, tem_models, tem_spinup, ::DoSpinupTEM)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_models`: a NT with lists and information on selected forward and spinup SINDBAD models
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
"""
function coreTEMYax(selected_models, forcing, land_init, tem_helpers, tem_models, tem_spinup)

    forcing_one_timestep = getForcingForTimeStep(forcing, deepcopy(forcing), 1, tem_helpers.vals.forc_types)
    
    spinup_forcing = getAllSpinupForcing(forcing, tem_spinup.sequence, tem_helpers);

    land_prec = definePrecomputeTEM(selected_models, forcing_one_timestep, land_init, tem_helpers)

    land_spin = spinupTEM(selected_models, spinup_forcing, forcing_one_timestep, land_prec, tem_helpers, tem_spinup)

    land_time_series = timeLoopTEM(selected_models, forcing, forcing_one_timestep, land_spin, tem_helpers, tem_helpers.run.debug_model)

    return LandWrapper(land_time_series)
end


"""
    TEMYax(args; land_init::NamedTuple, tem::NamedTuple, selected_models::Tuple, forcing_variables::AbstractArray)



# Arguments:
- `args`: DESCRIPTION
- `land_init`: initial SINDBAD land with all fields and subfields
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing_variables`: DESCRIPTION
"""
function TEMYax(args...;selected_models::Tuple, forcing_variables::AbstractArray, land_init::NamedTuple, out_variables, tem::NamedTuple)
    outputs, inputs = unpackYaxForward(args; out_variables, forcing_variables)
    forcing = (; Pair.(forcing_variables, inputs)...)
    land_out = coreTEMYax(selected_models, forcing, land_init, tem.helpers, tem.models, tem.spinup)

    i = 1
    foreach(out_variables) do var_pair
        # @show i, var_pair
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
- `max_cache`: cache size to use for mapCube
"""
function runTEMYax(selected_models::Tuple, forcing::NamedTuple, info::NamedTuple)

    # forcing/input information
    incubes = forcing.data;
    indims = forcing.dims;
    forcing_variables = collect(forcing.variables);
    
    # information for running model
    run_helpers = prepTEM(forcing, info);
    outdims = run_helpers.out_dims;
    land_init = deepcopy(run_helpers.land_init);
    out_variables = valToSymbol(run_helpers.tem_with_types.helpers.vals.output_vars);
    outcubes = mapCube(TEMYax,
        (incubes...,);
        selected_models=selected_models,
        forcing_variables=forcing_variables,
        out_variables = out_variables,
        land_init=land_init,
        tem=run_helpers.tem_with_types,
        indims=indims,
        outdims=outdims,
        max_cache=info.experiment.exe_rules.yax_max_cache,
        ispar=true)
    return outcubes
end


"""
    unpackYaxForward(args; tem::NamedTuple, forcing_variables::AbstractArray)



# Arguments:
- `args`: DESCRIPTION
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `forcing_variables`: DESCRIPTION
"""
function unpackYaxForward(args; out_variables, forcing_variables)
    nin = length(forcing_variables)
    nout = length(out_variables)
    outputs = args[1:nout]
    inputs = args[(nout+1):(nout+nin)]
    return outputs, inputs
end



"""
    viewCopyYax(xout, xin)



# Arguments:
- `xout`: DESCRIPTION
- `xin`: DESCRIPTION
"""
function viewCopyYax(xout, xin)
    if ndims(xout) == ndims(xin)
        for i ∈ eachindex(xin)
            xout[i] = xin[i][1]
        end
    else
        for i ∈ CartesianIndices(xin)
            xout[:, i] .= xin[i]
        end
    end
end