using DimensionalData

known_regions = Dict(
"Africa"=>(; lat = -40.0 .. 40, lon = -17.0 .. 51.0),
"Asia"=>(; lat = 5.0 .. 80.0, lon = 30.0 .. 179.5),
"Australia"=>(; lat = -40.0 .. -8.0, lon = 110.0 .. 155.0),
"Europe"=>(; lat = 35.0 .. 70.0, lon = -10.0 .. 33.0),
"North America"=>(; lat = 10.0 .. 80, lon = -168.0 .. -55.0),
"South America"=>(; lat = -60.0 .. 15, lon = -85.0 .. -33.0)
)

