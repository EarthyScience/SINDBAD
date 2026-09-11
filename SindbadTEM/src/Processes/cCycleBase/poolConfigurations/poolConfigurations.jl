export CarbonPoolConfiguration
export cFlowEdges
export TAU_DORMANT

"""
    CarbonPoolConfiguration

Abstract supertype of the carbon pool configurations: the pool structure a
`cCycleBase` approach is written against, together with any aliases that structure
needs. Each configuration's file also centralizes that structure's own fixed
per-pool defaults an approach reads rather than declares inline -- turnover time
(`GSI_TAU_DEFAULT`/`GSI_TAU_PLANTFORM`/`MGMT_TAU`/`CASA_TAU`) and vegetation
carbon-to-nitrogen ratio (`GSI_CN_ratio`/`CASA_CN_ratio`) today, alongside the
flow-edge topology (`GSI_FLOW_EDGES`/`CASA_FLOW_EDGES`) that was already here.

An approach names its configuration with `poolConfiguration`, and the configuration
answers `poolStructure` and `poolAliases`.

# Notes:
- One file per configuration, in this directory, listed at the bottom of this file.
  This file holds only what they share: the supertype, the defaults, and the machinery
  that resolves a declared edge list against a concrete structure. A new structure is a
  new file plus a line in that list.
- `cCycleBase.jl` includes this file explicitly. `includeApproaches` globs
  `cCycleBase_*.jl` in the directory above and does not descend, so it skips the folder.
- Configurations subtype `SindbadTypes`, deliberately not `cCycleBase`. Approach
  enumeration is driven by `subtypes(cCycleBase)` and `subtypes(LandEcosystem)` in
  five places: the generated "# Approaches" docstring list, the variable catalog, the
  approaches list, and approach validation. A configuration has no `define` and no
  parameters, so registering as an approach would surface it as a broken one.
- `subtypes(CarbonPoolConfiguration)` is what enumerates the structures, so a
  configuration file that is written but never included is invisible everywhere,
  including in the pool-name skeleton `setPoolsInfo` builds.
"""
abstract type CarbonPoolConfiguration <: SindbadTypes end
purpose(::Type{CarbonPoolConfiguration}) = "Abstract type for the carbon pool structures that cCycleBase approaches are written against"

"""
    TAU_DORMANT

Shared placeholder turnover *time* (years) for a pool that, by design, effectively
never decays -- a `(0.25, 4.0)`-bounded scalar could never scale a rate derived
from this back up to anything physically meaningful, so it exists purely to make
"this pool is dormant" explicit and consistent wherever it's needed, rather than
each configuration re-choosing its own large number.

Used for the GSI-family vegetation Reserve pool (`GSI_TAU_DEFAULT`, hence every
`GSI_TAU_PLANTFORM` entry that inherits it), the `unknown` plant-form's full table
(`GSI_TAU_PLANTFORM.unknown`), and `MGMT_TAU`'s structural-completeness
`cProductsWood`/`cProductsCrop` placeholders (`poolConfigurations/MGMT.jl`).
"""
const TAU_DORMANT = 1.0e11

"""
    poolAliases(configuration)

Extra `zix` names a configuration needs that its nesting cannot produce, `(;)` unless
the configuration declares otherwise.

Only `CarbonPoolsCASA` declares any: its litter nests by organ, so the fast/slow
quality split cuts across the hierarchy. Every other structure nests litter by quality
already and generates those names directly.
"""
poolAliases(::Type{<:CarbonPoolConfiguration}) = (;)

"""
    cFlowEdges(T)

Return the pool-to-pool carbon flow edges of an approach as `giver => taker` pairs,
or `()` if it declares none.

# Notes:
- Topology is an approach property rather than a pool-structure one: a base that adds
  or drops a link declares its own list, without a new configuration. The lists
  themselves sit in the configuration files even so, because an edge list is written in
  the pool names of one structure and resolves against no other: `GSI_FLOW_EDGES` in
  `GSI.jl`, `CASA_FLOW_EDGES` in `CASA.jl`. Which approach uses which is still declared
  by the approach.
- An edge list rather than a transfer matrix, because the matrix carried no
  information beyond the adjacency. `cFlowMatrix` rebuilds the matrix view from an
  edge list when one is wanted, in the `[taker, giver]` orientation every dense flow
  array in the models uses. Every `c_flow_A_array` in every `cCycleBase`
  approach held only `{-1, 0, 1}`, and every consumer tested positivity alone, so it
  was a dense encoding of a sparse graph: 64 numbers to say 11 things under GSI, 196
  to say 22 under CASA.
- Listed in flow-vector order: all edges leaving the first giver pool, ordered by
  taker index, then all edges leaving the second, and so on. Nothing depends on it,
  since `cFlowStructure` sorts by `(giver, taker)` whatever the declaration order,
  but reading a declaration against a `d_cFlow` output is far easier when the two
  agree.
- Edges must name leaf pools, never groups. `zix` is keyed by group names as well as
  leaf names, so an edge naming a group would silently expand to a cross product,
  `:cVeg => :cLit` becoming 4x2 entries. CASA is why this matters: `cVegRootFine` feeds
  `cLitRootFineFast` and `cLitRootFineSlow` while `cVegRootCoarse` feeds only `cLitRootCoarse`, so a
  group-level `cVegRoot => cLitFast` would invent links that do not exist.
  `cFlowStructure` rejects both mistakes.
"""
function cFlowEdges end

cFlowEdges(::Type{<:cCycleBase}) = ()
cFlowEdges(T::cCycleBase) = cFlowEdges(typeof(T))

"""
    cFlowStructure(params::cCycleBase, cEco, helpers)

Resolve an approach's `cFlowEdges` against the pool structure the experiment actually
configured, returning the whole flow-vector description as
`(c_flow_order, c_taker, c_giver, c_flow_named_edges, c_flow_A_vec, c_flow_QP_vec,
c_flow_ME_vec)`, in the order the approaches pack it.

# Notes:
- A flow is an edge, so the taker and giver of flow `i` are just the two endpoints of
  edge `i` resolved to indices, and `c_flow_order` is `1:number of edges`. There is no
  transfer matrix in between: the old `c_flow_A_array` existed only to be walked back
  out by `findall`, and its one remaining reader, `cCycleConsistency_simple`, asks
  only whether a flow sits above or below the diagonal, which is `c_taker` against
  `c_giver`.
- All seven come from one call so they cannot disagree about how many flows there are
  or what order they sit in, which is what an approach rederiving each of them
  separately from a matrix left open. `c_flow_named_edges` is the same topology keyed
  by pool-name pair rather than by position, built by `cFlowNamedEdges`.
- `c_flow_A_vec`, `c_flow_QP_vec` and `c_flow_ME_vec` are neutral, one per flow, and
  are built here rather than in a `cFlow`, `cQualityPartition` or
  `cMicrobialEfficiency` approach for the same reason: their length and order are the
  topology's, so an approach building one had to reach for `c_taker` to re-measure
  what the base already knows. Those approaches fill in values; they no longer decide
  the shape. Allocating here also means the neutral value of one exists whenever the
  topology does, so `cCycle` reads a valid `c_flow_QP_vec` and `c_flow_ME_vec` even
  when no `cQualityPartition` or `cMicrobialEfficiency` model is selected at all.
- Sorted by `(giver, taker)`, which is the column-major order `findall` produced from
  the matrix and which `c_flow_A_vec`, `c_flow_QP_vec`, `c_flow_ME_vec` and the
  `d_cFlow` output dimension are all indexed by. Column-major means the giver is the
  column, so a flow matrix rebuilt from this is `[taker, giver]`; see `cFlowMatrix`. Sorting here rather than trusting the
  declaration means an edge list written out of order still yields the same flow
  vector; the lists are kept in that order anyway so a declaration reads in the same
  order as the flows it produces.
- This is where an edge list first meets a concrete structure, so the checks live
  here: an edge naming a pool the structure lacks, an edge naming a group or alias
  rather than a leaf pool, which would otherwise expand silently into a cross
  product, and a duplicated edge, which the matrix used to swallow into one flow.
"""
function cFlowStructure(params::cCycleBase, cEco, helpers)
    edges = cFlowEdges(typeof(params))
    givers = [cFlowEdgeIndex(params, helpers, first(edge), edge) for edge ∈ edges]
    takers = [cFlowEdgeIndex(params, helpers, last(edge), edge) for edge ∈ edges]
    flows = collect(zip(givers, takers))
    if length(unique(flows)) < length(flows)
        repeated = unique([edges[i] for i ∈ findall(flow -> count(==(flow), flows) > 1, flows)])
        error("$(nameof(typeof(params))) declares the carbon flow edge(s) " *
              "$(repeated) more than once. Each giver to taker link carries one flow, " *
              "so list it once.")
    end
    order = sortperm(flows)
    c_taker = Tuple(takers[order])
    c_giver = Tuple(givers[order])
    c_flow_order = ntuple(identity, length(order))
    c_flow_named_edges = cFlowNamedEdges(c_taker, c_giver, helpers.pools.components.cEco)
    c_flow_A_vec = getVectorOfType(cEco, length(c_taker), one)
    c_flow_QP_vec = getVectorOfType(cEco, length(c_taker), one)
    c_flow_ME_vec = getVectorOfType(cEco, length(c_taker), one)
    return c_flow_order, c_taker, c_giver, c_flow_named_edges, c_flow_A_vec, c_flow_QP_vec,
        c_flow_ME_vec
end

"""
    cFlowEdgeIndex(params, helpers, pool_name, edge)

Resolve one end of a flow edge to the single `cEco` index it names, erroring with the
offending name when it resolves to no pool or to more than one.
"""
function cFlowEdgeIndex(params, helpers, pool_name, edge)
    approach = nameof(typeof(params))
    if !hasproperty(helpers.pools.zix, pool_name)
        error("$(approach) declares the carbon flow edge `$(edge)`, but `$(pool_name)` is not a " *
              "known carbon pool name: no carbon pool configuration declares it. Correct the " *
              "edge, or declare the pool in a configuration's poolStructure.")
    end
    zix = getproperty(helpers.pools.zix, pool_name)
    if isempty(zix)
        error("$(approach) declares the carbon flow edge `$(edge)`, but the configured pool " *
              "structure has no `$(pool_name)`. Use a pool structure that has it, or an approach " *
              "whose edges match this structure.")
    end
    if length(zix) > 1
        error("$(approach) declares the carbon flow edge `$(edge)`, but `$(pool_name)` spans " *
              "$(length(zix)) pools ($(zix)). Flow edges must name leaf pools, not groups or " *
              "aliases, because a group would expand into a cross product of links. List the " *
              "individual edges instead.")
    end
    return only(zix)
end

"""
    cFlowNamedEdges(c_taker, c_giver, cEco_components)

Bucket the flow-vector positions by the `(giver, taker)` pool-name pair they connect,
as `<giver>_to_<taker> => (positions...)`.

`cFlow` approaches need to find "the entry that carries leaf shedding" without
knowing which index that is. They used to rederive it themselves by matching
component names and taking `findall(...)[1]`, which silently kept only the first
match wherever a name spans more than one `cEco` slot. Resolving it once here, as a
tuple of every match, removes the duplication and the truncation together: the caller
loops over the tuple instead of writing a single element.

A pair the topology does not contain is simply absent, so reading it fails at
`define` naming the missing edge rather than at a `BoundsError` on an empty
`findall`.
"""
function cFlowNamedEdges(c_taker, c_giver, cEco_components)
    edge_names = Symbol[]
    edge_positions = Vector{Int}[]
    for flow ∈ eachindex(c_taker, c_giver)
        edge = Symbol(String(cEco_components[c_giver[flow]]) * "_to_" *
                      String(cEco_components[c_taker[flow]]))
        known = findfirst(==(edge), edge_names)
        if isnothing(known)
            push!(edge_names, edge)
            push!(edge_positions, [flow])
        else
            push!(edge_positions[known], flow)
        end
    end
    return NamedTuple{Tuple(edge_names)}(Tuple(Tuple.(edge_positions)))
end

"""
    applyPoolTable(c_eco, table, scalar, helpers)

Multiply each pool in `table` (a per-pool-name `NamedTuple` mapping to a turnover
*time*, e.g. `GSI_TAU_DEFAULT`/`CASA_TAU`) by `one(T) / T(value) * scalar`, `T` being
`eltype(c_eco)`, writing the result into `c_eco` at that pool's `cEco` index via
`repElem`, and return the updated `c_eco`. `scalar` is either one value applied to
every pool (`cCycleBase_CASA`'s single `k_c_scalar`) or a per-pool-name `NamedTuple`
with the same keys as `table` (`cCycleBase_GSI`'s `k_c_scalars`, one shared scalar
per organ/pool group), dispatched on `scalar`'s type.

# Notes:
- The explicit `T(value)` conversion is not cosmetic: `table`'s entries are `Float64`
  literals (`GSI_TAU_DEFAULT`/`CASA_TAU` are defined once, independent of any
  approach's working precision), but `c_eco` and `scalar` are typically `Float32` in
  a model configured that way. Without converting, `one(turnover_time) /
  turnover_time` (an untouched `Float64`) times a `Float32` `scalar` promotes to
  `Float64`, and writing that into an `SVector{N,Float32}` via `repElem` silently
  upgrades the *whole array* to `Float64` on the very first loop iteration -- so the
  loop's accumulator has one type on iteration 1 and another from iteration 2 on,
  which Julia's inference reports as this function returning
  `Union{SVector{N,Float32}, SVector{N,Float64}}`, not a concrete type. Converting
  `table`'s value to `eltype(c_eco)` up front keeps every iteration in the same
  precision as the array being built, closing that union.
- Exists as its own function, not inlined into each approach's `precompute`, so a
  type instability in this loop (present or future) cannot silently widen the whole
  `land` structure `precompute` returns -- inference failing here fails loudly on
  this function's own, much smaller signature instead. This also keeps the
  table-driven loop itself out of `precompute`'s already substantial body (unpacking
  a dozen struct fields, unpacking and repacking several `land` namespaces), rather
  than adding to it.
- Used identically by `cCycleBase_GSI`, `cCycleBase_GSI_PlantForm`,
  `cCycleBase_GSI_PlantForm_MGMT` (`c_eco_τ`, per-pool `k_c_scalars`) and
  `cCycleBase_CASA` (`c_eco_k_base`, the single `k_c_scalar`) -- the target array's
  name and whether the scalar varies by pool differ by approach, the loop does not.
"""
function applyPoolTable(c_eco, table, scalar::Real, helpers)
    T = eltype(c_eco)
    for (pool_name, turnover_time) in pairs(table)
        for ix in getproperty(helpers.pools.zix, pool_name)
            tmp = (one(T) / T(turnover_time)) * scalar
            c_eco = repElem(c_eco, tmp, helpers.pools.zeros.cEco, helpers.pools.ones.cEco, ix)
        end
    end
    return c_eco
end
function applyPoolTable(c_eco, table, scalar_for::NamedTuple, helpers)
    T = eltype(c_eco)
    for (pool_name, turnover_time) in pairs(table)
        scalar = getproperty(scalar_for, pool_name)
        for ix in getproperty(helpers.pools.zix, pool_name)
            tmp = (one(T) / T(turnover_time)) * scalar
            c_eco = repElem(c_eco, tmp, helpers.pools.zeros.cEco, helpers.pools.ones.cEco, ix)
        end
    end
    return c_eco
end

"""
    applyPoolCNTable(C_to_N_cVeg, table, cn_scalar, helpers)

Same idea as `applyPoolTable`, for the vegetation carbon-to-nitrogen ratio: multiplies
each `table` (`GSI_CN_ratio`/`CASA_CN_ratio`) entry by `cn_scalar` directly, no
turnover-time inversion, writing into `C_to_N_cVeg`. Every `cCycleBase` approach
applies one shared `CN_ratio_scalar` across all pools, so unlike `applyPoolTable` this
has only the single-scalar form. Kept as its own function, separate from
`applyPoolTable`, since the two write different target arrays for a different
physical quantity even though the loop shape matches -- but for the same
type-stability reason (see `applyPoolTable`'s notes), it must remain its own function
barrier rather than get inlined into `precompute`.
"""
function applyPoolCNTable(C_to_N_cVeg, table, cn_scalar, helpers)
    T = eltype(C_to_N_cVeg)
    for (pool_name, c_to_n) in pairs(table)
        for ix in getproperty(helpers.pools.zix, pool_name)
            tmp = T(c_to_n) * cn_scalar
            C_to_N_cVeg = repElem(C_to_N_cVeg, tmp, helpers.pools.zeros.cEco, helpers.pools.ones.cEco, ix)
        end
    end
    return C_to_N_cVeg
end

# One file per pool structure, listed rather than globbed so only files meant to load
# do. New structure: add the file, add it here. Included last, so the supertype and the
# defaults above are already defined.
include("GSI.jl")
include("MGMT.jl")
include("CASA.jl")
