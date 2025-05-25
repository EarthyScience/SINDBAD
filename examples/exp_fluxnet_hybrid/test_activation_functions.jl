export sigmoid_k

sigmoid_k(x, K) = one(x) / (one(x) + exp(-K * x))


function sigmoid_2(x)
    1 / (1 + exp(-2 * x))
end


function sigmoid_3(x)
    1 / (1 + exp(-3 * x))
end