
export MLType
abstract type MLType <: SindbadType end
purpose(::Type{MLType}) = "Abstract type for types in machine learning related methods in SINDBAD"

# ------------------------- gradient related types ------------------------------------------------------------
export EnzymeGrad
export FiniteDifferencesGrad
export FiniteDiffGrad
export ForwardDiffGrad
export PolyesterForwardDiffGrad
export GradType
export ZygoteGrad

abstract type GradType <: MLType end
purpose(::Type{GradType}) = "Abstract type for automatic differentiation or finite differences for gradient calculations"

struct EnzymeGrad <: GradType  end
purpose(::Type{EnzymeGrad}) = "Use Enzyme.jl for automatic differentiation"
struct FiniteDifferencesGrad <: GradType end
purpose(::Type{FiniteDifferencesGrad}) = "Use FiniteDifferences.jl for finite difference calculations"

struct FiniteDiffGrad <: GradType end
purpose(::Type{FiniteDiffGrad}) = "Use FiniteDiff.jl for finite difference calculations"

struct ForwardDiffGrad <: GradType end
purpose(::Type{ForwardDiffGrad}) = "Use ForwardDiff.jl for automatic differentiation"

struct PolyesterForwardDiffGrad <: GradType end
purpose(::Type{PolyesterForwardDiffGrad}) = "Use PolyesterForwardDiff.jl for automatic differentiation"

struct ZygoteGrad <: GradType  end
purpose(::Type{ZygoteGrad}) = "Use Zygote.jl for automatic differentiation"