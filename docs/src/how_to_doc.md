This documentation is build using [Documenter.jl](https://documenter.juliadocs.org/stable/) and [DocumenterVitepress.jl](https://github.com/LuxDL/DocumenterVitepress.jl), hence a working installaion of
[VitePress](https://vitepress.dev) in your system needs to be installed. 

### Prerequisites

- [Node.js](https://nodejs.org/) version 18 or higher.

VitePress can be used on its own, or be installed into an existing project. In both cases, you can install it with:

::: code-group

```sh [npm]
$ npm add -D vitepress
```

```sh [pnpm]
$ pnpm add -D vitepress
```

```sh [yarn]
$ yarn add -D vitepress
```

```sh [bun]
$ bun add -D vitepress
```

:::

## Building the Documentation

Building the documentations takes two steps:

````julia
include("gen_mds.jl")
````
which can generate markdonw files from `.jl` files and then

````julia
include("make.jl")
````
to generate `.md` files compatible with VitePress.

## Start a local dev server
To see the documentation locally run:

You should have the following `package.json` which is requiered to build/preview the docs

```json
{
  ...
  "scripts": {
    "docs:dev": "vitepress dev docs/docs",
    "docs:build": "vitepress build docs/docs",
    "docs:preview": "vitepress preview docs/docs"
  },
  ...
}
```

The `docs:dev` script will start a local dev server with instant hot updates. Run it with the following command:

::: code-group

```sh [npm]
$ npm run docs:dev
```

```sh [pnpm]
$ pnpm run docs:dev
```

```sh [yarn]
$ yarn docs:dev
```

```sh [bun]
$ bun run docs:dev
```

:::

Instead of npm scripts, you can also invoke VitePress directly with:

::: code-group

```sh [npm]
$ npx vitepress dev docs
```

```sh [pnpm]
$ pnpm exec vitepress dev docs
```

```sh [bun]
$ bunx vitepress dev docs
```

:::

For more information see the Documentation from [VitePress](https://vitepress.dev/guide/getting-started).

