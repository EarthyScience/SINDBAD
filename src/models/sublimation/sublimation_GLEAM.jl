export sublimation_GLEAM

@bounds @describe @units @with_kw struct sublimation_GLEAM{T1} <: sublimation
	α::T1 = 0.95 | (0.0, 3.0) | "Priestley Taylor Coefficient for Sublimation" | "none"
end

function compute(o::sublimation_GLEAM, forcing, land, infotem)
	## unpack parameters and forcing
	@unpack_sublimation_GLEAM o
	@unpack_forcing (PsurfDay, Rn, TairDay) ∈ forcing


	## unpack land variables
	@unpack_land begin
		snowFraction ∈ land.states
		snowW ∈ land.pools
	end
	# convert temperature to Kelvin
	T = TairDay + 273.15

	# from Diego miralles: The majority of the parameters I use in GLEAM come from the equations in Murphy & Koop [2005] here attached. The slope of the vapour pressure over ice versus temperature curve (Δ) is obtained from eq. (7). You may want to do this derivative yourself because my calculus is not as good as it used to; what I get is:
	
	Δ = (5723.265 / T ^ 2.0 + 3.53068 / (T-0.00728332)) * exp(9.550426-5723.265 / T + 3.53068 * log(T) - 0.00728332 * T)

	# That you can convert from [Pa/K] to [kPa/K] by multiplying times 0.001.
	Δ = Δ * 0.001
	
	# The latent heat of sublimation of ice [λ] can be found in eq. (5):
	λ = 46782.5 + 35.8925 * T - 0.07414 * T ^ 2.0 + 541.5 * exp(-(T / 123.75) ^ 2)
	
	# To convert from [J/mol] to [MJ/kg] I assume a molecular mass of water of
	# 18.01528 g/mol:
	λ = λ * 0.000001 / (18.01528 * 0.001)
	
	# Then the psychrometer "constant" (γ) can be calculated in [kPa/K] according to Brunt [1952] as: Where P is the air pressure in [kPa], which I consider as a function of the elevation [DEM] but can otherwise be set to 101.3, & ca is the specific heat of air which I assume 0.001 MJ/kg/K.
	# ca = 101.3
	pa = 0.001; #MJ/kg/K
	γ = PsurfDay * pa / (0.622 * λ)

	#PTterm = (fei.Δ / (fei.Δ+fei.γ)) / fei.λ
	tmp = α * Rn * (Δ / (Δ + γ)) / λ

	PTtermSub = max(tmp, infotem.helpers.zero)
	# PTterm = (fei.Δ / (fei.Δ+fei.γ)) / fei.λ

	# Then sublimation [mm/day] is calculated in GLEAM using a P.T. equation
	sublimation = min(snowW, PTtermSub * snowFraction)

	## pack land variables
	@pack_land begin
		sublimation => land.fluxes
		PTtermSub => land.sublimation
	end
	return land
end

function update(o::sublimation_GLEAM, forcing, land, infotem)
	@unpack_sublimation_GLEAM o

	## unpack variables
	@unpack_land begin
		snowW ∈ land.pools
		sublimation ∈ land.fluxes
	end

	# update snow pack
	snowW[1] = snowW[1] - sublimation

	## pack land variables
	@pack_land snowW => land.pools
	return land
end

@doc """
precomputes the Priestley-Taylor term for sublimation following GLEAM. computes sublimation following GLEAM

# Parameters
$(PARAMFIELDS)

---

# compute:
Calculate sublimation and update snow water equivalent using sublimation_GLEAM

*Inputs*
 - forcing.PsurfDay : atmospheric pressure during the daytime [kPa]
 - forcing.Rn : net radiation [MJ/m2/time]
 - forcing.TairDay : daytime temperature [C]
 - land.states.snowFraction: snow cover fraction []
 - land.sublimation.PTtermSub: Priestley-Taylor term [mm/MJ]
 - α: α coefficient for sublimation

*Outputs*
 - land.fluxes.sublimation: sublimation [mm/time]

# update

update pools and states in sublimation_GLEAM

 -
 - land.pools.snowW: snow pack [mm]

---

# Extended help

*References*
 - Miralles; D. G.; De Jeu; R. A. M.; Gash; J. H.; Holmes; T. R. H.  & Dolman, A. J. (2011). An application of GLEAM to estimating global evaporation.  Hydrology & Earth System Sciences Discussions, 8[1].

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - mjung
"""
sublimation_GLEAM