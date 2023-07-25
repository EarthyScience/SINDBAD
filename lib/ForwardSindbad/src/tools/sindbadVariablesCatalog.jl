export getVariableCatalog
export getVariableInfo
export getVariableCatalogFromLand
export saveVariableCatalogFromLand


function getVariableInfo(catalog, vari_b)
    o_varib = copy(catalog["default_varib"])
    if vari_b ∈ keys(catalog)
        o_varib = catalog[vari_b]
    end
    o_varib["standard_name"] = split(vari_b, "__")[1]
    return o_varib
end

function getVariableCatalog(info)
    variCat = Sindbad.parsefile(joinpath(info.experiment_root, "../../lib/ForwardSindbad/src/tools/sindbadVariables.json"), dicttype=Dict)
    default_info = variCat["default_varib"]
    t_step = info.model_run.time.model_time_step
    default_keys = keys(default_info)

    for vari_b ∈ keys(variCat)
        if vari_b !== "default_varib"
            var_info = variCat[vari_b]
            var_fields = keys(var_info)
            all_fields = Tuple(unique([default_keys..., var_fields...]))
            for var_field ∈ all_fields
                field_value = nothing
                if haskey(default_info, var_field)
                    field_value = default_info[var_field]
                else
                    field_value = var_info[var_field]
                end
                if haskey(var_info, var_field)
                    var_prop = var_info[var_field]
                    if !isnothing(var_prop) && length(var_prop) > 0
                        field_value = var_info[var_field]
                    end
                end
                if var_field == "units"
                    field_value = replace(field_value, "time" => t_step)
                end
                variCat[vari_b][var_field] = field_value
            end
        end
    end
    return variCat
end


function getVariableCatalogFromLand(land)
    default_varib = Sindbad.DataStructures.OrderedDict(
        "standard_name" => "",
        "long_name" => "",
        "units" => nothing,
        "sindbad_field" => "",
        "description" => nothing
    )
    landprops = propertynames(land)
    varnames = []
    variCat = Sindbad.DataStructures.OrderedDict()
    for lf in landprops
        lsf = propertynames(getproperty(land, lf))
        for lsff in lsf
            keyname = string(lf) * "__" * string(lsff)
            # keyname = string(lsff) * "__" * string(lf)
            push!(varnames, keyname)
        end
    end
    @show varnames
    varnames = sort(varnames)
    for varn in varnames

        field = split(varn, "__")[1]
        subfield = split(varn, "__")[2]
        var_dict = copy(default_varib)
        var_dict["standard_name"] = subfield
        var_dict["long_name"] = replace(subfield, "_" => " ")
        var_dict["sindbad_field"] = field
        if field == "fluxes"
            if startswith(subfield, "c_")
                var_dict["units"] = "gC/m2/time"
                var_dict["description"] = "carbon flux as $(var_dict["long_name"])"
            else
                var_dict["units"] = "mm/time"
                var_dict["description"] = "water flux as $(var_dict["long_name"])"
            end
        elseif field == "pools"
            if startswith(subfield, "c")
                var_dict["units"] = "gC/m2"
                var_dict["description"] = "carbon storage in $((subfield)) pool(s)"
            elseif endswith(subfield, "W")
                var_dict["units"] = "mm"
                var_dict["description"] = "water storage in $((subfield)) pool(s)"
            end
        elseif field == "states"
            if startswith(subfield, "Δ")
                poolname = replace(subfield, "Δ" => "")
                @show subfield, poolname
                if startswith(subfield, "c")
                    var_dict["units"] = "gC/m2"
                    var_dict["description"] = "change in carbon storage in $(poolname) pool(s)"
                else
                    var_dict["units"] = "mm"
                    var_dict["description"] = "change in water storage in $(poolname) pool(s)"
                end
            else
                var_dict["units"] = "-"
            end
            var_dict["units"] = "-"
        elseif startswith(subfield, "frac_")
            var_dict["units"] = "fraction"
        end
        if occursin("_k", subfield)
            if endswith(subfield, "_frac")
                var_dict["units"] = "fraction"
            else
                var_dict["units"] = "/time"
            end
        end
        if occursin("_f_", subfield)
            var_af = split(subfield, "_f_")[1]
            var_afft = split(subfield, "_f_")[2]
            var_dict["description"] = "effect of $(var_afft) on $(var_af). 1: no stress, 0: complete stress"
            var_dict["units"] = "-"
        end
        variCat[varn] = var_dict
    end
    return variCat
end

function saveVariableCatalogFromLand(land, file_name)
    if isfile(file_name)
        error("cannot overwrite the catalog file. Either give a new name or delete the original file")
    end
    variCat = getVariableCatalogFromLand(land)
    jsondata = Sindbad.json(variCat)
    open(file_name, "w") do f
        write(f, jsondata)
    end
    return nothing
end


