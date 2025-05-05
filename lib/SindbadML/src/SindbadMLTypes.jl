export EnzymeGrad
export FiniteDifferencesGrad
export FiniteDiffGrad
export ForwardDiffGrad
export PolyesterForwardDiffGrad
export SindbadMLGradType
export ZygoteGrad

abstract type SindbadMLGradType end
purpose(::Type{SindbadMLGradType}) = "Abstract type for automatic differentiation or finite differences for gradient calculations"

struct EnzymeGrad <: SindbadMLGradType  end
purpose(::Type{EnzymeGrad}) = "Use Enzyme.jl for automatic differentiation"
struct FiniteDifferencesGrad <: SindbadMLGradType end
purpose(::Type{FiniteDifferencesGrad}) = "Use FiniteDifferences.jl for finite difference calculations"

struct FiniteDiffGrad <: SindbadMLGradType end
purpose(::Type{FiniteDiffGrad}) = "Use FiniteDiff.jl for finite difference calculations"

struct ForwardDiffGrad <: SindbadMLGradType end
purpose(::Type{ForwardDiffGrad}) = "Use ForwardDiff.jl for automatic differentiation"

struct PolyesterForwardDiffGrad <: SindbadMLGradType end
purpose(::Type{PolyesterForwardDiffGrad}) = "Use PolyesterForwardDiff.jl for automatic differentiation"

struct ZygoteGrad <: SindbadMLGradType  end
purpose(::Type{ZygoteGrad}) = "Use Zygote.jl for automatic differentiation"