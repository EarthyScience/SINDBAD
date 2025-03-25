export setOrderedSelectedModels
export setSpinupAndForwardModels

"""
    changeModelOrder(info::NamedTuple, selected_models::AbstractArray)

Reorders the list of models based on the order specified in the `model_structure.json` file.

# Arguments:
- `info`: A NamedTuple containing the experiment configuration.
- `selected_models`: An array of selected models to reorder.

# Returns:
- A reordered list of models based on the specified order.

# Notes:
- USE WITH EXTREME CAUTION AS CHANGING ORDER MAY RESULT IN MODEL INCONSISTENCY
- The default order is taken from `standard_sindbad_models`.
- Models cannot be set before `getPools` or after `cCycle`.
- Changing the order may result in model inconsistency, so use with caution.
- Issues warnings if the model order is changed or duplicates are found in the order.
"""
function changeModelOrder(info::NamedTuple, selected_models::AbstractArray; sindbad_models=standard_sindbad_models::Tuple)
    sindbad_models = [sindbad_models...]
    checkSelectedModels(sindbad_models, selected_models)
    # get orders of fixed models that cannot be changed
    order_getPools = findfirst(e -> e == :getPools, sindbad_models)
    order_cCycle = findfirst(e -> e == :cCycle, sindbad_models)

    # get the new orders and models from model_structure.json
    new_orders = Int64[]
    new_models = (;)
    order_changed_warn = true
    for sm ∈ selected_models
        model_info = getfield(info.settings.model_structure.models, sm)
        if :order in propertynames(model_info)
            push!(new_orders, model_info.order)
            new_models = setTupleField(new_models, (sm, model_info.order))
            if model_info.order <= order_getPools
                error(
                    "The model order for $(sm) is set at $(model_info.order). Any order earlier than or same as getPools ($order_getPools) is not permitted."
                )
            end
            if model_info.order >= order_cCycle
                error(
                    "The model order for $(sm) is set at $(model_info.order). Any order later than or same as cCycle ($order_cCycle) is not permitted."
                )
            end
            if order_changed_warn
                @warn "changeModelOrder:: Model order has been changed through model_structure.json. Make sure that model structure is consistent by accessing the model list in info.models.selected_models and comparing it with standard_sindbad_models"
                order_changed_warn = false
            end
            @warn "$(sm) [$(Pair(findfirst(e->e==sm, sindbad_models), model_info.order))]"
        end
    end

    #check for duplicates in the order
    if length(new_orders) != length(unique(new_orders))
        nun = nonUnique(new_orders)
        error(
            "There are duplicates in the order [$(nun)] set in model_structure.json. Cannot set the same order for different models."
        )
    end

    # sort the orders
    new_orders = sort(new_orders; rev=true)

    # create re-ordered list of full models
    full_models_reordered = deepcopy(sindbad_models)
    for new_order ∈ new_orders
        sm = nothing
        for nm ∈ keys(new_models)
            if getproperty(new_models, nm) == new_order
                sm = nm
            end
        end
        old_order = findfirst(e -> e == sm, full_models_reordered)
        # get the models without the model to be re-ordered
        tmp = filter!(e -> e ≠ sm, full_models_reordered)
        # insert the re-ordered model to the right place
        if old_order >= new_order
            insert!(tmp, new_order, sm)
        else
            insert!(tmp, new_order - 1, sm)
        end
        full_models_reordered = deepcopy(tmp)
    end
    return full_models_reordered
end

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
function getAllSindbadModels(info; all_models_default=standard_sindbad_models)
    sindbad_models = all_models_default
    @show propertynames(info.temp)
    if hasproperty(info.temp, :sindbad_models)
        sindbad_models = info.temp.sindbad_models
        @show "I am here...", sindbad_models
    end
    return sindbad_models
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
    all_sindbad_models_reordered = changeModelOrder(info, selected_models; sindbad_models=sindbad_models)
    checkSelectedModels(all_sindbad_models_reordered, selected_models)
    order_selected_models = []
    for msm ∈ all_sindbad_models_reordered
        if msm in selected_models
            push!(order_selected_models, msm)
        end
    end
    @debug "     setupInfo: creating initial out/land..."

    info = (; info..., temp=(; info.temp..., models=(; selected_models=Table((; model=[order_selected_models...])))))
    info = (; info..., temp=(; info.temp..., models=(; selected_models=Table((; model=[order_selected_models...])))))
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