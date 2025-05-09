export setupInfo
export createInitLand
export getSpinupSequenceWithTypes

"""
    createInitLand(pool_info, tem)

Initializes the land state by creating a NamedTuple with pools, states, and selected models.

# Arguments:
- `pool_info`: Information about the pools to initialize.
- `tem`: A helper NamedTuple with necessary objects for pools and numbers.

# Returns:
- A NamedTuple containing initialized pools, states, fluxes, diagnostics, properties, models, and constants.
"""
function createInitLand(pool_info, tem)
    @info "  createInitLand: creating Initial Land..."
    init_pools = createInitPools(pool_info, tem.helpers)
    initial_states = createInitStates(pool_info, tem.helpers)
    out = (; fluxes=(;), pools=(; init_pools..., initial_states...), states=(;), diagnostics=(;), properties=(;), models=(;), constants=(;))
    sortedModels = sort([_sm for _sm ∈ tem.models.selected_models.model])
    for model ∈ sortedModels
        out = setTupleField(out, (model, (;)))
    end
    return out
end

"""
    parseSaveCode(info)

Parses and saves the code and structs of the selected model structure for the given experiment.

# Arguments:
- `info`: The experiment configuration NamedTuple containing model and output information.

# Notes:
- Writes the `define`, `precompute`, and `compute` functions for the selected models to separate files.
- Also writes the parameter structs for the models.
"""
function parseSaveCode(info)
    @info "  parseSaveCode: saving Selected Models Code..."
    models = info.temp.models.forward
    outfile_define = joinpath(info.output.dirs.code, info.temp.experiment.basics.name * "_" * info.temp.experiment.basics.domain * "_model_definitions.jl")
    outfile_code = joinpath(info.output.dirs.code, info.temp.experiment.basics.name * "_" * info.temp.experiment.basics.domain * "_model_functions.jl")
    outfile_struct = joinpath(info.output.dirs.code, info.temp.experiment.basics.name * "_" * info.temp.experiment.basics.domain * "_model_structs.jl")
    fallback_code_define = nothing
    fallback_code_precompute = nothing
    fallback_code_compute = nothing

    # Write define functions
    open(outfile_define, "w") do o_file
        mod_string = "# Code for define functions (variable definition) in models of SINDBAD for $(info.settings.experiment.basics.name) experiment applied to $(info.settings.experiment.basics.domain) domain.\n"
        mod_string *= "# These functions are called just ONCE for variable/array definitions.\n"
        write(o_file, mod_string)
        mod_string = "# Based on @code_string from CodeTracking.jl. In case of conflicts, follow the original code in define functions of model approaches in src/Models/[model]/[approach].jl\n"
        write(o_file, mod_string)
        for (mi, _mod) in enumerate(models)
            mod_name = string(nameof(supertype(typeof(_mod))))
            appr_name = string(nameof(typeof(_mod)))
            mod_string = "\n# $appr_name\n"
            write(o_file, mod_string)
            mod_file = joinpath(info.temp.experiment.dirs.sindbad, "src/Models", mod_name, appr_name * ".jl")
            write(o_file, "# " * mod_file * "\n")
            mod_string = "# Call order: $mi\n\n"
            write(o_file, mod_string)

            mod_ending = "\n\n"
            if mi == lastindex(models)
                mod_ending = "\n"
            end
            mod_code = @code_string Models.define(_mod, nothing, nothing, nothing)
            if occursin("LandEcosystem", mod_code)
                if isnothing(fallback_code_define)
                    fallback_code_define = mod_code
                end
            else
                write(o_file, mod_code * mod_ending)
            end
            mod_string = "# --------------------------------------\n"
            write(o_file, mod_string)
        end
        mod_string = "\n# Fallback define function for LandEcosystem\n"
        write(o_file, mod_string)
        write(o_file, fallback_code_define)
    end

    # Write precompute and compute functions
    open(outfile_code, "w") do o_file
        mod_string = "# Code for precompute and compute functions in models of SINDBAD for $(info.settings.experiment.basics.name) experiment applied to $(info.settings.experiment.basics.domain) domain.\n"
        mod_string *= "# Precompute functions are called once outside the time loop per iteration in optimization, while compute functions are called every time step.\n"
        write(o_file, mod_string)
        mod_string = "# Based on @code_string from CodeTracking.jl. In case of conflicts, follow the original code in model approaches in src/Models/[model]/[approach].jl\n"
        write(o_file, mod_string)
        for (mi, _mod) in enumerate(models)
            mod_name = string(nameof(supertype(typeof(_mod))))
            appr_name = string(nameof(typeof(_mod)))
            mod_string = "\n# $appr_name\n"
            write(o_file, mod_string)
            mod_file = joinpath(info.temp.experiment.dirs.sindbad, "src/Models", mod_name, appr_name * ".jl")
            write(o_file, "# " * mod_file * "\n")
            mod_string = "# Call order: $mi\n\n"
            write(o_file, mod_string)

            mod_ending = "\n\n"

            mod_code = @code_string Models.precompute(_mod, nothing, nothing, nothing)

            if occursin("LandEcosystem", mod_code)
                if isnothing(fallback_code_precompute)
                    fallback_code_precompute = mod_code * "\n\n"
                end
            else
                write(o_file, mod_code * mod_ending)
            end

            mod_code = @code_string Models.compute(_mod, nothing, nothing, nothing)
            if occursin("LandEcosystem", mod_code)
                if isnothing(fallback_code_compute)
                    fallback_code_compute = mod_code
                end
            else
                write(o_file, mod_code * mod_ending)
            end
            mod_string = "# --------------------------------------\n"
            write(o_file, mod_string)
        end
        mod_string = "\n# Fallback precompute and compute functions for LandEcosystem\n"
        write(o_file, mod_string)
        write(o_file, fallback_code_precompute)
        write(o_file, fallback_code_compute)
    end

    # Write structs
    open(outfile_struct, "w") do o_file
        mod_string = "# Code for parameter structs of SINDBAD for $(info.settings.experiment.basics.name) experiment applied to $(info.settings.experiment.basics.domain) domain.\n"
        mod_string *= "# Based on @code_expr from CodeTracking.jl. In case of conflicts, follow the original code in model approaches in src/Models/[model]/[approach].jl\n\n"
        write(o_file, mod_string)
        write(o_file, "abstract type LandEcosystem end\n")

        for (mi, _mod) in enumerate(models)
            mod_name = string(nameof(supertype(typeof(_mod))))
            appr_name = string(nameof(typeof(_mod)))
            mod_file = joinpath(info.temp.experiment.dirs.sindbad, "src/Models", mod_name, appr_name * ".jl")
            mod_string = "\n# $appr_name\n"
            write(o_file, mod_string)
            write(o_file, "# " * mod_file * "\n")
            mod_string = "# Call order: $mi\n\n"
            write(o_file, mod_string)

            write(o_file, "abstract type $mod_name <: LandEcosystem end\n\n")

            mod_string = string(@code_expr typeof(_mod)())
            for xx = 1:100
                if occursin(mod_file, mod_string)
                    mod_string = replace(mod_string, "#= $(mod_file):$(xx) =#\n" => "")
                    mod_string = replace(mod_string, "#= $(mod_file):$(xx) =#" => "")
                end
            end
            mod_string = replace(mod_string, " @bounds " => "@bounds")
            mod_string = replace(mod_string, "@describe(" => "@describe")
            mod_string = replace(mod_string, "@units(" => "@units")
            mod_string = replace(mod_string, "@timescale(" => "@timescale")
            mod_string = replace(mod_string, "@with_kw(" => "@with_kw ")
            mod_string = replace(mod_string, "                    end))))" => "end")
            mod_string = replace(mod_string, "                end))))" => "end")
            mod_string = replace(mod_string, "\n    end" => " end")
            mod_string = replace(mod_string, "                                                " => "    ")
            mod_string = replace(mod_string, " = (((" => " = ")
            mod_string = replace(mod_string, ") |" => " |")
            mod_string = replace(mod_string, "] |" => "]) |")
            write(o_file, mod_string * "\n\n")
            mod_string = "# --------------------------------------\n"
            if mi == lastindex(models)
                mod_string = "# --------------------------------------"
            end
            write(o_file, mod_string)
        end
    end

    return nothing
end


"""
    setDatesInfo(info::NamedTuple)

Fills `info.temp.helpers.dates` with date and time-related fields needed in the models.

# Arguments:
- `info`: A NamedTuple containing the experiment configuration.

# Returns:
- The updated `info` NamedTuple with date-related fields added.
"""
function setDatesInfo(info::NamedTuple)
    @info "  setDatesInfo: setting Dates Helpers..."
    tmp_dates = (;)
    time_info = getfield(info.settings.experiment.basics, :time)
    time_props = propertynames(time_info)
    for time_prop ∈ time_props
        prop_val = getfield(time_info, time_prop)
        if prop_val isa Number
            prop_val = info.temp.helpers.numbers.num_type(prop_val)
        end
        tmp_dates = setTupleField(tmp_dates, (time_prop, prop_val))
    end
    timestep = getfield(Dates, Symbol(titlecase(info.settings.experiment.basics.time.temporal_resolution)))(1)
    time_range = DateTime(info.settings.experiment.basics.time.date_begin):timestep:DateTime(info.settings.experiment.basics.time.date_end)
    tmp_dates = setTupleField(tmp_dates, (:temporal_resolution, info.settings.experiment.basics.time.temporal_resolution))
    tmp_dates = setTupleField(tmp_dates, (:timestep, timestep))
    tmp_dates = setTupleField(tmp_dates, (:range, time_range))
    tmp_dates = setTupleField(tmp_dates, (:size, length(time_range)))
    info = (; info..., temp=(; info.temp..., helpers=(; info.temp.helpers..., dates=tmp_dates)))
    return info
end


"""
    setModelRunInfo(info::NamedTuple)

Sets up model run flags and output array types for the experiment.

# Arguments:
- `info`: A NamedTuple containing the experiment configuration.

# Returns:
- The updated `info` NamedTuple with model run flags and output array types added.
"""
function setModelRunInfo(info::NamedTuple)
    @info "  setModelRunInfo: setting Model Run Flags..."
    if info.settings.experiment.flags.run_optimization
        info = @set info.settings.experiment.flags.catch_model_errors = false
    end
    run_vals = convertRunFlagsToTypes(info)
    output_array_type = getfield(SindbadSetup, toUpperCaseFirst(info.settings.experiment.model_output.output_array_type, "Output"))()
    run_info = (; run_vals..., output_array_type = output_array_type)
    run_info = setTupleField(run_info, (:save_single_file, getTypeInstanceForFlags(:save_single_file, info.settings.experiment.model_output.save_single_file, "Do")))
    run_info = setTupleField(run_info, (:use_forward_diff, run_vals.use_forward_diff))
    run_info = setTupleField(run_info, (:input_data_backend, info.settings.experiment.exe_rules.input_data_backend))
    run_info = setTupleField(run_info, (:input_array_type, info.settings.experiment.exe_rules.input_array_type))

    parallelization = titlecase(info.settings.experiment.exe_rules.parallelization)
    run_info = setTupleField(run_info, (:parallelization, getfield(SindbadSetup, Symbol(parallelization*"Parallelization"))()))
    land_output_type = getfield(SindbadSetup, toUpperCaseFirst(info.settings.experiment.exe_rules.land_output_type, "PreAlloc"))()
    run_info = setTupleField(run_info, (:land_output_type, land_output_type))
    info = (; info..., temp=(; info.temp..., helpers=(; info.temp.helpers..., run=run_info)))
    return info
end

"""
    setNumericHelpers(info::NamedTuple, ttype)

Prepares numeric helpers for maintaining consistent data types across models.

# Arguments:
- `info`: A NamedTuple containing the experiment configuration.
- `ttype`: The numeric type to use (default: `info.settings.experiment.exe_rules.model_number_type`).

# Returns:
- The updated `info` NamedTuple with numeric helpers added.
"""
function setNumericHelpers(info::NamedTuple, ttype=info.settings.experiment.exe_rules.model_number_type)
    @info "  setNumericHelpers: setting Numeric Helpers..."
    num_type = getNumberType(ttype)

    tolerance = num_type(info.settings.experiment.exe_rules.tolerance)
    num_helpers = (; tolerance=tolerance, num_type=num_type)
    info = (; info..., temp=(; info.temp..., helpers=(; numbers=num_helpers)))
    return info
end


"""
    setRestartFilePath(info::NamedTuple)

Validates and sets the absolute path for the restart file used in spinup.

# Arguments:
- `info`: A NamedTuple containing the experiment configuration.

# Returns:
- The updated `info` NamedTuple with the absolute restart file path set.
"""
function setRestartFilePath(info::NamedTuple)
    restart_file_in = info.settings.experiment.model_spinup.restart_file
    restart_file = nothing

    if !isnothing(restart_file_in)
        if restart_file_in[(end-4):end] != ".jld2"
            error(
                "info.settings.experiment.model_spinup.restartFile has a file ending other than .jld2. Only jld2 files are supported for loading spinup. Either give a correct file or set info.settings.experiment.flags.load_spinup to false."
            )
        end
        if isabspath(restart_file_in)
            restart_file = restart_file_in
        else
            restart_file = joinpath(info.temp.experiment.dirs.experiment, restart_file_in)
        end
        info = @set info.settings.experiment.model_spinup.restart_file = restart_file
    end
    return info
end

"""
    getSpinupSequenceWithTypes(seqq, helpers_dates)

Processes the spinup sequence and assigns types for temporal aggregators for spinup forcing.

# Arguments:
- `seqq`: The spinup sequence from the experiment configuration.
- `helpers_dates`: A NamedTuple containing date-related helpers.

# Returns:
- A processed spinup sequence with forcing types for temporal aggregators.
"""
function getSpinupSequenceWithTypes(seqq, helpers_dates)
    seqq_typed = []
    for seq in seqq
        for kk in keys(seq)
            if kk == "forcing"
                skip_aggregation = false
                if startswith(kk, helpers_dates.temporal_resolution)
                    skip_aggregation = true
                end
                aggregator = createTimeAggregator(helpers_dates.range, seq[kk], mean, skip_aggregation)
                seq["aggregator"] = aggregator
                seq["aggregator_type"] = TimeNoDiff()
                seq["aggregator_indices"] = [_ind for _ind in vcat(aggregator[1].indices...)]
                seq["n_timesteps"] = length(aggregator[1].indices)
                if occursin("_year", seq[kk])
                    seq["aggregator_type"] = TimeIndexed()
                    seq["n_timesteps"] = length(seq["aggregator_indices"])
                end
            end
            if kk == "spinup_mode"
                seq[kk] = getTypeInstanceForNamedOptions(seq[kk])
            end
            if seq[kk] isa String
                seq[kk] = Symbol(seq[kk])
            end
        end
        optns = in(seq, "options") ? seqp["options"] : (;)
        sst = SpinupSequenceWithAggregator(seq["forcing"], seq["n_repeat"], seq["n_timesteps"], seq["spinup_mode"], optns, seq["aggregator_indices"], seq["aggregator"], seq["aggregator_type"]);
        push!(seqq_typed, sst)
    end
    return seqq_typed
end

"""
    setSpinupInfo(info::NamedTuple)

Processes the spinup configuration and prepares the spinup sequence.

# Arguments:
- `info`: A NamedTuple containing the experiment configuration.

# Returns:
- The updated `info` NamedTuple with spinup-related fields added.
"""
function setSpinupInfo(info)
    @info "  setSpinupInfo: setting Spinup Info..."
    info = setRestartFilePath(info)
    infospin = info.settings.experiment.model_spinup
    # change spinup sequence dispatch variables to Val, get the temporal aggregators
    seqq = infospin.sequence
    seqq_typed = getSpinupSequenceWithTypes(seqq, info.temp.helpers.dates)
    infospin = setTupleField(infospin, (:sequence, [_s for _s in seqq_typed]))
    info = setTupleSubfield(info, :temp, (:spinup, infospin))
    return info
end


"""
    setExperimentBasics(info::NamedTuple)

Copies basic experiment information into the temporary experiment configuration.

# Arguments:
- `info`: A NamedTuple containing the experiment configuration.

# Returns:
- The updated `info` NamedTuple with basic experiment information added.
"""
function setExperimentBasics(info)
    @info "  setExperimentBasics: setting Basic Experiment Info..."
    ex_basics = info.settings.experiment.basics
    ex_basics_sel = (;)
    for k in propertynames(ex_basics)
        if k !== :config_files
            if k == :time
                ex_basics_sel = setTupleField(ex_basics_sel, (:temporal_resolution, getfield(ex_basics[:time], :temporal_resolution)))
            else
                ex_basics_sel = setTupleField(ex_basics_sel, (k, getfield(ex_basics, k)))
            end 
        end
    end
    info = (; info..., temp=(; info.temp..., experiment=(; info.temp.experiment..., basics=ex_basics_sel)))
    return info
end

"""
    setupInfo(info::NamedTuple)

Processes the experiment configuration and sets up all necessary fields for model simulation.

# Arguments:
- `info`: A NamedTuple containing the experiment configuration.

# Returns:
- The updated `info` NamedTuple with all necessary fields for model simulation.
"""
function setupInfo(info::NamedTuple)
    @info "setupInfo: Setting and consolidating Experiment Info..."
    # @show info.settings.model_structure.parameter_table.optimized
    info = setExperimentBasics(info)
    # @info "  setupInfo: setting Output Basics..."
    info = setExperimentOutput(info)
    # @info "  setupInfo: setting Numeric Helpers..."
    info = setNumericHelpers(info)
    # @info "  setupInfo: setting Pools Info..."
    info = setPoolsInfo(info)
    # @info "  setupInfo: setting Dates Helpers..."
    info = setDatesInfo(info)
    # @info "  setupInfo: setting Model Structure..."
    info = setOrderedSelectedModels(info)
    # @info "  setupInfo: setting Spinup and Forward Models..."
    info = setSpinupAndForwardModels(info)

    # @info "  setupInfo:         ...saving Selected Models Code..."
    _ = parseSaveCode(info)

    # add information related to model run
    # @info "  setupInfo: setting Model Run Flags..."
    info = setModelRunInfo(info)
    # @info "  setupInfo: setting Spinup Info..."
    info = setSpinupInfo(info)

    # @info "  setupInfo: setting Model Output Info..."
    info = setModelOutput(info)

    # @info "  setupInfo: creating Initial Land..."
    land_init = createInitLand(info.pools, info.temp)
    info = (; info..., temp=(; info.temp..., helpers=(; info.temp.helpers..., land_init=land_init)))

    if (info.settings.experiment.flags.run_optimization || info.settings.experiment.flags.calc_cost) && hasproperty(info.settings.optimization, :algorithm_optimization)
        # @info "  setupInfo: setting Optimization and Observation info..."
        info = setOptimization(info)
    else
        parameter_table = info.temp.models.parameter_table
        checkParameterBounds(parameter_table.name, parameter_table.initial, parameter_table.lower, parameter_table.upper, ScaleNone(), show_info=true, model_names=parameter_table.model_approach)
     end

    if !isnothing(info.settings.experiment.exe_rules.longtuple_size)
        selected_approach_forward = makeLongTuple(info.temp.models.forward, info.settings.experiment.exe_rules.longtuple_size)
        info = @set info.temp.models.forward = selected_approach_forward
    end

    @info "  setupInfo: Cleaning Info Fields..."
    data_settings = (; forcing = info.settings.forcing, optimization = info.settings.optimization)
    exe_rules = info.settings.experiment.exe_rules
    info = dropFields(info, (:model_structure, :experiment, :output, :pools))
    info = (; info..., info.temp...)
    info = setTupleSubfield(info, :experiment, (:data_settings, data_settings))
    info = setTupleSubfield(info, :experiment, (:exe_rules, exe_rules))
    info = dropFields(info, (:temp, :settings,))
    return info
end

