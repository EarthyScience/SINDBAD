using YAXArrays, Zarr
using DimensionalData
using WGLMakie, Bonito
using WGLMakie.Colors
WGLMakie.activate!()

# include("app.jl")

# path_exp = "/Net/Groups/BGI/tscratch/lalonso/SindbadOutput/fireEmissions_cases/FLUXNET_Hybrid_seasfire/data"

# launchApp(path_exp)

path_exp = "/Net/Groups/BGI/tscratch/lalonso/SindbadOutput/fireEmissions_debug2/FLUXNET_Hybrid_seasfire/data/"

# launchButtons(path_exp)
function get_var_names(path_variables)
    return map(name -> match(r"FLUXNET_(.+)\.zarr", name).captures[1], path_variables)
end

_variables = readdir(path_exp)
nameVariables = get_var_names(_variables)
name_extensions = Dict(nameVariables .=> joinpath.(path_exp, _variables))
tmp_path = joinpath(path_exp, name_extensions["TWS"])
ds_tmp = open_dataset(tmp_path)["layer"]


App() do session
    d_indx = Observable(1)
    dropdown = Dropdown([1, 2, 3]; index=1)

    ds_tmp_slice = @lift(ds_tmp[$d_indx, 1, :, :])

    fig, ax, plt = heatmap(ds_tmp_slice; figure=(;size=(600, 400)))

    on(dropdown.value) do value
        d_indx[] = value
    end

    return Grid(fig, dropdown)
end