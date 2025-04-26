export FiniteDifferencesGrad
export FiniteDiffGrad
export ForwardDiffGrad
export PolyesterForwardDiffGrad
export SindbadMLGradType

abstract type SindbadMLGradType end
struct FiniteDifferencesGrad <: SindbadMLGradType end
struct FiniteDiffGrad <: SindbadMLGradType end
struct ForwardDiffGrad <: SindbadMLGradType end
struct PolyesterForwardDiffGrad <: SindbadMLGradType end


