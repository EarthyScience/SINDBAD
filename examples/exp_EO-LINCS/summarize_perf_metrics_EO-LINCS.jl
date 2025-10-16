using Serialization
using Revise
using SindbadExperiment
# Import the pickle module
using PyCall
pickle = pyimport("pickle")

toggleStackTraceNT()

forcing_set = "erai"
# site_info = CSV.File(
    # "/Net/Groups/BGI/scratch/skoirala/prod_sindbad.jl/examples/exp_WROASTED/settings_WROASTED/site_names_disturbance.csv";
    # header=true);
exp_main = "EO-LINCS_v202510"
tmp_out = joinpath("tmp_metrics_summary")
mkpath(tmp_out)

opti_sets = (:ndvi_modis, :ndvi_sen2,)

vs = String.([(:gpp, :nee, :reco, :transpiration, :evapotranspiration, :ndvi_modis, :ndvi_sen2,:agb)...])
all_metrics = [s() for s in subtypes(PerfMetric)]
all_metrics_names = [nameof(typeof(s)) for s in all_metrics]
site_index = 100
sites = ("FR-Pue", "DE-Hai", "AT-Neu")
site_range = 1:length(sites)
# site_range = 1:5
# generate the bucket
OD = Dict
perf_metrics = OD{Symbol, Union{OD, Vector{String}}}()
perf_metrics[:sites] = Array{String}(undef, length(site_range))
for mtr in opti_sets
    mtr = Symbol(mtr)
    perf_metrics[mtr] = OD{Symbol,OD}()
    for v in vs
        v = Symbol(v)
        perf_metrics[mtr][v] = OD{Symbol,Vector{Float64}}()
        for a_m in all_metrics_names
            perf_metrics[mtr][v][a_m] = Array{Float64}(undef, length(site_range)) * NaN
        end
    end
end

# pf=load(joinpath(tmp_out, "metrics_summary.jld2"), "perf_metrics")
# site_index = Base.parse(Int, ENV["SLURM_ARRAY_TASK_ID"])
site_index = 1
for site_index in site_range
    # site_index = Base.parse(Int, ARGS[1])
    domain = sites[site_index]
    # domain = string(site_info[site_index][1])
    perf_metrics[:sites][site_index] = domain
    mtr = opti_sets[2]
    for mtr in opti_sets

    # o_set = :set1
    base_o_set = mtr


    base_path_output = "/Users/skoirala/research/RnD/SINDBAD-RnD-SK/examples/exp_EO-LINCS/"
    # base_path_output = "/Net/Groups/BGI/tscratch/skoirala/$(exp_main)/$(forcing_set)/$(base_o_set)"
    # base_exp_name = "$(exp_main)_$(forcing_set)_$(base_o_set)_$(o_cost)"
    # base_path_site = joinpath(base_path_output, "output_" * domain * "_" * base_exp_name)
    # info_path = joinpath(base_path_site, "settings/info.jld2")
    # info = load(info_path, "info")
    # setLogLevel(:warn)
    # forcing = getForcing(info)

    # observations = getObservation(info, forcing.helpers)

    # obs_array = [Array(_o) for _o in observations.data] # TODO: necessary now for performance because view of keyedarray is slow

        base_exp_name = "$(exp_main)_$(forcing_set)_$(base_o_set)"
        base_path_site = joinpath(base_path_output, "output_" * domain * "_" * base_exp_name)
        info_path = joinpath(base_path_site, "settings/info.jld2")
        info = load(info_path, "info");
        setLogLevel(:info)
        forcing = getForcing(info);

        observations = getObservation(info, forcing.helpers);

        obs_array = [Array(_o) for _o in observations.data] # TODO: necessary now for performance because view of keyedarray is slow
        path_site = base_path_site
        exp_name = base_exp_name
        # path_site = replace(base_path_site, String(base_o_set) => String(o_set))
        # exp_name = replace(base_exp_name, String(base_o_set) => String(o_set))
        costOpt = info.optimization.cost_options
        obs_vars = costOpt.variable
        obs_inds = costOpt.obs_ind
        mod_fields = costOpt.mod_field
        mod_subfields = costOpt.mod_subfield
        # var_row=costOpt[3]
        # vi = 3
        for vi in eachindex(obs_vars)
            v = obs_vars[vi]
            v_pair = (mod_fields[vi], mod_subfields[vi])
            mod_v = v_pair[2]
            vinfo = getVariableInfo(v_pair, info.experiment.basics.temporal_resolution)
            v_standard = vinfo["standard_name"]

            obs_dat = obs_array[obs_inds[vi]]
            obs_σ = obs_array[obs_inds[vi]+1]
            obs_dat_TMP = obs_dat[:, 1, 1, 1]
            non_nan_index = findall(x -> !isnan(x), obs_dat_TMP)
            if length(non_nan_index) < 2
                tspan = 1:length(obs_dat_TMP)
            else
                tspan = first(non_nan_index):last(non_nan_index)
            end
            obs_σ = obs_σ[tspan]
            obs_dat = obs_dat[tspan]
            if v == :ndvi
                obs_dat = obs_dat .- nanmean(obs_dat)
            end


            mod_path = joinpath(path_site, "data", "$(exp_name)_$(domain)_$(mod_v).zarr")
            # mtr = opti_cost_cmp[1]
                mod_path_mtr = replace(mod_path, o_cost => String(mtr))
                if !isdir(mod_path_mtr)
                    println("$(site_index): $(domain), $(v), $(mtr), $(mod_path_mtr) is missing. Cannot calculate metrics. Continuing...")
                    continue
                end
                mod_dat_ds = SindbadData.zopen(mod_path_mtr, "r")
                mod_dat = mod_dat_ds["$(mod_v)"][:, 1]


                mod_dat = mod_dat[tspan]
                if v == :ndvi_modis || v == :ndvi_sen2
                    mod_dat = mod_dat .- nanmean(mod_dat)
                end

                obs_dat_n, obs_σ_n, mod_dat_n = getDataWithoutNaN(obs_dat, obs_σ, mod_dat)
                mi = 20
                if !isempty(mod_dat_n)
                    for mi in eachindex(all_metrics_names)
                        pf = Float64(metric(obs_dat_n, obs_σ_n, mod_dat_n, all_metrics[mi]))
                        perf_metrics[Symbol(mtr)][v][all_metrics_names[mi]][site_index] = pf
                        println("$(site_index): $(domain), $(v), $(mtr), $(all_metrics_names[mi])=$(pf)")
                        # println("$(site_index): $(domain) @ $(mod_path_mtr), $(o_set), $(v), $(mtr), $(all_metrics_names[mi])=$(pf)")
                    end
                else
                    println("$(site_index): $(domain), $(v), $(mtr), $(all_metrics_names[mi]) = all metrics are NaN due to empty/zero valid data points in observations or model data")
                end
            end
            println("..........................")
    end
    println("------------------------------------------------------------")
end
@save joinpath(tmp_out, "metrics_summary.jld2") perf_metrics

# Open the file in write-binary mode and save the dictionary
open(joinpath(tmp_out, "metrics_summary.pkl"), "w") do file
    pickle.dump(perf_metrics, file)
end