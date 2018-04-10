counters inside functions, that are inside the core, should be named ii

checks on allocation
    has to give an error when allocation ~= 1 or when allocation per pool <0 | >1
    size as to be equal to the forcing used
    
fixed allocation is precomputed

Friedlingstein allocation works as long as LAI is a forcing variable. Once it this is turned into dynamic vegetation this has to be changed...

concept notes
each grid cell as only 1 pft - ok for now, but we should think of how to change this in the future
the fixed allocation was 1/3 in every pool. But to make it consistent with the dynamic allocation for non-limiting conditions of Friedlingstein et al 1999 we make it root=0.3, wood=0.3 and leaf=0.4

help function docuemntation

what to do with parameters that change per PFT (leaf age, root age, wood age, ...)
    
fe.EcoProp.