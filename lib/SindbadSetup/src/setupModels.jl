export setOrderedSelectedModels
export setSpinupAndForwardModels

"""
    changeModelOrder(info::NamedTuple, selected_models::AbstractArray)

returns a list of models reordered according to orders provided in model_structure json.

- default order is taken from sindbad_models
- models cannot be set before getPools or after cCycle
- USE WITH EXTREME CAUTION AS CHANGING ORDER MAY RESULT IN MODEL INCONSISTENCY
"""
function changeModelOrder(info::NamedTuple, selected_models::AbstractArray)
    all_sindbad_models = [sindbad_models...]
    checkSelectedModels(all_sindbad_models, selected_models)
    # get orders of fixed models that cannot be changed
    order_getPools = findfirst(e -> e == :getPools, all_sindbad_models)
    order_cCycle = findfirst(e -> e == :cCycle, all_sindbad_models)

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
                @warn "changeModelOrder:: Model order has been changed through model_structure.json. Make sure that model structure is consistent by accessing the model list in info.temp.models.selected_models and comparing it with sindbad_models"
                order_changed_warn = false
            end
            @warn "$(sm) [$(Pair(findfirst(e->e==sm, all_sindbad_models), model_info.order))]"
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
    full_models_reordered = deepcopy(all_sindbad_models)
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
    checkSelectedModels(all_sindbad_models::AbstractArray, selected_models::AbstractArray)

checks if the list of selected models in model_structure.json are available in the full list of sindbad_models defined in models.jl
"""
function checkSelectedModels(all_sindbad_models, selected_models::AbstractArray)
    for sm ∈ selected_models
        if sm ∉ all_sindbad_models
            @show all_sindbad_models
            error(sm,
                " is not a valid model from all_sindbad_models [Sindbad.sindbad_models]. check model_structure settings in json")
            return false
        end
    end
    return true
end


"""
    setOrderedSelectedModels(info::NamedTuple)

gets the ordered list of selected models from info.settings.model_structure.models
- orders them as given in sindbad_models in models.jl.
- consistency check using checkSelectedModels for the existence of user-provided model.
"""
function setOrderedSelectedModels(info::NamedTuple)
    selected_models = collect(propertynames(info.settings.model_structure.models))
    all_sindbad_models_reordered = changeModelOrder(info, selected_models)
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

sets the spinup and forward subfields of info.temp.models to select a separated set of model for spinup and forward run.

  - allows for a faster spinup if some models can be turned off
  - relies on use_in_spinup flag in model_structure
  - by design, the spinup models should be subset of forward models
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
        selected_approach_func = getTypedModel(Symbol(selected_approach), info.temp.helpers.numbers.num_type)
        # selected_approach_func = getfield(Sindbad.Models, Symbol(selected_approach))()
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
    if hasproperty(info, :parameters) && !isempty(info.parameters)
        original_params_forward = getParameters(selected_approach_forward)
        input_params = info.parameters
        updated_params = setInputParameters(original_params_forward, input_params)
        selected_approach_forward = updateModelParameters(updated_params, selected_approach_forward)
    end
    info = (; info..., temp=(; info.temp..., models=(; info.temp.models..., forward=selected_approach_forward, is_spinup=is_spinup))) 
    return info
end