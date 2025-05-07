export cAllocationRadiation_RgPot


struct cAllocationRadiation_RgPot <: cAllocationRadiation end

function define(params::cAllocationRadiation_RgPot, forcing, land, helpers)
    @unpack_nt f_rg_pot ⇐ forcing
	rg_pot_max = maxZero(f_rg_pot)
    @pack_nt (rg_pot_max) ⇒ land.cAllocationRadiation
	return land
end

function compute(params::cAllocationRadiation_RgPot, forcing, land, helpers)
    @unpack_nt begin
		f_rg_pot ⇐ forcing
		rg_pot_max ⇐ land.cAllocationRadiation
	end

	rg_pot_max = max(rg_pot_max, f_rg_pot)

	c_allocation_f_cloud = f_rg_pot / rg_pot_max

	@pack_nt begin
		c_allocation_f_cloud ⇒ land.diagnostics
		rg_pot_max ⇒ land.diagnostics
	end 
	return land
end

purpose(::Type{cAllocationRadiation_RgPot}) = "radiation effect on allocation using potential radiation instead of actual one"

@doc """ 

	$(getBaseDocString(cAllocationRadiation_RgPot))

---

# Extended help

*References*

*Versions*
 - 1.0 on 07.05.2025 [skoirala]

*Created by*
 - skoirala

"""
cAllocationRadiation_RgPot

