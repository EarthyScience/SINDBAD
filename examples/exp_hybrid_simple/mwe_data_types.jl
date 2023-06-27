using Dates, ForwardDiff, AxisKeys
r = rand(Float32, 4)
r[1] = NaN32    
ka = KeyedArray(r; i =Date(today()):Date(today()+Day(3)) )
ar = Union{Float32, ForwardDiff.Dual}[1f0,2f0, ForwardDiff.Dual(NaN32), 2f0]
idx_f(ar,ka) = (.!isnan.(ar .* ka))
idxs = idx_f(ar,ka)

@code_warntype idx_f(ar,r)

function ka_ar_unstable(ka, ar,idxs)
    return abs2.(ka[idxs] .- ar[idxs])
end

@code_warntype ka_ar_unstable(ka, ar, idxs)

ar2 = [1f0,2f0, ForwardDiff.Dual(NaN32), 2f0]

typeof(ar2)