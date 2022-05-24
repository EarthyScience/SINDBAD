using Revise
using Sinbad
# using ProfileView
using BenchmarkTools
#using GLMakie
using Pkg
using NetCDF
using YAXArrays, NetCDF, EarthDataLab, DiskArrayTools
using AxisKeys
using TypedTables, Tables
using Plots
using Pkg
using NetCDF
using YAXArrays, NetCDF, EarthDataLab, DiskArrayTools



struct AllNaN <: YAXArrays.DAT.ProcFilter
end
YAXArrays.DAT.checkskip(::AllNaN,x) = all(isnan,x)

expFilejs = "settings_minimal/experiment.json"
#local_root ="/Users/skoirala/research/sjindbad/sinbad.jl/"
local_root = @__DIR__
local_root = dirname(Base.active_project())
expFile = joinpath(local_root, expFilejs)


info = getConfiguration(expFile, local_root);

info = setupModel!(info);

out = createInitOut(info);

#observations = getObservation(info); # target observation!!

file = joinpath(info.sinbad_root, info.forcing.oneDataPath)

forcing_variables = keys(info.forcing.variables)

nc = NetCDF.open(file)
incubes = map(forcing_variables) do k
info = setupModel!(info);
out = createInitOut(info);
observations = getObservation(info); # target observation!!
# plot(observations.transpiration)
# plot(observations.transpiration_σ)
optimParams = info.opti.params2opti;
approaches = info.tem.models.forward;
tblParams = getParameters(info.tem.models.forward, info.opti.params2opti);
forcing = nothing
modelvars = info.tem.variables
# hcat(info.opti.constraints.variables.evapotranspiration.costOptions, info.opti.constraints.variables.transpiration.costOptions)
# initPools = getInitPools(info)
# @show out.pools.soilW


file = info.forcing.oneDataPath
#ds = open_dataset(file)
varnames = keys(info.forcing.variables)

nc = NetCDF.open(file)
incubes = map(varnames) do k
    v = nc[info.forcing.variables[k].sourceVariableName]
    atts = v.atts
    if any(in(keys(atts)), ["missing_value", "scale_factor", "add_offset"])
        v = CFDiskArray(v, atts)
    end
    ax = map(v.dim) do d
        dn = d.name
        dv = nc[dn][:]
        RangeAxis(dn,dv)
    end
    yax = YAXArray(ax,v)
    vinfo = info.forcing.variables[k]
    numtype = Val{info.tem.helpers.numbers.numType}()
    map(v->Sinbad.clean_inputs(v,vinfo,numtype),yax)
end;



outpath = joinpath(@__DIR__(),info.modelRun.output.dirPath)
outformat = info.modelRun.output.dataFormat

function layersize(vname, pools)
    if vname in keys(pools.water.zix)
        length(pools.water.zix[vname])
    elseif vname in keys(pools.carbon.zix)
        length(pools.carbon.zix[vname])
    else
        1
    end
end
function getOutDims(info,vname)
    ls = layersize(vname, info.tem.pools)
    if ls > 1
        OutDims("Time",RangeAxis("$(vname)_idx",1:ls),path = joinpath(outpath,"vname$outformat"),overwrite=true)
    else
        OutDims("Time",path = joinpath(outpath,"vname$outformat"),overwrite=true)
    end
end

outdims = map(Iterators.flatten(info.tem.variables)) do vn
outdims = map(Iterators.flatten(modelvars)) do vn
    getOutDims(info,vn)
end

using AxisKeys: KeyedArray, AxisKeys
#Fix: only time 
function getInDims(c)
    inax = String[]
    YAXArrays.Axes.findAxis("Time",c) === nothing || push!(inax,"Time")
    #Look for remaining axes
    islonlattime(n) = lowercase(n[1:min(3,length(n))]) in ("lon","lat","tim")
    axnames = YAXArrays.Axes.axname.(caxes(c))
    inollt = findall(!islonlattime,axnames)
    !isempty(inollt) && append!(inax,axnames[inollt])
    InDims(inax...;artype=KeyedArray, filter=AllNaN())
end


indims = getInDims.(incubes)
function getnts(incubes)
    i1 = findfirst(c->YAXArrays.Axes.findAxis("Time",c) !==nothing, incubes)
    length(getAxis("Time",incubes[i1]).values)
end
getnts(incubes)

using FillArrays
using YAXArrayBase: getdata

function unpack_yax(args;modelinfo,forcing_variables,nts)
    nin = length(forcing_variables)
    nout = sum(length,modelinfo.variables)
function unpack_yax(args)
    nts = args[end]
    varnames = args[end-1]
    modelvars = args[end-2]
    nin = length(varnames)
    nout = sum(length,modelvars)
    outputs = args[1:nout]
    inputs = args[(nout+1):(nout+nin)]
    #Make fillarrays for constant inputs
    inputs = map(inputs) do i
        dn = AxisKeys.dimnames(i)
        (!in(:time,dn) && !in(:Time,dn)) ? Fill(getdata(i),nts) : getdata(i)
    end
    return  outputs, inputs
    other = args[(nout+nin+1):end]
    @assert length(other) == 6
    return  outputs, inputs, other...
end

using FillArrays
#capt = []
#@profview outsp = runSpinup(approaches, forcing, out, info.tem.helpers, false; nspins=1);
#@time outsp = runSpinup(approaches, forcing, out, info.tem.helpers, false; nspins=1);
function rungridcell(args...;out,modelinfo,forcing_variables,nts,history=false,nspins=1)
    # outputs,inputs,selectedModels,out,modelinfo,modelvars,forcing_variables,nts = unpack_yax(args)
    outputs,inputs = unpack_yax(args;modelinfo,forcing_variables,nts)
    forcing = Table((; Pair.(forcing_variables, inputs)...))
    # outevolution = runEcosystem(info.tem.models.forward, forcing, out, info.tem; nspins=1);
    outforw = runEcosystem(modelinfo.models.forward, forcing, out, modelinfo; nspins=1);
    # outforw = runEcosystem(selectedModels, forcing, out, modelvars, modelinfo, history; nspins)
    i = 1
    modelvars = modelinfo.variables
function rungridcell(args...;history=false,nspins=1)
    outputs,inputs,selectedModels,out,modelinfo,modelvars,varnames,nts = unpack_yax(args)
    forcing = Table((; Pair.(varnames, inputs)...))
    outforw = runEcosystem(selectedModels, forcing, out, modelinfo)
    i = 1
    for group in keys(modelvars)
        data = columntable(outforw[group])
        for k in modelvars[group]
            if eltype(data[k]) <: AbstractArray
                for j in axes(outputs[i],1)
                    outputs[i][j,:] = data[k][j]
                end
            else
                outputs[i][:] .= data[k]
            end
            i += 1
        end
    end
end



res = mapCube(rungridcell,
    (incubes...,);
    out=out,
    modelinfo=info.tem,
    forcing_variables = forcing_variables,
    nts = getnts(incubes),
    indims=indims, 
    outdims=outdims,
)


res[1]
    (incubes...,),
    approaches,
    out,
    info.tem,
    modelvars,
    varnames,
    getnts(incubes);
    indims=indims, 
    outdims=outdims,
)
