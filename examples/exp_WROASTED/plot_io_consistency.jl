using Revise
using SindbadExperiment
# using CairoMakie

using Plots
toggleStackTraceNT()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
begin_year = "2000"
end_year = "2017"

domain = "US-SRM"
# domain = "MY-PSO"
path_variable = "$(getSindbadDataDepot())/fn/$(domain).1979.2017.daily.nc"
forcing_config = "forcing_erai.json"

path_observation = path_variable
optimize_it = true
# optimize_it = false
path_output = nothing

parallelization_lib = "threads"
model_array_type = "static_array"
replace_info = Dict("experiment.basics.time.date_begin" => begin_year * "-01-01",
    "experiment.basics.config_files.forcing" => forcing_config,
    "experiment.basics.domain" => domain,
    "forcing.default_forcing.data_path" => path_variable,
    "experiment.basics.time.date_end" => end_year * "-12-31",
    "experiment.flags.run_optimization" => optimize_it,
    "experiment.flags.calc_cost" => false,
    "experiment.flags.catch_model_errors" => false,
    "experiment.flags.spinup_TEM" => true,
    "experiment.flags.debug_model" => false,
    "experiment.exe_rules.model_array_type" => model_array_type,
    "experiment.model_output.path" => path_output,
    "experiment.model_output.format" => "nc",
    "experiment.model_output.save_single_file" => true,
    "experiment.exe_rules.parallelization" => parallelization_lib,
    "optimization.algorithm_optimization" => "opti_algorithms/CMAEvolutionStrategy_CMAES.json",
    "optimization.observations.default_observation.data_path" => path_observation);

info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info

function get_variables(in_out_models, which_field)
    if isa(which_field, Symbol)
        which_field = [which_field]
    end
    unique_variables=map(which_field) do wf
        collect(sort(unique(vcat([[(in_out_models[model][wf])...] for model in keys(in_out_models)]...))))
    end
    unique_variables = unique(vcat(unique_variables...))
    return unique_variables
end
which_function = :compute
in_out_models = getInOutModels(info.models.forward, which_function);


which_field = [:input, :output]
which_field = :input
unique_variables = get_variables(in_out_models, which_field)
# Extract all unique inputs
# unique_variables = sort(unique(vcat([in_out_models[model][:input] for model in keys(in_out_models)]...)))
model_names = collect(keys(in_out_models))

# Create a binary matrix

n_variables = length(unique_variables)
# Fill in the matrix
locs = []
binary_matrix = zeros(Int, length(unique_variables), length(model_names)) .* NaN
for (v_i, input_value) in enumerate(unique_variables)
    for (m_i, model_name) in enumerate(model_names)
        model_variables = in_out_models[model_name][which_field]
        if input_value in model_variables
            # v_i_new = n_variables - v_i + 1
            v_i_new = v_i
            binary_matrix[v_i_new, m_i] = 1
            println("$m_i: $(model_name) has $v_i: $(input_value), $(binary_matrix[v_i_new, m_i])")
            push!(locs, (m_i, v_i_new))
            println("-------------")
        end
        # binary_matrix[m_i, v_i] = v_i * m_i
        # println("$m_i: $(model_name) has $v_i: $(input_value), $(binary_matrix[m_i,v_i])")
    end
end


binary_matrix[:,2]
# Mask zeros (replace with NaN)
# binary_matrix = replace(binary_matrix, 0 => NaN)

unique_variables_names = string.(["$i. $(first(unique_variable)).$(last(unique_variable))" for (i, unique_variable) in enumerate(unique_variables)])
# Plot heatmap
model_names_str = ["$(i). $(string(model_name))" for (i, model_name) in enumerate(model_names)]  
default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))

plot_width = 2000
plot_height = plot_width * length(unique_variables_names) / length(model_names_str)
xtick_locs = collect((1:length(model_names_str)).-0.5)
ytick_locs = collect((1:length(unique_variables_names)).-0.5)

n_grid_lines = 5


grid_lines_color = :darkorange1
vline([0], color=grid_lines_color, linewidth=1.5)
vline!([xtick_locs[xi] for xi in n_grid_lines:n_grid_lines:length(xtick_locs)], color=grid_lines_color, linewidth=0.9)
hline!([ytick_locs[xi] for xi in n_grid_lines:n_grid_lines:length(ytick_locs)], color=grid_lines_color, linewidth=0.9)
hline!([0], color=grid_lines_color, linewidth=1.5)

ax=scatter!(first.(locs).-0.5, last.(locs).-0.5, marker=:square, markersize=9, color=:turquoise1, markerstrokewidth=0.3, markerstrokecolor=:yellow2, size=(plot_width, plot_height),xrotation=90, xticks=(xtick_locs, model_names_str), yticks=(ytick_locs, unique_variables_names), colorbar=false, left_margin=40Plots.mm, bottom_margin=10Plots.mm, c=:greens, grid=true, gridcolor=:gainsboro, gridlinewidth=1, gridalpha=0.5,widen=false,tickdirection=:out, legend=false, xtickfontcolor=:blue, ytickfontcolor=:green)

n_annotations = 10

annotations_y = [(xtick_locs[xi]+0.5, ytick_locs[i]-0.5, text("↑\n$i", :green, :center, 7)) for xi in n_annotations:n_annotations:length(xtick_locs) for i in n_annotations:n_annotations:length(ytick_locs)]
# annotations_y = [(xtick_locs[xi], ytick_locs[i], text(string(i), :green, :center, 7)) for xi in 3:n:length(xtick_locs) for i in 3:n:length(ytick_locs)]
annotations = [(xtick_locs[xi]-0.5, ytick_locs[i]-0.5, text("$(xi)→", :blue, :center, 7)) for xi in n_annotations:n_annotations:length(xtick_locs) for i in 1:n_annotations:length(ytick_locs)]
annotate!(annotations)
annotate!(annotations_y)

ylims!(ax, (-1, length(unique_variables_names)+1))
xlims!(ax, (-1, length(model_names)+1))
savefig(joinpath(info.output.dirs.figure, "heatmap_vars_$(domain)_$(which_field)_$(which_function).pdf"))

