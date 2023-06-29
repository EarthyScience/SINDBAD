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

using PreallocationTools: DiffCache, get_tmp
using ForwardDiff
A = [1 2; 3 4]
function get_view(ar, indx)
    return @view ar[:,indx]
end

b = get_view(A, 1)

fill!(b, 0)
A

in_put = DiffCache(A)

function fxy(in_put, x, y)
    in_put = get_tmp(in_put, x)
    ŷ =  x[1]*x[2] + x[1] + x[2]
    b = get_view(in_put,1)
    fill!(b, ŷ)
    return sum(abs.(in_put .- y))
end

#fxy(in_put, [1,2])

A = [1 2; 3 4]

let 
    y = rand()*A
    in_put = DiffCache(A)
    g(x) = fxy(in_put, x, y)
    ForwardDiff.gradient(g, [1.0,2.0])
end
