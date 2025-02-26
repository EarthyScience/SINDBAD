export getLossForSites
export lossSite
export getInnerArgs

"""
    getLoss(models, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_output, land_init, tem_info, tem_run_spinup, loc_obs, cost_options, constraint_method; optim_mode=true)

Calculates the loss for a given site. At this stage model parameters should had been set. The loss is calculated using the `getLossVector` and `combineLoss` functions. The `getLossVector` function calculates the loss for each model output and the `combineLoss` function combines the losses into a single value.

# Arguments
- `models`: list of models
- `loc_forcing`: forcing data location
- `loc_spinup_forcing`: spinup forcing data location
- `loc_forcing_t`: forcing data time for one time step.
- `loc_output`: output data location
- `land_init`: initial land state
- `tem_info`: model information
- `tem_run_spinup`: spinup information
- `loc_obs`: observation data location
- `cost_options`: cost options
- `constraint_method`: constraint method

The optional argument `optim_mode` is used to return the loss value only when set to `true`. Otherwise, it returns the loss value, the loss vector, and the loss indices.

*Created by:*
 - skoirala
"""
function getLoss(models, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_output, land_init, tem_info, tem_run_spinup, loc_obs, cost_options, constraint_method; optim_mode=true)
    coreTEM!(
        models,
        loc_forcing,
        loc_spinup_forcing,
        loc_forcing_t,
        loc_output,
        land_init,
        tem_info,
        tem_run_spinup)
    lossVec = getLossVector(loc_output, loc_obs, cost_options)
    t_loss = combineLoss(lossVec, constraint_method)
    loss_indices = cost_options.mod_ind
    if optim_mode
        return t_loss
    else
        return t_loss, lossVec, loss_indices
    end
end

"""
    lossSite(new_params, gradient_lib, models, loc_forcing, loc_spinup_forcing, loc_forcing_t, loc_output, land_init, tem_info, tem_run_spinup, param_to_index, loc_obs, cost_options, constraint_method; optim_mode=true)

Function to calculate the loss for a given site. This is used for optimization, hence the `optim_mode` argument is set to `true` by default. Also, a gradient library should be set as well as new parameters to update the models. See all input arguments in the function:

# Arguments
- `new_params`: new parameters
- `gradient_lib`: gradient library
- `models`: list of models
- `loc_forcing`: forcing data location
- `loc_spinup_forcing`: spinup forcing data location
- `loc_forcing_t`: forcing data time for one time step.
- `loc_output`: output data location
- `land_init`: initial land state
- `tem_info`: model information
- `tem_run_spinup`: spinup information
- `param_to_index`: parameter to index
- `loc_obs`: observation data location
- `cost_options`: cost options
- `constraint_method`: constraint method

*Created by:*
 - skoirala
"""
function lossSite(new_params, gradient_lib, models, loc_forcing, loc_spinup_forcing, 
    loc_forcing_t, loc_output, land_init, tem_info, tem_run_spinup, param_to_index, loc_obs, cost_options, constraint_method; optim_mode=true)

    out_data = getOutputFromCache(loc_output, new_params, gradient_lib)
    new_models = updateModelParameters(param_to_index, models, new_params)
    return getLoss(new_models, loc_forcing, loc_spinup_forcing, loc_forcing_t, out_data, land_init, tem_info, tem_run_spinup, loc_obs, cost_options, constraint_method; optim_mode)
end

"""
    getLossForSites(gradient_lib, loss_function::F, loss_array_sites, loss_array_split, epoch_number, scaled_params, sites_list, indices_sites, models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, loc_land, tem_info, tem_run_spinup, param_to_index, loc_observations, cost_options, constraint_method) where {F}

Calculates the loss for all sites. The loss is calculated using the `loss_function` function. The `loss_array_sites` and `loss_array_split` arrays are updated with the loss values. The `loss_array_sites` array stores the loss values for each site and epoch, while the `loss_array_split` array stores the loss values for each model output and epoch.

# Arguments
- `gradient_lib`: gradient library
- `loss_function`: loss function
- `loss_array_sites`: array to store the loss values for each site and epoch
- `loss_array_split`: array to store the loss values for each model output and epoch
- `epoch_number`: epoch number
- `scaled_params`: scaled parameters
- `sites_list`: list of sites
- `indices_sites`: indices of sites
- `models`: list of models
- `space_forcing`: forcing data location
- `space_spinup_forcing`: spinup forcing data location
- `loc_forcing_t`: forcing data time for one time step.
- `space_output`: output data location
- `loc_land`: initial land state
- `tem_info`: model information
- `tem_run_spinup`: spinup information
- `param_to_index`: parameter to index
- `loc_observations`: observation data location
- `cost_options`: cost options
- `constraint_method`: constraint method

*Created by:*
 - skoirala
"""
function getLossForSites(gradient_lib, loss_function::F, loss_array_sites, loss_array_split, epoch_number,
    scaled_params, sites_list, indices_sites, models, space_forcing, space_spinup_forcing,
    loc_forcing_t, space_output, loc_land, tem_info, tem_run_spinup, param_to_index, loc_observations,
    cost_options, constraint_method) where {F}
    @sync begin
        for idx ∈ eachindex(indices_sites)
           Threads.@spawn begin
                site_location = indices_sites[idx]
                site_name = sites_list[idx]
                loc_params = scaled_params(site=site_name)
                loc_forcing = space_forcing[site_location]
                loc_obs = loc_observations[site_location]
                loc_output = space_output[site_location]
                loc_spinup_forcing = space_spinup_forcing[site_location]
                loc_cost_option = cost_options[site_location]

                gg, gg_split, loss_indices = loss_function(loc_params, gradient_lib, models, loc_forcing, loc_spinup_forcing,
                    loc_forcing_t, loc_output, deepcopy(loc_land), tem_info, tem_run_spinup, param_to_index, loc_obs, loc_cost_option, constraint_method;
                    optim_mode=false)
                loss_array_sites[idx, epoch_number] = gg
                loss_array_split[idx, loss_indices, epoch_number] = gg_split
           end
       end
    end
end

"""
    getInnerArgs(idx, grads_lib, scaled_params_batch, selected_models, space_forcing, space_spinup_forcing, loc_forcing_t, space_output, loc_land, tem_info, tem_run_spinup, param_to_index, loc_observations, cost_options, constraint_method, indices_batch, sites_batch)

Function to get inner arguments for the loss function.
    
# Arguments
- `idx`: index batch value
- `grads_lib`: gradient library
- `scaled_params_batch`: scaled parameters batch
- `selected_models`: selected models
- `space_forcing`: forcing data location
- `space_spinup_forcing`: spinup forcing data location
- `loc_forcing_t`: forcing data time for one time step.
- `space_output`: output data location
- `loc_land`: initial land state
- `tem_info`: model information
- `tem_run_spinup`: spinup information
- `param_to_index`: parameter to index
- `loc_observations`: observation data location
- `cost_options`: cost options
- `constraint_method`: constraint method
- `indices_batch`: indices batch
- `sites_batch`: sites batch
"""
function getInnerArgs(idx, grads_lib,
    scaled_params_batch, # ? input_args
    selected_models,
    space_forcing,
    space_spinup_forcing,
    loc_forcing_t,
    space_output,
    loc_land,
    tem_info,
    tem_run_spinup,
    param_to_index,
    loc_observations,
    cost_options,
    constraint_method,
    indices_batch,
    sites_batch)

    site_location = indices_batch[idx]
    site_name = sites_batch[idx]
    # get site information
    x_vals = scaled_params_batch(site=site_name).data.data
    loc_forcing = space_forcing[site_location]
    loc_obs = loc_observations[site_location]
    loc_output = space_output[site_location]
    loc_spinup_forcing = space_spinup_forcing[site_location]
    loc_cost_option = cost_options[site_location]

    return (;
        loc_params = x_vals,
        inner_args = (
            selected_models,
            loc_forcing,
            loc_spinup_forcing,
            loc_forcing_t,
            getCacheFromOutput(loc_output, grads_lib),
            deepcopy(loc_land),
            tem_info,
            tem_run_spinup,
            param_to_index,
            loc_obs,
            loc_cost_option,
            constraint_method)
        )
end