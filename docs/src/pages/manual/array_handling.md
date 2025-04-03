# SINDBAD Vector and Matrix Functions

Using these functionalities inside the SINDBAD models to main performance. Note that under development model can still use other methods, as long as there are no performance bottlenecks.


## `repElem`

Replace an element of a vector or static vector with a new value.

```julia
v = [1.0, 2.0, 3.0]
v = repElem(v, 10.0, nothing, nothing, 2) # Replace the second element with 10.0
```

## @rep_elem
Macro to simplify replacing an element of a **vector that is defined in land.pools**.

```julia
@rep_elem pout[l] ⇒ (cEco, lc, :cEco)
```

::: info
Note that the macro call @rep_elem just translate the code to repElem call during compile time. You can check the expansion as

```julia
@macroexpand @rep_elem pout[l] ⇒ (cEco, lc, :cEco)
```
:::

## addToElem
Add a value to a specific element of a vector or static vector.

```julia
v = [1.0, 2.0, 3.0]
v = addToElem(v, 5.0, nothing, 2) # Add 5.0 to the second element
```

## @add_to_elem
Macro to simplify adding a value to an element of a **vector that is defined in land.pools**.

```julia
    @add_to_elem -evaporation ⇒ (ΔsoilW, 1, :soilW)
```

## addVec

Add two vectors element-wise.

## repVec
Replace the values of a vector with a new vector. Also, check `@rep_vec`

## cumSum!
Compute the cumulative sum of elements in an input vector and store the result in an output vector.

## getFrac
Return either a ratio or numerator depending on whether the denominator is zero.

## getZix
A helper function to get the indices of certain component, e.g., cVeg, within the larger vector of ecosystem pools cEco.
