using WGLMakie, Bonito
using WGLMakie.Colors
WGLMakie.activate!()

WGLMakie.activate!(resize_to=:parent)

function DemoCard(content=DOM.div(); style=Styles(), attributes...) 
    return Card(content; backgroundcolor=:silver, border_radius="2px", style=Styles(style, "color" => :white), attributes...)
end

# Little helper to create a Card with centered content
centered(c; style=Styles(), kw...) = DemoCard(Centered(DOM.h4(c; style=Styles("color" => :white))); style=style, kw...)

function get_var_names(path_variables)
    return map(name -> match(r"FLUXNET_(.+)\.zarr", name).captures[1], path_variables)
end

# _name_variable = match(r"FLUXNET_(.+)\.zarr", path_variable).captures[1]

function launchApp(path_exp)
    _variables = readdir(path_exp)
    nameVariables = get_var_names(_variables)
    name_extensions = Dict(nameVariables .=> joinpath.(path_exp, _variables))

    App() do
        style_drop = Styles(
            CSS("font-weight" => "500"),
            CSS(":hover", "background-color" => "silver"),
            CSS(":focus", "box-shadow" => "rgba(0, 0, 0, 0.5) 0px 0px 5px"),
            CSS("height" => "fit-content"),
        )

        header = DemoCard(
            "SindbadOutput: Forward run, WROASTED-FIRE",
            style = Styles(
                "font-weight" => "500",
                "grid-column" =>  "2",
                "grid-row" =>  "1",
                "color" => "firebrick"
            )
        )
        fig, ax, plt = heatmap(rand(1440,720); figure=(;size=(600, 400)))
        main = DemoCard(
            fig,
            style = Styles(
                "grid-column" =>  "2",
                "grid-row" =>  "2",
            )
        )

        dropdown = Dropdown(nameVariables; index=1, style=style_drop);
        d_cmap =  Dropdown(["viridis", "plasma"]; index=1, style=style_drop)

        sidebar = DemoCard(
            Grid(
                dropdown,
                d_cmap
            ),
            style = Styles(
                "grid-column" =>  "1",
                "grid-row" =>  "1 / 3",
            )
        )
        
        s_depth = Observable(1)
        on(dropdown.value) do value
            # @info value
            tmp_path = joinpath(path_exp, name_extensions[value])
            @info tmp_path
            ds_tmp = open_dataset(tmp_path)
            @info dims(ds_tmp["layer"])

            # @show intersect([Ti, longitude, latitude], dims(ds_tmp["layer"]))
            # s_depth[] = length(ds_tmp, )
        end

        on(d_cmap.value) do value
            plt.colormap[] = value
        end
        
        # cards = map(s_depth.value) do n
        #     cards = [centered(i) for i in 1:31]
        #     return Grid(cards;)
        # end

        # sidebar2 = DemoCard(
        #     cards,
        #     style = Styles(
        #         "grid-column" =>  "1",
        #         "grid-row" =>  "2",
        #     )
        # ),

        grid = Grid(
            sidebar, header, main,
            columns = "2fr 5fr",
            rows = "50px 1fr"
        )
        return DOM.div(grid; style=Styles("height" => "600px", "margin" => "20px", "position" => :relative))
    end
end