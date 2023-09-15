using Random

rand_ntuple() = (; Dict([Symbol(randstring(3)) => (rand(Bool) ? rand(rand(1:3)) : rand(Float32)) for i in 1:10])...)

tuple = ntuple(10) do i 
    ntuple(x->rand_ntuple(), 6)
end


function test(big_tuple)
    map(x-> map(identity, x), big_tuple)
end

function test2(big_tuple)
    map(identity, big_tuple)
end

@code_warntype test(tuple)


big_tuple2 = ntuple(x->rand_ntuple(), 60)

@code_warntype test2(big_tuple2)

