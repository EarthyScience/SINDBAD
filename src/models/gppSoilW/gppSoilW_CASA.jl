export gppSoilW_CASA

@bounds @describe @units @with_kw struct gppSoilW_CASA{T1} <: gppSoilW
	Bwe::T1 = 0.5 | nothing | "CASA We" | ""
end

function compute(o::gppSoilW_CASA, forcing, land, helpers)
	## unpack parameters and forcing
	@unpack_gppSoilW_CASA o
	@unpack_forcing Tair ∈ forcing


	## unpack land variables
	@unpack_land begin
		SMScGPP_prev ∈ land.gppSoilW
		transpiration ∈ land.fluxes
		PET ∈ land.PET
	end
	pBwe = Bwe
	OmBweOPET = NaN
	ndx = Tair > 0.0 & PET > 0.0
	OmBweOPET[ndx] = (1.0 - pBwe[ndx]) / PET[ndx]
	SMScGPP = 1.0; #-> should be
	We = SMScGPP_prev
	ndx = Tair > 0.0 & PET > 0.0
	We[ndx] = Bwe[ndx, 1] + OmBweOPET[ndx, tix] * transpiration.transpiration[ndx, tix]
	SMScGPP = We

	## pack land variables
	@pack_land (OmBweOPET, SMScGPP) => land.gppSoilW
	return land
end

@doc """
initialized in teh preallocation function. is not VPD effect; is the ET/PET effect if Tair <= 0.0 | PET <= 0.0; use the previous stress index otherwise; compute according to CASA

# Parameters
$(PARAMFIELDS)

---

# Extended help
"""
gppSoilW_CASA