# PlotsOptim.jl

Documentation for PlotsOptim.jl


# Plots for optimzation algorithms

## The base plot routine

```@docs
plot_curves
get_curveparams
get_legendname
```

The lines may be simplified, thus calling
```@docs
PlotsOptim.simplifyline
```


Example functions:
```@docs
PlotsOptim.get_abscisses
PlotsOptim.get_ordinates
```

## Helper functions

### Relative Optimality
```@docs
```

### Checking derivatives

```@docs
plot_taylordev
build_affinemodel
```

Unexported helper functions:

```@docs
PlotsOptim.logspaced_range
PlotsOptim.build_logcurves
PlotsOptim.remove_small_functionvals
```

### Performance profiles

```@docs
plot_perfprofile
```
