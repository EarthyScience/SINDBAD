model = Lux.Chain(
  Dense(2, 8, tanh),
  Dense(8, 1,x->x^2), x -> reshape(x, :)
  )

rng = Random.default_rng()
Random.seed!(rng, 0)
ps, st = Lux.setup(rng, model)
ps_new = ComponentArray(ps)

ŷ, st = Lux.apply(model, rand(Float32,2,10), ps_new, st)

y = rand(Float32, 10)
function loss(y, model, ps_new, st)
  ŷ, st = Lux.apply(model, rand(Float32,2,10), ps_new, st)
  #ŷ .+= ps_new[1]
  mean(abs2.(y .- ŷ))
end