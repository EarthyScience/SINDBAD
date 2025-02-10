## Dev/build documentation in remote server

```sh
sindbad.jl $ cd docs
```

Next, load the appropiate modules

```sh
docs $ module load nodejs/20.12.2
```

Install npm packages

```sh
docs $ npm i
```

Load Julia

```sh
docs $ module load julia/1.10
```

## Building the Documentation

Now, start a julia session and activate the `docs` env:

````sh
docs $ julia
````

````sh
julia > ] # type ]
````
and

````sh
pkg > activate . # now, instantiate
````

````sh
] dev ../ ../lib/SindbadUtils/ ../lib/SindbadData/ ../lib/SindbadMetrics/ ../lib/SindbadSetup/ ../lib/SindbadTEM
````

````sh
pkg > instantiate # type delete[backspace] after finishing to get back to the julia repl
````

Building the documentations takes two steps:

````julia
julia> include("gen_models_md.jl")
````
which generates a markdown file with all available models. Then do,

```julia
julia> include("make.jl")
```

to create the site.

## Start a local dev server

To see the documentation locally (remote machine) run in another terminal:

```sh
docs $ npm run docs:dev
```

A small alert should popup, click `open in browser`. Or click on `➜  Local:   http://localhost:5173/`.

## Build directly

Also, if all `md` files are already available, the following should also work

```sh
docs $ npm run docs:build
```

and to get a `preview` 

```sh
docs $ npm run docs:preview
```
___