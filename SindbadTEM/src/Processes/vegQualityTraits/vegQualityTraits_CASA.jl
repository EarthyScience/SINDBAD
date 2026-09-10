export vegQualityTraits_CASA

#! format: off
@bounds @describe @units @timescale @with_kw struct vegQualityTraits_CASA{T1,T2,T3,T4,T5,T6,T7,T8} <: vegQualityTraits
    lit_frac_metabolic_A::T1 = 0.85 | (0.0, 1.0) | "intercept of the metabolic litter fraction at zero lignin-to-nitrogen ratio" | "fraction" | ""
    lit_frac_metabolic_B::T2 = 0.018 | (0.0, 0.1) | "sensitivity of the metabolic litter fraction to the lignin-to-nitrogen ratio" | "fraction" | ""
    lit_nonsol_to_sol_lignin::T3 = 2.22 | (1.0, 5.0) | "scalar converting nonsoluble to soluble lignin" | "fraction" | ""
    lit_frac_lignin_per_PFT::T4 = Float64.([0.2, 0.2, 0.22, 0.25, 0.2, 0.15, 0.1, 0.0, 0.2, 0.15, 0.15, 0.1]) | (0.0, 1.0) | "fraction of litter that is lignin, per PFT class" | "fraction" | ""
    lit_C_to_N_per_PFT::T5 = Float64.([40.0, 50.0, 65.0, 80.0, 50.0, 50.0, 50.0, 0.0, 65.0, 50.0, 50.0, 40.0]) | (0.0, 150.0) | "carbon-to-nitrogen ratio of litter, per PFT class" | "gC/gN" | ""
    lit_frac_C_lignin::T6 = 0.65 | (0.0, 1.0) | "carbon fraction of lignin" | "fraction" | ""
    lit_k_f_lignin_A::T7 = 3.0 | (0.0, 10.0) | "sensitivity of the structural litter decomposition rate to the structural lignin fraction" | "" | ""
    lit_frac_lignin_wood::T8 = 0.4 | (0.0, 1.0) | "lignin fraction of woody litter" | "fraction" | ""
end
#! format: on

function precompute(params::vegQualityTraits_CASA, forcing, land, helpers)
    ## unpack parameters
    @unpack_vegQualityTraits_CASA params

    ## unpack land variables
    @unpack_nt begin
        PFT ⇐ land.states
        o_one ⇐ land.constants
    end

    ## calculate variables
    # Select the litter chemistry of the PFT class of this pixel. PFT is a
    # one-based class index, so it is clamped to the length of the per-PFT
    # vectors rather than trusted blindly.
    ipft = clamp(round(Int, PFT), 1, length(lit_frac_lignin_per_PFT))
    lit_C_to_N = lit_C_to_N_per_PFT[ipft]
    lit_frac_lignin = lit_frac_lignin_per_PFT[ipft]

    # lignin-to-nitrogen ratio of litter
    lignin_to_N = (lit_C_to_N * lit_frac_lignin) * lit_nonsol_to_sol_lignin

    # the metabolic fraction of litter decreases linearly with the
    # lignin-to-nitrogen ratio
    lit_frac_metabolic = clamp_zero_one(lit_frac_metabolic_A - lit_frac_metabolic_B * lignin_to_N)

    # lignin is present only in the structural litter fraction, so the lignin
    # content of litter is rescaled by the structural fraction of litter,
    # 1 - lit_frac_metabolic
    lit_frac_lignin_struct = clamp_zero_one(
        (lit_frac_lignin * lit_frac_C_lignin * lit_nonsol_to_sol_lignin) /
        (o_one - lit_frac_metabolic))

    # effect of lignin content on the decomposition rate of the structural
    # litter pools
    lit_k_f_lignin = exp(-lit_k_f_lignin_A * lit_frac_lignin_struct)

    ## pack land variables
    @pack_nt begin
        (lit_C_to_N, lit_frac_lignin, lit_frac_metabolic, lit_nonsol_to_sol_lignin) ⇒ land.properties
        (lit_frac_C_lignin, lit_frac_lignin_struct, lit_frac_lignin_wood, lit_k_f_lignin) ⇒ land.properties
    end
    return land
end

purpose(::Type{vegQualityTraits_CASA}) = "Metabolic litter fraction and the structural lignin fraction, with PFT-dependent litter chemistry, and the lignin effect on decomposition rate, as modeled in CASA."

@doc """

	$(getModelDocString(vegQualityTraits_CASA))

---

# Extended help

The approach looks up the lignin fraction and the carbon-to-nitrogen ratio of
litter for the PFT class in `land.states.PFT`, forms the lignin-to-nitrogen
ratio

`lignin_to_N = lit_C_to_N * lit_frac_lignin * lit_nonsol_to_sol_lignin`

and computes

`lit_frac_metabolic = clamp_zero_one(lit_frac_metabolic_A - lit_frac_metabolic_B * lignin_to_N)`

Lignin-rich, nitrogen-poor litter therefore yields a smaller metabolic fraction
and a larger structural fraction. Lignin is present only in that structural
fraction, so it is rescaled by `1 - lit_frac_metabolic` to give the structural
lignin fraction:

`lit_frac_lignin_struct = clamp_zero_one(lit_frac_lignin * lit_frac_C_lignin * lit_nonsol_to_sol_lignin / (1 - lit_frac_metabolic))`

`lit_k_f_lignin = exp(-lit_k_f_lignin_A * lit_frac_lignin_struct)`

This used to be two approaches, `metabolicFraction_CASA` and `lignin_CASA`, with the
second reading the first's output back from `land.properties`. Merged into one so the
per-PFT litter chemistry and the lignin effect it drives are always computed
consistently, with no dependency on a matching separate selection.

This replaces the metabolic-fraction and lignin parts of the legacy
`cTauVegProperties_CASA`, where `MTF` was clipped with a MATLAB-style logical index
that never ran in Julia; `clamp_zero_one` also bounds the fraction above, which the
original did not.

*References*
 - Carvalhais, N., Reichstein, M., Seixas, J., Collatz, G. J., Pereira, J. S., Berbigier, P., & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for biogeochemical modeling performance and inverse parameter retrieval. Global Biogeochemical Cycles, 22(2).
 - Potter, C. S., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., & Kumar, V. (2003). Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data and ecosystem modeling 1982-1998. Global and Planetary Change, 39(3-4), 201-213.
 - Potter, C. S., Randerson, J. T., Field, C. B., Matson, P. A., Vitousek, P. M., Mooney, H. A., & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global satellite and surface data. Global Biogeochemical Cycles, 7(4), 811-841.

*Versions*
 - 1.0 on 04.09.2026 [skoirala]: extracted from cTauVegProperties_CASA, as separate metabolicFraction_CASA and lignin_CASA approaches
 - 2.0 on 09.09.2026 [skoirala]: merged metabolicFraction_CASA and lignin_CASA into vegQualityTraits_CASA

*Created by*
 - ncarvalhais

"""
vegQualityTraits_CASA
