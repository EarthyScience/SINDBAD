using Revise
using Sinbad
# using ProfileView
using BenchmarkTools
#using GLMakie

expFile = "sandbox/test_json/settings_minimal/experiment.json"

info = getConfiguration(expFile);
info = setupModel!(info);
out = getInitOut(info);
forcing = getForcing(info);
obsvars, modelvars, optimvars = getConstraintNames(info);
observations = getObservation(info); # target observation!!

optimParams = info.opti.params2opti;
approaches = info.tem.models.forward;
# tblParams = getParameters(info.tem.models.forward, info.opti.params2opti);

# initPools = getInitPools(info)
# @show out.pools.soilW

outsp = runSpinup(approaches, forcing, out, info.tem.helpers, false; nspins=3);
osp = outsp[1];
pprint(osp)
# @time runSpinup(approaches, forcing, out, info.tem.helpers, false; nspins=1);

outforw = runForward(approaches, forcing, outsp[1], info.tem.variables, info.tem.helpers);
pools = outforw.pools |> columntable
fluxes = outforw.fluxes |> columntable

# outevolution = runEcosystem(approaches, forcing, outsp[1], modelvars, info.tem; nspins=3)

# outfor = runEcosystem(approaches, forcing, out, info.tem.helpers);
#pprint(outsp)

# outparams, outdata = optimizeModel(forcing, out, observations, approaches, optimParams,
    # obsvars, modelvars, optimvars, info.tem, info.opti; maxfevals=1);


# for it in 1:10
#     @time runSpinup(approaches, forcing, out, info.tem.helpers, false; nspins=4)
# end
function rotate!(v,n::Int)
    l = length(v)
    l>1 || return v
    n = n % l
    n = n < 0 ? n+l : n
    n==0 && return v
    for i=1:gcd(n,l)
      tmp = v[i]
      dst = i
      src = dst+n
      while src != i
        v[dst] = v[src]
        dst = src
        src += n
        if src > l
          src -= l
        end
      end
      v[dst] = tmp
    end
    return v
  end
a=rand(6)
rotate!(a, 3)
# outf=columntable(outdata.fluxes)
using GLMakie
fig = Figure(resolution=(2200, 900))
# lines(pools.snowW)
lines(fluxes.gpp)
lines!(fluxes.NEE)
lines!(fluxes.NPP)
# lines!(fluxes.evapotranspiration)
# lines!(observations.evapotranspiration)

