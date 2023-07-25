export getStandardVariableCatalog
export getVariableInfo
export getVariableCatalogFromLand
export saveVariableCatalogFromLand

function getVariableInfo(catalog, vari_b, t_step)
    default_info = defaultVariableInfo()
    default_keys = keys(default_info)
    o_varib = copy(default_info)
    if vari_b ∈ keys(catalog)
        var_info = catalog[vari_b]
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
                if !isnothing(field_value)
                    field_value = replace(field_value, "time" => t_step)
                else
                    field_value = ""
                end
            end
            o_varib[var_field] = field_value
        end
    end
    if isnothing(o_varib["standard_name"])
        o_varib["standard_name"] = split(vari_b, "__")[1]
    end
    if isnothing(o_varib["description"])
        o_varib["description"] = ""
    end
    return Dict(o_varib)
end

function getStandardVariableCatalog(info)
    variCat = Sindbad.parsefile(joinpath(info.experiment_root, "../../lib/ForwardSindbad/src/tools/sindbadVariables.json"), dicttype=Dict)
    return variCat
end

function defaultVariableInfo()
    return Sindbad.DataStructures.OrderedDict(
        "standard_name" => "",
        "long_name" => "",
        "units" => nothing,
        "sindbad_field" => "",
        "description" => nothing
    )
end

function getVariableCatalogFromLand(land)
    default_varib = defaultVariableInfo()
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
                var_dict["description"] = "carbon content of $((subfield)) pool(s)"
            elseif endswith(subfield, "W")
                var_dict["units"] = "mm"
                var_dict["description"] = "water storage in $((subfield)) pool(s)"
            end
        elseif field == "states"
            if startswith(subfield, "Δ")
                poolname = replace(subfield, "Δ" => "")
                if startswith(poolname, " c")
                    var_dict["units"] = "gC/m2"
                    var_dict["description"] = "change in carbon content of $(poolname) pool(s)"
                else
                    var_dict["units"] = "mm"
                    var_dict["description"] = "change in water storage in $(poolname) pool(s)"
                end
            else
                var_dict["units"] = "-"
            end
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