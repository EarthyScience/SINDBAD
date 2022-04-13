export gppSoilW_CASA, gppSoilW_CASA_h
"""
initialized in teh preallocation function. is not VPD effect; is the ET/PET effect if Tair <= 0.0 | PET <= 0.0; use the previous stress index otherwise; compute according to CASA

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppSoilW_CASA{T1} <: gppSoilW
	Bwe::T1 = 0.5 | nothing | "CASA We" | ""
end

function precompute(o::gppSoilW_CASA, forcing, land, infotem)
	# @unpack_gppSoilW_CASA o
	return land
end

function compute(o::gppSoilW_CASA, forcing, land, infotem)
	@unpack_gppSoilW_CASA o

	## unpack variables
	@unpack_land begin
		Tair ∈ forcing
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

	## pack variables
	@pack_land begin
		(OmBweOPET, SMScGPP) ∋ land.gppSoilW
	end
	return land
end

function update(o::gppSoilW_CASA, forcing, land, infotem)
	# @unpack_gppSoilW_CASA o
	return land
end

"""
initialized in teh preallocation function. is not VPD effect; is the ET/PET effect if Tair <= 0.0 | PET <= 0.0; use the previous stress index otherwise; compute according to CASA

# Extended help
"""
function gppSoilW_CASA_h end