export snowFraction_binary

struct snowFraction_binary <: snowFraction
end

function compute(o::snowFraction_binary, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		snowW ∈ land.pools
		(𝟘, 𝟙) ∈ helpers.numbers
        ΔsnowW ∈ land.states
	end
	# if there is snow; then snow fraction is 1; otherwise 0
	snowFraction = 𝟙 * (sum(snowW + ΔsnowW) > 𝟘)

	## pack land variables
	@pack_land snowFraction => land.states
	return land
end

@doc """
compute the fraction of snow cover.

---

# compute:
Calculate snow cover fraction using snowFraction_binary

*Inputs*
 - land.rainSnow.snow : snow fall [mm/time]

*Outputs*
 - land.states.snowFraction: sets snowFraction to 1 if there is snow; to 0 if there  is now snow

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - mjung
"""
snowFraction_binary