# using WGLMakie, Bonito
# using WGLMakie.Colors
using YAXArrays, Zarr, DimensionalData

# WGLMakie.activate!(resize_to=:parent)

function DemoCard(content=DOM.div(); style=Styles(), attributes...) 
    return Card(content; backgroundcolor=:silver, border_radius="2px", style=Styles(style, "color" => :white), attributes...)
end

# Little helper to create a Card with centered content
centered(c; style=Styles(), kw...) = DemoCard(Centered(DOM.h4(c; style=Styles("color" => :white))); style=style, kw...)

function get_var_names(path_variables)
    return map(name -> match(r"FLUXNET_(.+)\.zarr", name).captures[1], path_variables)
end

path_exp = "/Net/Groups/BGI/tscratch/lalonso/SindbadOutput/fireEmissions_local/FLUXNET_Hybrid_seasfire/data/"
_variables = readdir(path_exp)
nameVariables = get_var_names(_variables)
name_extensions = Dict(nameVariables .=> joinpath.(path_exp, _variables))

set_theme!(theme_dark())

function launchButtons(path_exp)
    _variables = readdir(path_exp)
    nameVariables = get_var_names(_variables)
    name_extensions = Dict(nameVariables .=> joinpath.(path_exp, _variables))
    App() do

        style = Styles(
            CSS("font-weight" => "500"),
            CSS("background-color" => "silver"),
            CSS(":hover", "background-color" => "#1a1a1a"),
            CSS(":hover", "color" => "silver"),
            CSS("height" => "30px"),
            CSS(":focus", "box-shadow" => "rgba(0, 0, 0, 0.5) 0px 0px 5px"),
        )

        dropdown = Dropdown(nameVariables; index=1, style=style)
        dropdown_depth = Dropdown([1, 2, 3]; index=2, style=style)
        dropdown_cmap = Dropdown(["viridis", "plasma"]; index=1, style=style)
        
        tmp_path = joinpath(path_exp, name_extensions["TWS"])
        ds_tmp = open_dataset(tmp_path)["layer"]
        ds_data = ds_tmp["layer"][1, 1, :, :]

        fig, ax, plt = heatmap(ds_data)

        on(dropdown.value) do value
            tmp_path = joinpath(path_exp, name_extensions[value])
            ds_tmp = open_dataset(tmp_path)["layer"]
        end

        # lines!(ax, GeoMakie.coastlines())

        Colorbar(fig[1,2], plt)
        hidedecorations!(ax, ticks=false, ticklabels = false,
            grid = false, minorgrid = false, minorticks = false)
        ax.ytickformat = "{:.1f}ᵒ"
        ax.xtickformat = "{:.1f}ᵒ"
        ax.spinewidth[] = 0.25
        # plot pixel 
        ax = Axis(fig[2, 1:2])
        lines!(ax, s_pix; color=:orangered)
        rowsize!(fig.layout, 2, Auto(0.25))

        header = Row(
            DemoCard("Logo"),
            DemoCard("Sindbad"),
            dropdown, dropdown_depth, dropdown_cmap,
            style = Styles(
                "grid-column" =>  "1",
                "grid-row" =>  "1",
            )
        )


        main = DemoCard(
            fig,
            style = Styles(
                "grid-column" =>  "1",
                "grid-row" =>  "2",
            )
        )

        grid = Grid(
            header, main,
            rows = "2rem 1fr",
            gap = "0px"
        )

        on(dropdown_cmap.value) do value
            plt.colormap[] = value
        end

        return DOM.div(grid; style=Styles(
            "height" => "100vh",
            "margin" => "0px",
            "background-color" => "#1a1a1a",
            "padding" => "0px",
            # "margin-left" => "0px",
        ))
    end
end

launchButtons(path_exp)
