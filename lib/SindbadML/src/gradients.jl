export gradientSite
export gradientBatch!
export newVals
export get∇params
export train
export lossSites
export destructureNN

export UseFiniteDiff
export UseForwardDiff
struct UseFiniteDiff end
struct UseForwardDiff end

"""
    ForwardDiff_grads(loss_function::Function, vals::AbstractArray, args...)

Wraps a multi-input argument function to be used by ForwardDiff.

    - loss_function :: The loss function to be used by ForwardDiff
    - vals :: Gradient evaluation `values`
    - kwargs :: keyword arguments needed by the loss_function
"""
#@everywhere 
function gradientSite(gradient_lib::UseForwardDiff, loss_function::F, vals::AbstractArray, args...) where {F}
    loss_tmp(x) = loss_function(x, gradient_lib, args...)
    return ForwardDiff.gradient(loss_tmp, vals)#::Vector{Float32}
end

function gradientSite(gradient_lib::UseFiniteDiff, loss_function::F, vals::AbstractArray, args...) where {F}
    loss_tmp(x) = loss_function(x, gradient_lib, args...)
    return FiniteDiff.finite_difference_gradient(loss_tmp, vals)
end

"""
    ForwardDiff_grads(loss_function::Function, vals::AbstractArray, args...; CHUNK_SIZE = 42)

Wraps a multi-input argument function to be used by ForwardDiff.

    - loss_function :: The loss function to be used by ForwardDiff
    - vals :: Gradient evaluation `values`
    - CHUNK_SIZE :: https://juliadiff.org/ForwardDiff.jl/dev/user/advanced/#Configuring-Chunk-Size
    - kwargs :: keyword arguments needed by the loss_function
"""
function gradientSiteCfg(loss_function::F, vals::AbstractArray, args...; CHUNK_SIZE=12) where {F}
    out = similar(vals)
    loss_tmp(x) = loss_function(x, args...)
    cfg = ForwardDiff.GradientConfig(loss_tmp, vals, ForwardDiff.Chunk{CHUNK_SIZE}())
    ForwardDiff.gradient!(out, loss_tmp, vals, cfg)
    return out
end

"""
    scaledParams(up_params_now, xbatch, idx)

Returns:
    - site_name
    - scaled parameters within the proper bounds
"""
function scaledParams(up_params_now, tblParams, xbatch, idx)
    site_name = xbatch[idx]
    x_params = up_params_now(; site=site_name)
    scaled_params = getParamsAct(x_params, tblParams)
    return site_name, scaled_params
end

function getOutputCache(loc_output, ::UseForwardDiff)
    return DiffCache.(loc_output)
end

function getOutputCache(loc_output, ::UseFiniteDiff)
    return loc_output
end

function gradientBatch!(
    gradient_lib,
    loss_function::F,
    grads_batch,
    scaled_params_batch,
    models,
    sites_batch,
    indices_batch,
    loc_forcings,
    loc_spinup_forcings,
    forcing_one_timestep,
    loc_outputs,
    land_one,
    loc_observations,
    tem,
    param_to_index,
    cost_options,
    constraint_method;
    do_one=false,
    logging=true) where {F}

# Threads.@spawn allows dynamic scheduling instead of static scheduling
# of Threads.@threads macro.
# See <https://github.com/JuliaLang/julia/issues/21017>
    if do_one
        indices_batch = indices_batch[1:1]
    end

    p = Progress(length(sites_batch); desc="Computing batch grads...", color=:yellow, enabled=logging)
    @sync begin
        for idx ∈ eachindex(indices_batch)
           Threads.@spawn begin
                site_location = indices_batch[idx]
                site_name = sites_batch[idx]
                loc_params = scaled_params_batch(site=site_name)
                loc_forcing = loc_forcings[site_location]
                loc_obs = loc_observations[site_location]
                loc_output = loc_outputs[site_location]
                loc_spinup_forcing = loc_spinup_forcings[site_location]
                loc_cost_option = cost_options[site_location]
                # @show site_location
                # tcPrint(land_one.pools, c_olor=false)
                gg = gradientSite(
                    gradient_lib,
                    loss_function,
                    loc_params,
                    models,
                    loc_forcing,
                    loc_spinup_forcing,
                    forcing_one_timestep,
                    getOutputCache(loc_output, gradient_lib),
                    deepcopy(land_one),
                    tem,
                    param_to_index,
                    loc_obs,
                    loc_cost_option,
                    constraint_method
                )
                grads_batch[:, idx] = gg
                next!(p)
           end
        end
    end
end


"""
    destructureNN(model; nn_opt=Optimisers.Adam())
"""
function destructureNN(model; nn_opt=Optimisers.Adam())
    flat, re = Optimisers.destructure(model)
    opt_state = Optimisers.setup(nn_opt, flat)
    return flat, re, opt_state
end

function lossSites(
    gradient_lib,
    loss_function::F,
    loss_array_sites,
    epoch_number,
    scaled_params,
    models,
    sites_list,
    indices_sites,
    loc_forcings,
    loc_spinup_forcings,
    forcing_one_timestep,
    loc_outputs,
    land_one,
    loc_observations,
    tem,
    param_to_index,
    cost_options,
    constraint_method;
    do_one=false,
    logging=true) where {F}

    if do_one
        indices_sites = indices_sites[1:1]
    end

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
                    loc_params,
                    gradient_lib,
                    models,
                    loc_forcing,
                    loc_spinup_forcing,
                    forcing_one_timestep,
                    loc_output,
                    deepcopy(land_one),
                    tem,
                    param_to_index,
                    loc_obs,
                    loc_cost_option,
                    constraint_method
                )
                # @show site_name, site_location, idx, gg
                loss_array_sites[idx, epoch_number] = gg
                # next!(p)
           end
       end
    end
end


function train(
    gradient_lib,
    nn_model_params::Flux.Chain,
    loss_function::F,
    xfeatures,
    models_lt,
    sites_training,
    indices_sites_training,
    loc_forcings,
    loc_spinup_forcings,
    forcing_one_timestep,
    loc_outputs,
    land_init,
    loc_observations,
    tbl_params,
    tem,
    param_to_index,
    cost_options,
    constraint_method;
    n_epochs=2,
    optimizer=Optimisers.Adam(),
    batch_seed=123,
    batch_size=4,
    shuffle=true,
    local_root=nothing,
    name="seq_training_output") where {F}

    local_root = isnothing(local_root) ? dirname(Base.active_project()) : local_root
    f_path = joinpath(local_root, name)
    mkpath(f_path)
#
    flat, re, opt_state = destructureNN(nn_model_params; nn_opt=optimizer)
    n_params = length(nn_model_params[end].bias)

    sites_batches = batch_shuffle(sites_training, batch_size; seed=batch_seed)
    indices_sites_batches = batch_shuffle(indices_sites_training, batch_size; seed=batch_seed)
    grads_batch = zeros(Float32, n_params, batch_size)

    loss_array_sites = fill(zero(Float32), length(sites_training), n_epochs)

    p = Progress(n_epochs; desc="Computing epochs...")


    for epoch ∈ 1:n_epochs
        sites_batches = shuffle ? batch_shuffle(sites_training, batch_size; seed=epoch + batch_seed) : sites_batches
        indices_sites_batches = shuffle ? batch_shuffle(indices_sites_training, batch_size; seed=epoch + batch_seed) : indices_sites_batches
        batch_id = 1
        grads_all_batches = map(sites_batches, indices_sites_batches) do sites_batch, indices_batch
            x_feature_batch = xfeatures(; site=sites_batch)
            new_params, pullback_func = Zygote.pullback(p -> re(p)(x_feature_batch), flat)            
            scaled_params_batch = getParamsAct(new_params, tbl_params)
            grads_batch .= zero(Float32)
            gradientBatch!(
                gradient_lib,
                loss_function,
                grads_batch,
                scaled_params_batch,
                models_lt,
                sites_batch,
                indices_batch,
                loc_forcings,
                loc_spinup_forcings,
                forcing_one_timestep,
                loc_outputs,
                land_init,
                loc_observations,
                tem,
                param_to_index,
                cost_options,
                constraint_method;
                logging=true
            )

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
                    loss_function(
                        p_vec_tmp,
                        models_lt,
                        loc_forcings[sii],
                        loc_spinup_forcings[sii],
                        forcing_one_timestep,
                        loc_outputs[sii],
                        deepcopy(land_init),
                        tem,
                        param_to_index,
                        loc_observations[sii],
                        cost_options[sii],
                        constraint_method
                        ; show_vec=true)
                        println("   ----------------------------------------------------- ")
                    # @show p_vec_tmp
                end
                @warn "replacing all nans by 0.0"
                grads_batch = replace(grads_batch, NaN => zero(Float32))
            end

            #grads_batch = mean(grads_batch, dims=2)[:,1]
            
            ∇params = pullback_func(grads_batch)[1]
            
            opt_state, flat = Optimisers.update(opt_state, flat, ∇params)
            jldsave(joinpath(f_path, "$(name)_batch_$(batch_id)_epoch_$(epoch).jld2"); sites_batch=sites_batch,x_feature_batch=x_feature_batch, grads_batch=grads_batch, scaled_params_batch=scaled_params_batch, new_params=new_params, re=re, flat=flat, d_params=∇params)
            batch_id += 1
            grads_batch
        end
        params_epoch = re(flat)(xfeatures)
        scaled_params_epoch = getParamsAct(params_epoch, tbl_params)
        
        @time lossSites(
            gradient_lib,
            loss_function,
            loss_array_sites,
            epoch,
            scaled_params_epoch,
            models_lt,
            sites_training,
            indices_sites_training,
            loc_forcings,
            loc_spinup_forcings,
            forcing_one_timestep,
            loc_outputs,
            land_init,
            loc_observations,
            tem,
            param_to_index,
            cost_options,
            constraint_method;
            logging=false
        )
        jldsave(joinpath(f_path, "$(name)_epoch_$(epoch).jld2"); grads_all_batches= grads_all_batches, loss= loss_array_sites[:, epoch], re=re, flat=flat)
        next!(p; showvalues=[(:epoch, epoch)])
    end
    return loss_array_sites, re, flat
end
