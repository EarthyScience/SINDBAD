
export SpinupType
abstract type SpinupType <: SindbadType end
purpose(::Type{SpinupType}) = "Abstract type for model spinup related functions and methods in SINDBAD"

# ------------------------- spinup mode ------------------------------------------------------------
export SpinupMode
export AllForwardModels
export SelSpinupModels
export EtaScaleA0H
export EtaScaleA0HCWD
export EtaScaleAHCWD
export EtaScaleAH
export NlsolveFixedpointTrustregionCEco
export NlsolveFixedpointTrustregionCEcoTWS
export NlsolveFixedpointTrustregionTWS
export ODEAutoTsit5Rodas5
export ODEDP5
export ODETsit5
export Spinup_TWS
export Spinup_cEco_TWS
export Spinup_cEco
export SSPDynamicSSTsit5
export SSPSSRootfind

abstract type SpinupMode <: SpinupType end
purpose(::Type{SpinupMode}) = "Abstract type for model spinup modes in SINDBAD"

struct AllForwardModels <: SpinupMode end
purpose(::Type{AllForwardModels}) = "Use all forward models for spinup"

struct EtaScaleA0H <: SpinupMode end
purpose(::Type{EtaScaleA0H}) = "scale carbon pools using diagnostic scalars for ηH and c_remain"

struct EtaScaleA0HCWD <: SpinupMode end
purpose(::Type{EtaScaleA0HCWD}) = "scale carbon pools of CWD (cLitSlow) using ηH and set vegetation pools to c_remain"

struct EtaScaleAHCWD <: SpinupMode end
purpose(::Type{EtaScaleAHCWD}) = "scale carbon pools of CWD (cLitSlow) using ηH and scale vegetation pools by ηA"

struct EtaScaleAH <: SpinupMode end
purpose(::Type{EtaScaleAH}) = "scale carbon pools using diagnostic scalars for ηH and ηA"

struct NlsolveFixedpointTrustregionCEco <: SpinupMode end
purpose(::Type{NlsolveFixedpointTrustregionCEco}) = "use a fixed-point nonlinear solver with trust region for carbon pools (cEco)"

struct NlsolveFixedpointTrustregionCEcoTWS <: SpinupMode end
purpose(::Type{NlsolveFixedpointTrustregionCEcoTWS}) = "use a fixed-point nonlinear solver with trust region for both cEco and TWS"

struct NlsolveFixedpointTrustregionTWS <: SpinupMode end
purpose(::Type{NlsolveFixedpointTrustregionTWS}) = "use a fixed-point nonlinearsolver with trust region for Total Water Storage (TWS)"

struct ODEAutoTsit5Rodas5 <: SpinupMode end
purpose(::Type{ODEAutoTsit5Rodas5}) = "use the AutoVern7(Rodas5) method from DifferentialEquations.jl for solving ODEs"

struct ODEDP5 <: SpinupMode end
purpose(::Type{ODEDP5}) = "use the DP5 method from DifferentialEquations.jl for solving ODEs"

struct ODETsit5 <: SpinupMode end
purpose(::Type{ODETsit5}) = "use the Tsit5 method from DifferentialEquations.jl for solving ODEs"

struct SelSpinupModels <: SpinupMode end
purpose(::Type{SelSpinupModels}) = "run only the models selected for spinup in the model structure"

struct SSPDynamicSSTsit5 <: SpinupMode end
purpose(::Type{SSPDynamicSSTsit5}) = "use the SteadyState solver with DynamicSS and Tsit5 methods"

struct SSPSSRootfind <: SpinupMode end
purpose(::Type{SSPSSRootfind}) = "use the SteadyState solver with SSRootfind method"


struct Spinup_TWS{M,F,T,I,O,N} <: SpinupMode
    models::M
    forcing::F
    tem_info::T
    land::I
    loc_forcing_t::O
    n_timesteps::N
end
purpose(::Type{Spinup_TWS}) = "Spinup spinup_mode for Total Water Storage (TWS)"

struct Spinup_cEco_TWS{M,F,T,I,O,N,TWS} <: SpinupMode
    models::M
    forcing::F
    tem_info::T
    land::I
    loc_forcing_t::O
    n_timesteps::N
    TWS::TWS
end
purpose(::Type{Spinup_cEco_TWS}) = "Spinup spinup_mode for cEco and TWS"

struct Spinup_cEco{M,F,T,I,O,N} <: SpinupMode
    models::M
    forcing::F
    tem_info::T
    land::I
    loc_forcing_t::O
    n_timesteps::N
end
purpose(::Type{Spinup_cEco}) = "Spinup spinup_mode for cEco"


# ------------------------- spinup sequence and types ------------------------------------------------------------
export SpinupSequence
export SpinupSequenceWithAggregator

struct SpinupSequenceWithAggregator <: SpinupType
    forcing::Symbol
    n_repeat::Int
    n_timesteps::Int
    spinup_mode::SpinupMode
    options::NamedTuple
    aggregator_indices::Vector{Int}
    aggregator::Vector{TimeAggregator}
    aggregator_type::TimeAggregation
end
purpose(::Type{SpinupSequenceWithAggregator}) = "Spinup sequence with time aggregation capabilities"

struct SpinupSequence <: SpinupType
    forcing::Symbol
    n_repeat::Int
    n_timesteps::Int
    spinup_mode::SpinupMode
    options::NamedTuple
end
