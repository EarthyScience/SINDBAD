::: tip What are `Exported` and `Internal` entities?

- `Exported` entities (functions, structs, types, constants):

These are explicitly made available to users using the `export` keyword, allowing them to be accessed without prefixing them with the module name.

- `Internal` entities (non-exported):

These remain accessible but require qualification with the module name (e.g., `MyModule.SomeType`), indicating that they are intended for internal use.

:::


```@docs
Sindbad
```

## Exported
```@meta

DocTestSetup= quote
using Sindbad
end
```

```@autodocs
Modules = [Sindbad]
Private = false
Filter = f -> !(f === Sindbad)
```

## Internal
```@meta
CollapsedDocStrings = false

DocTestSetup= quote
using Sindbad
end
```

```@autodocs
Modules = [Sindbad]
Public = false
```