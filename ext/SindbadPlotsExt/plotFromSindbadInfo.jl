"""
    getAllVariables(in_out_models, which_field)

Extracts all unique variables from the input-output of the models in selected model structure for the specified field(s).

# Arguments
- `in_out_models`: A dictionary containing input-output of models, where keys are model names and values are dictionaries of fields (e.g., `:input`, `:output`).
- `which_field`: A `Symbol` or an array of `Symbol`s specifying the field(s) to extract variables from (e.g., `:input`, `:output`).

# Returns
- A sorted array of unique variables across all specified fields.

# Example
```julia
in_out_models = Dict(
    :model1 => Dict(:input => [:var1, :var2], :output => [:var3]),
    :model2 => Dict(:input => [:var2, :var4], :output => [:var5])
)
unique_vars = getAllVariables(in_out_models, [:input, :output])
println(unique_vars)  # Output: [:var1, :var2, :var3, :var4, :var5]
```
"""
function getAllVariables(in_out_models, which_field)
    if isa(which_field, Symbol)
        which_field = [which_field]
    end
    unique_variables = map(which_field) do wf
        collect(sort(unique(vcat([[(in_out_models[model][wf])...] for model in keys(in_out_models)]...))))
    end
    unique_variables = sort(unique(vcat(unique_variables...)))
    return unique_variables
end

"""
    namedTupleToFlareJSON(info::NamedTuple)

Convert a nested NamedTuple into a flare.json format suitable for d3.js visualization.

# Arguments
- `info::NamedTuple`: The input NamedTuple to convert

# Returns
- A dictionary in flare.json format with the following structure:
  ```json
  {
    "name": "root",
    "children": [
      {
        "name": "field1",
        "children": [...]
      },
      {
        "name": "field2",
        "value": 42
      }
    ]
  }
  ```

# Notes
- The function recursively traverses the NamedTuple structure
- Fields with no children are treated as leaf nodes with a value of 1
- The structure is flattened to show the full path to each field
"""
function namedTupleToFlareJSON(info::NamedTuple)
    function _convert_to_flare(nt::NamedTuple, name="sindbad_info")
        children = []
        for field in propertynames(nt)
            value = getfield(nt, field)
            if value isa NamedTuple
                push!(children, _convert_to_flare(value, string(field)))
            else
                # println("field: $field, value: $value")
                push!(children, Dict("name" => string(field), "value" => 1))
            end
        end
        return Dict("name" => name, "children" => children)
    end
    
    return _convert_to_flare(info)
end



"""
    plotIOModelStructure(info, which_function=:compute, which_field=[:input, :output])

Generates a visualization of the input-output (IO) structure of the selected models in the SINDBAD framework.

This function creates a grid-based visualization of the input-output relationships for the specified models. It identifies unique variables across the specified fields (`which_field`) and maps them to the corresponding models. The visualization highlights:


# Arguments
- `info`: A `NamedTuple` containing experiment information, including model configurations and metadata.
- `which_function`: A `Symbol` specifying the function to analyze (default: `:compute`).
- `which_field`: A `Symbol` or an array of `Symbol`s specifying the fields to visualize (e.g., `:input`, `:output`; default: `[:input, :output]`).

# Returns
- A plot object visualizing the IO structure of the selected models.

# Description
- Input variables (`:input`) with "□" marker.
- Output variables (`:output`) with "x" marker style.


# Example
```julia
info = prepExperiment("path/to/experiment/config")
plotIOModelStructure(info, :compute, [:input, :output])
```

# Notes
- The function assumes that the info object contains a valid model structure and experiment metadata.
- The plot includes annotations, grid lines, and legends for clarity.
- The generated plot is saved as a PDF file in the experiment's output directory.

"""
function Sindbad.plotIOModelStructure(info, which_function=:compute, which_field=[:input, :output])
    showInfo(plotIOModelStructure, @__FILE__, @__LINE__, "plotting IO model structure for $(which_function) with fields $(which_field)", n_f=4)

    in_out_models = getInOutModels(info.models.forward, which_function);
    unique_variables = getAllVariables(in_out_models, which_field)
    if isa(which_field, Vector)
        which_field = join(which_field, "_")
    end
    if isa(which_field, Vector)
        which_field = join(which_field, "_")
    end

    model_names = collect(keys(in_out_models))
    
    
    locs_in = []
    locs_out = []
    model_variables = []
    model_variables_in = []
    model_variables_out = []
    for (v_i, the_variable) in enumerate(unique_variables)
        for (m_i, model_name) in enumerate(model_names)
            if isa(which_field, String)
                the_fields = Symbol.(split(which_field, "_"))
                model_variables = SindbadCore.orD()
                foreach(the_fields) do w_field
                    model_variables[w_field] = in_out_models[model_name][w_field]
                end
            else
                model_variables_in = in_out_models[model_name][which_field]
            end
            if isa(model_variables, SindbadCore.orD)
                model_variables_in = model_variables[:input]
                model_variables_out = model_variables[:output]
            end
            if the_variable in model_variables_in
                push!(locs_in, (m_i, v_i))
            end
            if the_variable in model_variables_out
                push!(locs_out, (m_i, v_i))
            end
        end
    end
        
    unique_variables_names = string.(["$i. $(first(unique_variable)).$(last(unique_variable))" for (i, unique_variable) in enumerate(unique_variables)])

    model_names_str = ["$(i). $(string(model_name))" for (i, model_name) in enumerate(model_names)]
    plots_default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
    
    n_grid_lines = 5
    grid_lines_color = :dimgray
    n_annotations = 10

    plot_width = 2000
    plot_height = plot_width * length(unique_variables_names) / length(model_names_str)
    xtick_locs = collect((1:length(model_names_str)) .- 0.5)
    ytick_locs = collect((1:length(unique_variables_names)) .- 0.5)



    title_str = "IO Visualization: $which_field of $(which_function) of Models in $(info.experiment.basics.id)"
    plots_vline([0], color=grid_lines_color, linewidth=1.5, title=title_str, label="")
    plots_vline!([xtick_locs[xi] for xi in n_grid_lines:n_grid_lines:length(xtick_locs)], color=grid_lines_color, linewidth=0.9, label="")
    plots_hline!([ytick_locs[xi] for xi in n_grid_lines:n_grid_lines:length(ytick_locs)], color=grid_lines_color, linewidth=0.9, label="")
    plots_hline!([0], color=grid_lines_color, linewidth=1.5, label="")


    ax = plots_scatter!(first.(locs_in) .- 0.5, last.(locs_in) .- 0.5, marker=:square, markersize=9, color=:turquoise1, markerstrokewidth=0.15, markerstrokecolor=:yellow2, size=(plot_width, plot_height), xrotation=90, xticks=(xtick_locs, model_names_str), yticks=(ytick_locs, unique_variables_names), colorbar=false, left_margin=50plots_mm, bottom_margin=25plots_mm, c=:greens, grid=true, gridcolor=:gainsboro, gridlinewidth=1, gridalpha=0.5, widen=false, tickdirection=:out, legend=false, xtickfontcolor=:blue, ytickfontcolor=:green, label="Input\n", legend_columns=1, legend_frame=false)

    if isa(which_field, String)
        plots_scatter!(first.(locs_out) .- 0.5, last.(locs_out) .- 0.5, marker=:x, markersize=4, color=:orangered1, markerstrokewidth=0.2, label="Output\n")
    end

    plots_plot!(ax, legend=(-0.15, -0.04), legendfontsize=9)  # Move legend after plotting
    annotations_y = [(xtick_locs[xi] + 0.5, ytick_locs[i] - 0.5, plots_text("↑\n$i", :green, :center, 7)) for xi in n_annotations:n_annotations:length(xtick_locs) for i in n_annotations:n_annotations:length(ytick_locs)]
    annotations = [(xtick_locs[xi] - 0.7, ytick_locs[i] - 0.5, plots_text("$(xi)→", :blue, :center, 7)) for xi in n_annotations:n_annotations:length(xtick_locs) for i in 1:n_annotations:length(ytick_locs)]
    plots_annotate!(annotations)
    plots_annotate!(annotations_y)

    plots_ylims!(ax, (-1, length(unique_variables_names) + 1))
    plots_xlims!(ax, (-1, length(model_names) + 1))
    plots_savefig(joinpath(info.output.dirs.figure, "$(which_field)_variables_$(info.experiment.basics.id)_$(which_function).pdf"))
    return ax
end
