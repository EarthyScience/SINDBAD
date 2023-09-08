#ar = [rand(Float32, 10) for i in 1:24]
ar = [rand(Float32, 10), rand(Bool, 10)]

_mask = rand(Bool,10)
indx = 1

function select_ar(ar, indx, _mask)
    y = ar[indx]
    return y[_mask]
end

select_ar(ar, indx, _mask)

@code_warntype select_ar(ar, indx, _mask)