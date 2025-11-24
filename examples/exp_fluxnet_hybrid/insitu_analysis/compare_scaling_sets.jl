using Revise
using Sindbad.Simulation
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
o_cost = "NNSE"

k_sets = Dict(
    "SR_RSc" => "Insitu_v202505_RgPot_Slow_Reserve",
    "FR_NoRSc" => "Insitu_v202505_RgPot_LargeK_Reserve",
    "FR_RSc" => "Insitu_v202505_RgPot_LargeK_Reserve_Scale",
    "FR_RSc_100K" => "Insitu_v202505_RgPot_LargeK_Reserve_Scale_100K",
)
k_names = collect(keys(k_sets))
k_base = "FR_RSc_100K"
o_set = :set1
# site_index = Base.parse(Int, ENV["SLURM_ARRAY_TASK_ID"])
site_index = 2
k_color = [:steelblue2, :seagreen3, :Goldenrod, :gray69]

for site_index in 1:205
    # site_index = Base.parse(Int, ARGS[1])
    domain = string(site_info[site_index][1])

    exp_main = k_sets[k_base]
    path_output = "/Net/Groups/BGI/tscratch/skoirala/$(exp_main)/$(forcing_set)/$(o_set)"
    exp_name = "$(exp_main)_$(forcing_set)_$(o_set)_$(o_cost)"
    path_site = joinpath(path_output, domain * "_" * exp_name)
    info_path = joinpath(path_site, "settings/info.jld2")
    @show info_path
    if isfile(info_path)

        info = load(info_path, "info")
        setLogLevel(:warn)
        forcing = getForcing(info)

        observations = getObservation(info, forcing.helpers)

        obs_array = [Array(_o) for _o in observations.data] # TODO: necessary now for performance because view of keyedarray is slow

        # some plots
        costOpt = prepCostOptions(obs_array, info.optimization.cost_options)
        default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))

        # load matlab wroasted results
        tmp_out = joinpath("tmp_comparison_reserve", string(o_set))
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
            obs_σ = obs_array[var_row.obs_ind+1]
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
                obs_dat = obs_dat #.- nanmean(obs_dat)
            end

            plot(xdata, obs_dat; label="obs", seriestype=:scatter, mc=:black, ms=4, lw=0, ma=0.65, left_margin=1Plots.cm)

            mod_path = joinpath(path_site, "data", "$(exp_name)_$(domain)_$(mod_v).zarr")
            kn_i = 1
            for kn in k_names
                mtr = k_sets[kn]
                mod_path_mtr = replace(mod_path, exp_main => String(mtr))
                # @show mod_path_mtr, isfile(mod_path_mtr)
                # # @
                if !isdir(mod_path_mtr)
                    @info "$(mod_path_mtr) not found"
                    @show mod_path_mtr
                    continue
                end
                mod_dat_ds = SindbadData.zopen(mod_path_mtr, "r")
                mod_dat = mod_dat_ds["$(mod_v)"][:, 1]


                mod_dat = mod_dat[tspan]
                if v == :ndvi
                    mod_dat = mod_dat #.- nanmean(mod_dat)
                end

                obs_dat_n, obs_σ_n, mod_dat_n = getDataWithoutNaN(obs_dat, obs_σ, mod_dat)
                metr_mod = metric(obs_dat_n, obs_σ_n, mod_dat_n, lossMetric)

                plot!(xdata, mod_dat, color=k_color[kn_i], lw=1.5, ls=:dash, left_margin=1Plots.cm, legend=:outerbottom, legendcolumns=length(k_names)+1/2, label="$(kn)\n($(nameof(typeof(lossMetric)))=$(round(metr_mod, digits=2)))", size=(2000, 1000), title="$(domain): $(vinfo["long_name"]) ($(vinfo["units"])) -> $(forcing_set), $(o_set)")
                kn_i += 1
            end

            savefig(fig_prefix * "_$(v).png")
        end
        println("..........................")
        # end
        println("------------------------------------------------------------")
    end
end
# /Net/Groups/BGI/tscratch/skoirala/Insitu_v202505_RgPot_LargeK_Reserve/erai/set1/GL-ZaH_Insitu_v202505_RgPot_LargeK_Reserve_erai_NNSE/settings/info.jld2
# /Net/Groups/BGI/tscratch/skoirala/Insitu_v202505_RgPot_LargeK_Reserve/erai/set1/GL-ZaH_Insitu_v202505_RgPot_LargeK_Reserve_erai_set1_NNSE/
# /Net/Groups/BGI/tscratch/skoirala/Insitu_v202505_RgPot_LargeK_Reserve/erai/set1/GL-ZaH_Insitu_v202505_RgPot_LargeK_Reserve_erai_set1_NNSE