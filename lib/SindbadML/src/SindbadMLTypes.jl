export FiniteDifferencesGrad
export FiniteDiffGrad
export ForwardDiffGrad
export PolyesterForwardDiffGrad
export SindbadMLGradType
export ZygoteGrad

abstract type SindbadMLGradType end
struct FiniteDifferencesGrad <: SindbadMLGradType end
struct FiniteDiffGrad <: SindbadMLGradType end
struct ForwardDiffGrad <: SindbadMLGradType end
struct PolyesterForwardDiffGrad <: SindbadMLGradType end
struct ZygoteGrad <: SindbadMLGradType  end


