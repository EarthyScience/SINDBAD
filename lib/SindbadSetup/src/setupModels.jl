export setOrderedSelectedModels
export setSpinupAndForwardModels

"""
    checkSelectedModels(sindbad_models::AbstractArray, selected_models::AbstractArray)

Validates that the selected models in `model_structure.json` exist in the full list of `standard_sindbad_models`.

# Arguments:
- `sindbad_models`: An array of all available SINDBAD models.
- `selected_models`: An array of selected models to validate.

# Returns:
- `true` if all selected models are valid; otherwise, throws an error.

# Notes:
- Ensures that the selected models are consistent with the available SINDBAD models.
"""
function checkSelectedModels(sindbad_models, selected_models::AbstractArray)
    for sm ∈ selected_models
        if sm ∉ sindbad_models
            @show sindbad_models
            error(sm,
                " is not a valid model from sindbad_models [Sindbad.standard_sindbad_models]. check model_structure settings in json")
            return false
        end
    end
    return true
end

"""
    getAllSindbadModels(info; all_models_default=standard_sindbad_models)

Retrieves the list of all SINDBAD models, either from the provided `info` object or a default list.

# Arguments:
- `info`: A NamedTuple or object containing experiment configuration and metadata.
- `all_models_default`: (Optional) The default list of SINDBAD models to use if `info` does not specify a custom list. Defaults to `standard_sindbad_models`.

# Returns:
- A list of all SINDBAD models, either from `info.sindbad_models` (if available) or `all_models_default`.

# Notes:
- If the `info` object has a property `sindbad_models`, it overrides the default list.
- This function ensures flexibility by allowing custom model lists to be specified in the experiment configuration.
"""
function getAllSindbadModels(info; sindbad_models=standard_sindbad_models)
    if hasproperty(info.settings.model_structure, :sindbad_models)
        sindbad_models = info.settings.model_structure.sindbad_models
        @info "  Using non-standard model order and list from model_structure.sindbad_models. Check info.models.sindbad_models for the non-standard list."
    else
        @info "  Using standard model order and list from standard_sindbad_models. Check either info.models.sindbad_models or the variable standard_sindbad_models for the list."
    end
    return sindbad_models
end

"""
    getModelImplicitTRepeat(info::NamedTuple, selected_models)

Retrieves the `implicit_t_repeat` values for the specified models from the experiment configuration.

# Arguments:
- `info::NamedTuple`: A SINDBAD NamedTuple containing the experiment configuration, including model structure details.
- `selected_models`: A list of model names (symbols) for which the `implicit_t_repeat` values are to be retrieved.

# Returns:
- A vector of `implicit_t_repeat` values corresponding to the `selected_models`.

# Notes:
- If a model has an `implicit_t_repeat` property defined in its configuration, that value is used.
- If the property is not defined for a model, the default value from `info.settings.model_structure.default_model.implicit_t_repeat` is used.
"""
function getModelImplicitTRepeat(info::NamedTuple, selected_models)
    t_repeat = Int64[]
    for sm ∈ selected_models
        model_info = getfield(info.settings.model_structure.models, sm)
        if :implicit_t_repeat in propertynames(model_info)
            push!(t_repeat, model_info.implicit_t_repeat)
        else
            push!(t_repeat, info.settings.model_structure.default_model.implicit_t_repeat)
        end
    end
    return t_repeat
end


"""
    setOrderedSelectedModels(info::NamedTuple)

Retrieves and orders the list of selected models based on the configuration in `model_structure.json`.

# Arguments:
- `info`: A NamedTuple containing the experiment configuration.

# Returns:
- The updated `info` NamedTuple with the ordered list of selected models added to `info.temp.models`.

# Notes:
- Ensures consistency by validating the selected models using `checkSelectedModels`.
- Orders the models as specified in `standard_sindbad_models`.
"""
function setOrderedSelectedModels(info::NamedTuple)
    selected_models = collect(propertynames(info.settings.model_structure.models))
    sindbad_models = getAllSindbadModels(info)
    checkSelectedModels(sindbad_models, selected_models)
    t_repeat_models = getModelImplicitTRepeat(info, selected_models)
    checkSelectedModels(sindbad_models, selected_models)
    order_selected_models = []
    for msm ∈ sindbad_models
        if msm in selected_models
            push!(order_selected_models, msm)
        end
    end
    @debug "     setupInfo: creating initial out/land..."

    info = (; info..., temp=(; info.temp..., models=(; sindbad_models=sindbad_models, selected_models=Table((; model=[order_selected_models...],t_repeat=t_repeat_models)))))
    return info
end

"""
    setSpinupAndForwardModels(info::NamedTuple)

Configures the spinup and forward models for the experiment.

# Arguments:
- `info`: A NamedTuple containing the experiment configuration.

# Returns:
- The updated `info` NamedTuple with the spinup and forward models added to `info.temp.models`.

# Notes:
- Allows for faster spinup by turning off certain models using the `use_in_spinup` flag in `model_structure.json`.
- Ensures that spinup models are a subset of forward models.
- Updates model parameters if additional parameter values are provided in the experiment configuration.
"""
function setSpinupAndForwardModels(info::NamedTuple)
    selected_approach_forward = ()
    selected_approach_spinup = ()
    is_spinup = Int64[]
    order_selected_models = info.temp.models.selected_models.model
    default_model = getfield(info.settings.model_structure, :default_model)
    for sm ∈ order_selected_models
        model_info = getfield(info.settings.model_structure.models, sm)
        selected_approach = model_info.approach
        selected_approach = String(sm) * "_" * selected_approach
        selected_approach_func = getTypedModel(Symbol(selected_approach), info.temp.helpers.dates.temporal_resolution, info.temp.helpers.numbers.num_type)
        selected_approach_forward = (selected_approach_forward..., selected_approach_func)
        if :use_in_spinup in propertynames(model_info)
            use_in_spinup = model_info.use_in_spinup
        else
            use_in_spinup = default_model.use_in_spinup
        end
        if use_in_spinup == true
            push!(is_spinup, 1)
        else
            push!(is_spinup, 0)
        end
    end
    # change is_spinup to a vector of indices
    is_spinup = findall(is_spinup .== 1)

    # update the parameters of the approaches if a parameter value has been added from the experiment configuration
    if hasproperty(info[:settings], :parameters) && !isempty(info.settings.parameters)
        original_params_table = getParameters(selected_approach_forward, info.temp.helpers.numbers.num_type, info.temp.helpers.dates.temporal_resolution)
        input_params_table = info.settings.parameters
        updated_params_table = setInputParameters(original_params_table, input_params_table)
        selected_approach_forward = updateModelParameters(updated_params_table, selected_approach_forward, updated_params_table.optim)
    end
    info = (; info..., temp=(; info.temp..., models=(; info.temp.models..., forward=selected_approach_forward, is_spinup=is_spinup))) 
    return info
end