export runTEMYax
export TEMYax


"""
    coreTEMYax(selected_models, loc_forcing, loc_forcing_t, loc_land, tem_helpers, tem_spinup, ::DoSpinupTEM)



# Arguments:
- `selected_models`: a tuple of all models selected in the given model structure
- `loc_forcing`: a forcing NT that contains the forcing time series set for one location
- `loc_land`: initial SINDBAD land with all fields and subfields
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `tem_spinup`: a NT with information/instruction on spinning up the TEM
"""
function coreTEMYax(selected_models, loc_forcing, loc_land, tem_helpers, tem_spinup)

    loc_forcing_t = getForcingForTimeStep(loc_forcing, deepcopy(loc_forcing), 1, tem_helpers.vals.forcing_types)
    
    spinup_forcing = getAllSpinupForcing(loc_forcing, tem_spinup.sequence, tem_helpers);

    land_prec = definePrecomputeTEM(selected_models, loc_forcing_t, loc_land, tem_helpers)

    land_spin = spinupTEM(selected_models, spinup_forcing, loc_forcing_t, land_prec, tem_helpers, tem_spinup)

    land_time_series = timeLoopTEM(selected_models, loc_forcing, loc_forcing_t, land_spin, tem_helpers, tem_helpers.run.debug_model)

    return LandWrapper(land_time_series)
end


"""
    TEMYax(args; loc_land::NamedTuple, tem::NamedTuple, selected_models::Tuple, forcing_vars::AbstractArray)



# Arguments:
- `args`: DESCRIPTION
- `loc_land`: initial SINDBAD land with all fields and subfields
- `tem`: a nested NT with necessary information of helpers, models, and spinup needed to run SINDBAD TEM and models
- `selected_models`: a tuple of all models selected in the given model structure
- `forcing_vars`: DESCRIPTION
"""
function TEMYax(args...;selected_models::Tuple, forcing_vars::AbstractArray, loc_land::NamedTuple, output_vars, tem::NamedTuple)
    outputs, inputs = unpackYaxForward(args; output_vars, forcing_vars)
    loc_forcing = (; Pair.(forcing_vars, inputs)...)
    land_out = coreTEMYax(selected_models, loc_forcing, loc_land, tem.helpers, tem.spinup)

    i = 1
    foreach(output_vars) do var_pair
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
    
    # information for running model
    run_helpers = prepTEM(forcing, info);
    loc_land = deepcopy(run_helpers.loc_land);
    outcubes = mapCube(TEMYax,
        (incubes...,);
        selected_models=selected_models,
        forcing_vars=forcing.variables,
        output_vars = run_helpers.output_variables,
        loc_land=loc_land,
        tem=run_helpers.tem_with_types,
        indims=indims,
        outdims=run_helpers.output_dims,
        max_cache=info.experiment.exe_rules.yax_max_cache,
        ispar=true)
    return outcubes
end


"""
    unpackYaxForward(args; tem::NamedTuple, forcing_vars::AbstractArray)



# Arguments:
- `args`: DESCRIPTION
- `forcing_vars`: forcing variables
- `output_vars`: output variables
"""
function unpackYaxForward(args; output_vars, forcing_vars)
    nin = length(forcing_vars)
    nout = length(output_vars)
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