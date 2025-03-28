using WGLMakie, Bonito
using WGLMakie.Colors
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

function launchButtons(path_exp)
    _variables = readdir(path_exp)
    nameVariables = get_var_names(_variables)
    name_extensions = Dict(nameVariables .=> joinpath.(path_exp, _variables))

    App() do
        style_drop =Styles(Styles(), "background-color" => "gray", "color" => "black")

        style_btn = Styles(
            CSS("font-weight" => "500"),
            CSS(":hover", "background-color" => "silver"),
            CSS(":focus", "box-shadow" => "rgba(0, 0, 0, 0.5) 0px 0px 5px"),
            CSS("width" => "5px"),
        )

        dropdown = Dropdown(nameVariables; index=1, style=style_drop);

        sidebar = Grid(dropdown,
            style = Styles(
                "grid-column" =>  "2",
                "grid-row" =>  "1",
            )
        )

        s_depth = Observable(1)

        tmp_path = joinpath(path_exp, name_extensions["TWS"])
        ds_tmp = open_dataset(tmp_path)

        ds_tmp_slice = @lift(ds_tmp["layer"][1, 1, :, :])

        fig, ax, plt = heatmap(ds_tmp_slice; figure=(;size=(600, 400)))
        
        main = DemoCard(
            fig,
            style = Styles(
                "grid-column" =>  "2",
                "grid-row" =>  "2",
            )
        )

        on(dropdown.value) do value
            tmp_path = joinpath(path_exp, name_extensions[value])
            ds_tmp = open_dataset(tmp_path)
            tmp_names = name.(dims(ds_tmp["layer"]))

            extra_name = setdiff([tmp_names...], [:Ti, :longitude, :latitude])
            # if length(extra_name) == 1
            #     s_depth[] = length(lookup(ds_tmp["layer"], extra_name[1]))
            # end
            # @show s_depth
            ds_tmp_slice[] = @lift(ds_tmp["layer"][$s_depth, 1, :, :].data[:,:])
        end
        
        # on(d_cmap.value) do value
        #     plt.colormap[] = value
        # end

        current_depth = Observable(1)

        _depth_btns = map(1:9) do d
            if d == current_depth
                return Button("$d"; style=style_drop)
            else
                return Button("$d"; style=style_btn)
            end
        end

        depth_grid = 
            Grid(_depth_btns...; columns="repeat(3, 0.1fr)",
            # style = Styles(
            #     "grid-column" =>  "1",
            #     "grid-row" =>  "1/3",
            # )
        )
        
        for btn in _depth_btns
            on(btn.value) do click::Bool
                @info "Button clicked!"
                @info parse(Int, btn.content[])
                # get the button value
                btn_value = parse(Int, btn.content[])
                current_depth[] = btn_value
                @info current_depth
            end
        end

        grid = Grid(
            sidebar, depth_grid, main,
            columns = "2fr 5fr",
            rows = "50px 1fr"
        )
        return DOM.div(grid; style=Styles("height" => "500px", "margin" => "20px", "position" => :relative))
    end
end