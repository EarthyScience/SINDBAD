# ? not clear

function test_unpack_app(forward)
    map(forward) do mod
        return mod        
    end
end

function test_unpack_app(forward)
    foldl(forward) do mod
        return mod        
    end
end

@code_warntype test_unpack_app(forward)

using Transducers

f_identity(x) = x

function t_map(apps)
    return Map(f_identity)(apps) |> collect
end

@code_warntype t_map(forward)
output_f = t_map(forward)

@code_warntype updateModelParametersType(tblParams2, output_f, tblParams.defaults)

@time updateModelParametersType(tblParams2, output_f, tblParams.defaults);

@code_warntype updateModelParametersTypeMap(tblParams2, output_f, tblParams.defaults)

@time new_models = updateModelParametersTypeMap(tblParams2, output_f, tblParams.defaults)
@time collect(new_models);

#@code_warntype collect(out_models)


function updateModelParametersType(tblParams, approaches, pVector)
    new_models = map(approaches) do approachx
        #@code_warntype new_model(approachx, tblParams, pVector)
        new_model(approachx, tblParams, pVector)
    end
    return new_models
end

function updateModelParametersTypeMap(tblParams, approaches, pVector)
    new_m(x) = new_model(x, tblParams, pVector)
    return Map(new_m)(approaches)
end

function inner_update(k, var, modelName, tblParams, new_ps)
    indx = findall(row -> row.names == k && row.modelsApproach == modelName, tblParams)
    var = !isempty(indx) ? new_ps[indx[1]] : var
    return k => var
end

function inner_vals(_pairs, modelName, tblParams, new_ps)
    #new_pairs = Pair[]
    #for (k,val) in _pairs
    #    push!(new_pairs, inner_update(k, val, modelName, tblParams, new_ps))
    #end
    #new_pairs = [p for p in new_pairs]
    #@show typeof(new_pairs)
    #return new_pairs
    in_vals = map(_pairs) do p
        inner_update(p[1], p[2], modelName, tblParams, new_ps)
    end
    #@show typeof(in_vals)
    return in_vals
end

function new_model(approachx, tblParams, pVector)
    modelName = nameof(typeof(approachx))
    if modelName ∈ tblParams.modelsApproach
        _pairs = pairs(getproperties(approachx)) |> collect
        newvals = inner_vals(_pairs,  modelName, tblParams, pVector)::Vector{Pair{Symbol, Float32}}
        #@code_warntype constructorof(typeof(approachx))(;newvals...)
        return constructorof(typeof(approachx))(;newvals...)
    else
        return approachx
    end
end