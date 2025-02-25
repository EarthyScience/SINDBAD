# Start developing this package

First do

```sh
(SindbadML) pkg> dev ../.. ../../lib/SindbadUtils/ ../../lib/SindbadData/ ../../lib/SindbadMetrics/ ../../lib/SindbadSetup/ ../../lib/SindbadTEM
```
and then 

```sh
(SindbadML) pkg> instantiate
```

now, this should work

```sh
julia > using SindbadML
```