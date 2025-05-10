
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
ignored_modules = [Sindbad.SindbadTypes]
Modules = [Sindbad]
Public = false
```