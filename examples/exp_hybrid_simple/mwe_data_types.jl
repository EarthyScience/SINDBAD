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

A = [1 2; 3 4]
function get_view(ar, indx)
    return @view ar[:,indx]
end

b = get_view(A, 1)

fill!(b, 0)
A

in_put = DiffCache(A)

function fxy(in_put, x)
    in_put = get_tmp(in_put, x)
    ŷ =  x*x + x
    b = get_view(in_put,1)
    #in_put[:,1] .= ŷ
    fill!(b, ŷ)
    return in_put
end

fxy(in_put, 1)

ForwardDiff.derivative(x->fxy(in_put, x), 1)

function gxy(ŷ, y)
    return mean(abs2.(y .- ŷ))
end
