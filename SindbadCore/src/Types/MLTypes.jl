
export MLTypes
abstract type MLTypes <: SindbadTypes end
purpose(::Type{MLTypes}) = "Abstract type for types in machine learning related methods in SINDBAD"

# ------------------------- gradient related types ------------------------------------------------------------
export MLGradType
export EnzymeGrad
export FiniteDifferencesGrad
export FiniteDiffGrad
export ForwardDiffGrad
export PolyesterForwardDiffGrad
export ZygoteGrad

abstract type MLGradType <: MLTypes end
purpose(::Type{MLGradType}) = "Abstract type for automatic differentiation or finite differences for gradient calculations"

struct EnzymeGrad <: MLGradType  end
purpose(::Type{EnzymeGrad}) = "Use Enzyme.jl for automatic differentiation"
struct FiniteDifferencesGrad <: MLGradType end
purpose(::Type{FiniteDifferencesGrad}) = "Use FiniteDifferences.jl for finite difference calculations"

struct FiniteDiffGrad <: MLGradType end
purpose(::Type{FiniteDiffGrad}) = "Use FiniteDiff.jl for finite difference calculations"

struct ForwardDiffGrad <: MLGradType end
purpose(::Type{ForwardDiffGrad}) = "Use ForwardDiff.jl for automatic differentiation"

struct PolyesterForwardDiffGrad <: MLGradType end
purpose(::Type{PolyesterForwardDiffGrad}) = "Use PolyesterForwardDiff.jl for automatic differentiation"

struct ZygoteGrad <: MLGradType  end
purpose(::Type{ZygoteGrad}) = "Use Zygote.jl for automatic differentiation"

# ML training types
export MLTrainingType
export MixedGradient
export LossModelObsML

abstract type MLTrainingType <: MLTypes end
purpose(::Type{MLTrainingType}) = "Abstract type for training a hybrid algorithm in SINDBAD"

struct MixedGradient <: MLTrainingType end
purpose(::Type{MixedGradient}) = "Use a mixed gradient approach for training using gradient from multiple methods and combining them with pullback from zygote"

struct LossModelObsML <: MLTrainingType end
purpose(::Type{LossModelObsML}) = "Loss function using metrics between the predicted model and observation as defined in optimization.json"


# Folds
export CalcFoldFromSplit
export LoadFoldFromFile

struct CalcFoldFromSplit <: MLTrainingType end
purpose(::Type{CalcFoldFromSplit}) = "Use a split of the data to calculate the folds for cross-validation. The default wat to calculate the folds is by splitting the data into k-folds. In this case, the split is done on the go based on the values given in ml_training.split_ratios and n_folds."

struct LoadFoldFromFile <: MLTrainingType end
purpose(::Type{LoadFoldFromFile}) = "Use precalculated data to load the folds for cross-validation. In this case, the data path has to be set under ml_training.fold_path and ml_training.which_fold. The data has to be in the format of a jld2 file with the following structure: /folds/0, /folds/1, /folds/2, ... /folds/n_folds. Each fold has to be a tuple of the form (train_indices, test_indices)."

## Machine Learning Model Types
export MLModelType
export FluxDenseNN

abstract type MLModelType <: MLTypes end
purpose(::Type{MLModelType}) = "Abstract type for machine learning models used in SINDBAD"

struct FluxDenseNN <: MLModelType end
purpose(::Type{FluxDenseNN}) = "simple dense neural network model implemented in Flux.jl"

## Optimizers
export MLOptimizerType
export OptimisersAdam
export OptimisersDescent

abstract type MLOptimizerType <: MLTypes end
purpose(::Type{MLOptimizerType}) = "Abstract type for optimizers used for training ML models in SINDBAD"

struct OptimisersAdam <: MLOptimizerType end
purpose(::Type{OptimisersAdam}) = "Use Optimisers.jl Adam optimizer for training ML models in SINDBAD"

struct OptimisersDescent <: MLOptimizerType end
purpose(::Type{OptimisersDescent}) = "Use Optimisers.jl Descent optimizer for training ML models in SINDBAD"

## Activation functions
export ActivationType
export FluxRelu
export FluxSigmoid
export FluxTanh
export CustomSigmoid

abstract type ActivationType <: MLTypes end
purpose(::Type{ActivationType}) = "Abstract type for activation functions used in ML models"

struct FluxRelu <: ActivationType end
purpose(::Type{FluxRelu}) = "Use Flux.jl ReLU activation function"

struct FluxSigmoid <: ActivationType end
purpose(::Type{FluxSigmoid}) = "Use Flux.jl Sigmoid activation function"

struct FluxTanh <: ActivationType end
purpose(::Type{FluxTanh}) = "Use Flux.jl Tanh activation function"

struct CustomSigmoid <: ActivationType end
purpose(::Type{CustomSigmoid}) = "Use a custom sigmoid activation function. In this case, the `k_σ` parameter in ml_model sections of the settings is used to control the steepness of the sigmoid function."