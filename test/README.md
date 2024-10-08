# What are we testing for here?

## For Models

1. Proper subtyping of model structs.
2. Allocations. It should be **ZERO** for core models.
3. The expected result for packed variables (your variables at the @pack_nt step). Is the Math correct?
- More? suggestions welcome.

Note that this done for just `one time step`.