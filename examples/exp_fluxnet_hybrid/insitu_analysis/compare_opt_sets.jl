using Revise
using SindbadExperiment
using Dates
using Plots
toggleStackTraceNT()

forcing_set = "erai"
site_info = CSV.File(
    "/Net/Groups/BGI/scratch/skoirala/prod_sindbad.jl/examples/exp_WROASTED/settings_WROASTED/site_names_disturbance.csv";
    header=true);

exp_main = "Insitu_v202503"

opti_set = (:set1, :set3, :set9)

opti_cost_cmp = ("NSE", "NNSE")
o_cost = "NSE"

# site_index = Base.parse(Int, ENV["SLURM_ARRAY_TASK_ID"])
site_index = 100
for site_index in 1:205
# site_index = Base.parse(Int, ARGS[1])
    domain = string(site_info[site_index][1])

    for o_set in opti_set
            path_output = "/Net/Groups/BGI/tscratch/skoirala/$(exp_main)/$(forcing_set)/$(o_set)"
            exp_name = "$(exp_main)_$(forcing_set)_$(o_set)_$(o_cost)"
            path_site = joinpath(path_output, domain*"_"*exp_name)
            info_path = joinpath(path_site, "settings/info.jld2")
            info=load(info_path,"info");
            setLogLevel(:warn)
            forcing = getForcing(info);

            observations = getObservation(info, forcing.helpers);
            
            obs_array = [Array(_o) for _o in observations.data]; # TODO: necessary now for performance because view of keyedarray is slow

            # some plots
            costOpt = prepCostOptions(obs_array, info.optimization.cost_options)
            default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))

            # load matlab wroasted results
            tmp_out = joinpath("tmp_comparison_nse_v_nnse_opti", string(o_set))
            mkpath(tmp_out)
            fig_prefix = joinpath(tmp_out, info.experiment.basics.domain * "_" * replace(info.experiment.basics.name, "_NSE" => ""))
            # var_row=costOpt[3]
            foreach(costOpt) do var_row
                v = var_row.variable
                println("$(site_index): $(domain), $(o_set), $(v)")
                v_pair = (var_row.mod_field, var_row.mod_subfield)
                mod_v = v_pair[2]
                vinfo = getVariableInfo(v_pair, info.experiment.basics.temporal_resolution)
                v_standard = vinfo["standard_name"]
                lossMetric = var_row.cost_metric
                loss_name = nameof(typeof(lossMetric))
                if loss_name in (:NNSEInv, :NSEInv)
                    lossMetric = NSE()
                end
                obs_dat = obs_array[var_row.obs_ind]
                obs_σ = obs_array[var_row.obs_ind + 1]
                obs_dat_TMP = obs_dat[:, 1, 1, 1]
                non_nan_index = findall(x -> !isnan(x), obs_dat_TMP)
                if length(non_nan_index) < 2
                    tspan = 1:length(obs_dat_TMP)
                else
                    tspan = first(non_nan_index):last(non_nan_index)
                end
                obs_σ = obs_σ[tspan]
                obs_dat = obs_dat[tspan]
                xdata = [info.helpers.dates.range[tspan]...]
                if v == :ndvi
                    obs_dat = obs_dat .- nanmean(obs_dat)
                end

                plot(xdata, obs_dat; label="obs", seriestype=:scatter, mc=:black, ms=4, lw=0, ma=0.65, left_margin=1Plots.cm)

                mod_path = joinpath(path_site,"data","$(exp_name)_$(domain)_$(mod_v).zarr")

                for mtr in opti_cost_cmp
                    mod_path_mtr = replace(mod_path, o_cost => String(mtr))
                    mod_dat_ds = SindbadData.zopen(mod_path_mtr, "r")
                    mod_dat = mod_dat_ds["$(mod_v)"][:,1]
                    

                    mod_dat = mod_dat[tspan]
                    if v == :ndvi
                        mod_dat = mod_dat .- nanmean(mod_dat)
                    end
        
                    obs_dat_n, obs_σ_n, mod_dat_n = getDataWithoutNaN(obs_dat, obs_σ, mod_dat)
                    metr_mod = metric(obs_dat_n, obs_σ_n, mod_dat_n, lossMetric)
            
                    plot!(xdata, mod_dat, lw=1.5, ls=:dash, left_margin=1Plots.cm, legend=:outerbottom, legendcolumns=3, label="$(mtr) ($(nameof(typeof(lossMetric)))=$(round(metr_mod, digits=2)))", size=(2000, 1000), title="$(vinfo["long_name"]) ($(vinfo["units"])) -> $(forcing_set), $(o_set)")
                end
                
                savefig(fig_prefix * "_$(v).png")
            end
            println("..........................")
        end
    println("------------------------------------------------------------")
end