```@docs
Sindbad
```

## Public
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
CollapsedDocStrings = true

DocTestSetup= quote
using Sindbad
end
```

```@autodocs
Modules = [Sindbad]
Public = false
```