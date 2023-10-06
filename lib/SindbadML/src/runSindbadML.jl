export gradientSite
export gradientBatch!
export getLossForSites
export lossSite
export trainSindbadML


function getCacheFromOutput(loc_output, ::ForwardDiffGrad)
    return DiffCache.(loc_output)
end

function getCacheFromOutput(loc_output, ::FiniteDiffGrad)
    return loc_output
end

function getCacheFromOutput(loc_output, ::FiniteDifferencesGrad)
    return loc_output
end


function getLoss(models, loc_forcing, loc_spinup_forcing, forcing_one_timestep, loc_output, land_init, tem, loc_obs, cost_options, constraint_method; show_vec=false)
    coreTEM!(
        models,
        loc_forcing,
        loc_spinup_forcing,
        forcing_one_timestep,
        loc_output,
        land_init,
        tem...)
    lossVec = getLossVector(loc_output, loc_obs, cost_options)
    t_loss = combineLoss(lossVec, constraint_method)
    if show_vec
        println("   loss_vector: ", Tuple([Pair.(string.(cost_options.variable), lossVec)...]) )
    end
    return t_loss
end


function getLossForSites(gradient_lib, loss_function::F, loss_array_sites, epoch_number,
    scaled_params, models, sites_list, indices_sites, loc_forcings, loc_spinup_forcings,
    forcing_one_timestep, loc_outputs, land_one, loc_observations, tem, param_to_index,
    cost_options, constraint_method; logging=true) where {F}

    # p = Progress(size(loss_array_sites,1); desc="Computing batch grads...", color=:yellow, enabled=logging)
    @sync begin
        for idx ∈ eachindex(indices_sites)
           Threads.@spawn begin
                site_location = indices_sites[idx]
                site_name = sites_list[idx]
                loc_params = scaled_params(site=site_name)
                loc_forcing = loc_forcings[site_location]
                loc_obs = loc_observations[site_location]
                loc_output = loc_outputs[site_location]
                loc_spinup_forcing = loc_spinup_forcings[site_location]
                loc_cost_option = cost_options[site_location]

                gg = loss_function(
                    loc_params, gradient_lib, models, loc_forcing, loc_spinup_forcing, forcing_one_timestep, loc_output, deepcopy(land_one), tem, param_to_index, loc_obs, loc_cost_option, constraint_method)
                loss_array_sites[idx, epoch_number] = gg
                # next!(p)
           end
       end
    end
end


function getOutputFromCache(loc_output, _, ::FiniteDiffGrad)
    return loc_output
end

function getOutputFromCache(loc_output, _, ::FiniteDifferencesGrad)
    return loc_output
end

function getOutputFromCache(loc_output, new_params, ::ForwardDiffGrad)
    return get_tmp.(loc_output, (new_params,))
end


"""
    gradientSite(gradient_lib::ForwardDiffGrad, loss_function::F, vals::AbstractArray, args...

Wraps a multi-input argument function to be used by ForwardDiff.

    - gradient_lib: the package/library to use for calculating gradient
    - loss_function: The loss function to be used by ForwardDiff
    - vals: Gradient evaluation `values`
    - kwargs: keyword arguments needed by the loss_function
"""
function gradientSite(gradient_lib::ForwardDiffGrad, loss_function::F, vals::AbstractArray, args...) where {F}
    loss_tmp(x) = loss_function(x, gradient_lib, args...)
    return ForwardDiff.gradient(loss_tmp, vals)#::Vector{Float32}
end

function gradientSite(gradient_lib::FiniteDiffGrad, loss_function::F, vals::AbstractArray, args...) where {F}
    loss_tmp(x) = loss_function(x, gradient_lib, args...)
    return FiniteDiff.finite_difference_gradient(loss_tmp, vals)
end

function gradientSite(gradient_lib::FiniteDifferencesGrad, loss_function::F, vals::AbstractArray, args...) where {F}
    loss_tmp(x) = loss_function(x, gradient_lib, args...)
    return FiniteDifferences.grad(FiniteDifferences.central_fdm(5, 1), loss_tmp, vals.data.data)
end

function gradientBatch!(gradient_lib, loss_function::F, grads_batch, scaled_params_batch,
    models, sites_batch, indices_batch, loc_forcings, loc_spinup_forcings, forcing_one_timestep,
    loc_outputs, land_one, loc_observations, tem, param_to_index, cost_options,
    constraint_method; logging=true) where {F}
    # Threads.@spawn allows dynamic scheduling instead of static scheduling
    # of Threads.@threads macro.
    # See <https://github.com/JuliaLang/julia/issues/21017>

    p = Progress(length(sites_batch); desc="Computing batch grads...", color=:yellow, enabled=logging)
    @sync begin
        for idx ∈ eachindex(indices_batch)
            Threads.@spawn begin
                site_location = indices_batch[idx]
                site_name = sites_batch[idx]
                loc_params = scaled_params_batch(site=site_name).data.data
                loc_forcing = loc_forcings[site_location]
                loc_obs = loc_observations[site_location]
                loc_output = loc_outputs[site_location]
                loc_spinup_forcing = loc_spinup_forcings[site_location]
                loc_cost_option = cost_options[site_location]
                gg = gradientSite(gradient_lib, loss_function, loc_params, models, loc_forcing,
                loc_spinup_forcing, forcing_one_timestep, getCacheFromOutput(loc_output,
                gradient_lib), deepcopy(land_one), tem, param_to_index, loc_obs,
                loc_cost_option, constraint_method)
                grads_batch[:, idx] = gg
                next!(p)
           end
        end
    end
end


function lossSite(new_params, gradient_lib, models, loc_forcing, loc_spinup_forcing, 
    forcing_one_timestep, loc_output, land_init, tem, param_to_index, loc_obs, cost_options,
    constraint_method; show_vec=false)
    out_data = getOutputFromCache(loc_output, new_params, gradient_lib)
    new_models = updateModelParameters(param_to_index, models, new_params)
    return getLoss(new_models, loc_forcing, loc_spinup_forcing, forcing_one_timestep, out_data, land_init, tem, loc_obs, cost_options, constraint_method; show_vec=show_vec)
end


function trainSindbadML(gradient_lib, nn_model_params::Flux.Chain, loss_function::F, xfeatures,
    models_lt, sites_training, indices_sites_training, loc_forcings, loc_spinup_forcings,
    forcing_one_timestep, loc_outputs, land_init, loc_observations, tbl_params, tem,
    param_to_index, cost_options, constraint_method; n_epochs=2, optimizer=Optimisers.Adam(),
    batch_seed=123, batch_size=4, shuffle=true, local_root=nothing, name="seq_training_output",
    save_batch=false, save_epoch=true) where {F}

    local_root = isnothing(local_root) ? dirname(Base.active_project()) : local_root
    f_path = joinpath(local_root, name)
    mkpath(f_path)
#
    flat, re, opt_state = destructureNN(nn_model_params; nn_opt=optimizer)
    n_params = length(nn_model_params[end].bias)

    sites_batches = shuffleBatches(sites_training, batch_size; seed=batch_seed)
    indices_sites_batches = shuffleBatches(indices_sites_training, batch_size; seed=batch_seed)
    grads_batch = zeros(Float32, n_params, batch_size)

    loss_array_sites = fill(zero(Float32), length(sites_training), n_epochs)

    p = Progress(n_epochs; desc="Computing epochs...")


    for epoch ∈ 1:n_epochs
        sites_batches = shuffle ? shuffleBatches(sites_training, batch_size; seed=epoch + batch_seed) : sites_batches
        indices_sites_batches = shuffle ? shuffleBatches(indices_sites_training, batch_size; seed=epoch + batch_seed) : indices_sites_batches
        batch_id = 1
        grads_all_batches = map(sites_batches, indices_sites_batches) do sites_batch, indices_batch
            x_feature_batch = xfeatures(; site=sites_batch)
            new_params, pullback_func = Zygote.pullback(p -> re(p)(x_feature_batch), flat)            
            scaled_params_batch = getParamsAct(new_params, tbl_params)
            grads_batch .= zero(Float32)
            
            gradientBatch!(gradient_lib, loss_function, grads_batch, scaled_params_batch, models_lt, sites_batch, indices_batch, loc_forcings, loc_spinup_forcings,
            forcing_one_timestep, loc_outputs, land_init, loc_observations, tem, param_to_index, cost_options, constraint_method; logging=true)

            num_nans = sum(isnan.(grads_batch))
            if num_nans > 0
                @warn ":::nan in grads:::"
                foreach(findall(x->isnan(x), grads_batch)) do ci
                    si = ci[2]
                    sii = indices_batch[si]
                    site_name_tmp = sites_batch[si]
                    p_vec_tmp = scaled_params_batch(site=site_name_tmp)
                    p_index_tmp = ci[1]
                    println("   site: ", site_name_tmp)
                    println("   parameter: ", Pair(tbl_params.name[p_index_tmp], (p_vec_tmp[p_index_tmp], tbl_params.lower[p_index_tmp], tbl_params.upper[p_index_tmp])))
                    println("   parameter_vector: ", p_vec_tmp)
                    loss_function(p_vec_tmp, models_lt, loc_forcings[sii],
                    loc_spinup_forcings[sii], forcing_one_timestep, loc_outputs[sii],
                    deepcopy(land_init), tem, param_to_index, loc_observations[sii],
                    cost_options[sii], constraint_method ; show_vec=true)
                    println("   ----------------------------------------------------- ")
                    # @show p_vec_tmp
                end
                @warn "replacing all nans by 0.0"
                grads_batch = replace(grads_batch, NaN => zero(Float32))
            end

            #grads_batch = mean(grads_batch, dims=2)[:,1]
            
            ∇params = pullback_func(grads_batch)[1]
            
            opt_state, flat = Optimisers.update(opt_state, flat, ∇params)

            if save_batch
                jldsave(joinpath(f_path, "$(name)_batch_$(batch_id)_epoch_$(epoch).jld2"); sites_batch=sites_batch,x_feature_batch=x_feature_batch, grads_batch=grads_batch, scaled_params_batch=scaled_params_batch, new_params=new_params, re=re, flat=flat, d_params=∇params)
            end
            
            batch_id += 1
            grads_batch
        end

        params_epoch = re(flat)(xfeatures)
        scaled_params_epoch = getParamsAct(params_epoch, tbl_params)
        
        getLossForSites(gradient_lib, loss_function, loss_array_sites, epoch,
        scaled_params_epoch, models_lt, sites_training, indices_sites_training, loc_forcings,
        loc_spinup_forcings, forcing_one_timestep, loc_outputs, land_init, loc_observations,
        tem, param_to_index, cost_options, constraint_method; logging=false)

        if save_epoch
            jldsave(joinpath(f_path, "$(name)_epoch_$(epoch).jld2"); grads_all_batches= grads_all_batches, loss= loss_array_sites[:, epoch], re=re, flat=flat)
        end
        
        println("-------------done:: epoch: $(epoch)-----------------------")
        next!(p; showvalues=[(:epoch, epoch)])
    end
    return loss_array_sites, re, flat
end
