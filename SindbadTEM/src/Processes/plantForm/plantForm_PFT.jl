export plantForm_PFT


struct plantForm_PFT <: plantForm end


function define(params::plantForm_PFT, forcing, land, helpers)
	## PFT-name groupings, keyed by the canonical PFT vocabulary
	## (PFTCatalog_SINDBAD_PFT) rather than any one source's raw codes, so this
	## approach works unchanged no matter which PFT_forcing_*/PFT_constant_*
	## produced land.states.PFT. Reproduces the same tree/shrub/herb split the
	## original numeric-code version used (1:5,8,9 / 6:7 / 10,11,12,14), now by
	## name instead of by magic number.
	plant_form_pft = (;
		tree  = (:Evergreen_Needleleaf_Forests, :Evergreen_Broadleaf_Forests,
		         :Deciduous_Needleleaf_Forests, :Deciduous_Broadleaf_Forests,
		         :Mixed_Forests, :Woody_Savannas, :Savannas),
		shrub = (:Closed_Shrublands, :Open_Shrublands),
		herb  = (:Grasslands, :Permanent_Wetlands, :Croplands,
		         :Cropland_Natural_Vegetation_Mosaics),
	)
	@pack_nt plant_form_pft ⇒ land.plantForm
	return land
end


function precompute(params::plantForm_PFT, forcing, land, helpers)
	## unpack land variables
	@unpack_nt PFT ⇐ land.states
	@unpack_nt plant_form_pft ⇐ land.plantForm

	plant_form = :unknown
	for (pf_key, pf_names) in pairs(plant_form_pft)
		if PFT in pf_names
			plant_form = pf_key
			break
		end
	end
	@pack_nt plant_form ⇒ land.states
	return land
end

purpose(::Type{plantForm_PFT}) = "Differentiate plant form based on PFT."

@doc """ 

	$(getModelDocString(plantForm_PFT))

---

# Extended help

Groups `land.states.PFT` into `:tree`/`:shrub`/`:herb` using the canonical
PFT names (`PFTCatalog_SINDBAD_PFT`), so this approach needs no knowledge of
which forcing/constant source produced that name. Any PFT class outside the
three groups (`Water_Bodies`, `Urban_and_Built_up_Lands`,
`Permanent_Snow_and_Ice`, `Barren`) resolves to `:unknown`.

*References*

*Versions*
 - 1.0 on 24.04.2025 [skoirala]
 - 2.0 on 10.09.2026 [skoirala]: keyed by canonical PFT names instead of raw
   numeric codes, so this approach is no longer tied to one forcing source's
   numbering; grouping is otherwise unchanged from the original numeric-code
   version

*Created by*
 - skoirala

"""
plantForm_PFT

