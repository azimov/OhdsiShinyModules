OhdsiShinyModules
======================

[![Build Status](https://github.com/OHDSI/OhdsiShinyModules/workflows/R-CMD-check/badge.svg)](https://github.com/OHDSI/OhdsiShinyModules/actions?query=workflow%3AR-CMD-check)

[![codecov.io](https://codecov.io/github/OHDSI/OhdsiShinyModules/coverage.svg?branch=main)](https://codecov.io/github/OHDSI/OhdsiShinyModules?branch=main)

OhdsiShinyModules is an R package containing shiny modules that can be used within shiny result interfaces.

The OHDSI tools often provide shiny interfaces for viewing and exploring results.  Many of these shiny apps have overlapping features.  To ensure consistency we have created a repository containing useful shiny modules that can be used in multiple result explorers.

Current Modules
========
- about module: this contains information about the shiny viewer and the types of OHDSI analyses
- prediction module: a module for exploring patient-level prediction results that were developed usign the OHDSI PatientLevelPrediction package


Technology
==========
OhdsiShinyModules is an R package that uses the R shiny library.  

System Requirements
===================
Requires R (version 3.3.0 or higher). 

Getting Started
===============

- To install the package:

```
install.packages(remotes)
remotes::install_github('ohdsi/OhdsiShinyModules')
```

Please read the main vignette for the package:

Package manual: [AddingShinyModules.pdf](https://github.com/OHDSI/OhdsiShinyModules/blob/main/inst/doc/AddingShinyModules.pdf)


Support
=======
* Developer questions/comments/feedback: <a href="http://forums.ohdsi.org/c/developers">OHDSI Forum</a>
* We use the <a href="https://github.com/OHDSI/OhdsiShinyModules/issues">GitHub issue tracker</a> for all bugs/issues/enhancements

Contributing
============
* Read [here](https://ohdsi.github.io/Hades/contribute.html) how you can contribute to this package. 
* This [website](https://mastering-shiny.org/scaling-modules.html) may be helpful if you want to see an introduction into how to write shiny modules
 
License
=======
OhdsiShinyModules is licensed under Apache License 2.0

Development
===========
OhdsiShinyModules is being developed in R Studio.


# Acknowledgements

- The package is maintained by <add> and has been developed with major contributions from <add>
