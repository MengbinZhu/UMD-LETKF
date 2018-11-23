Configuration
===================

This is the list of configuration options for the json configuration file.

* TODO, description
* TODO, JSON explanation
* TODO, import statements
* TODO, refer to an example configuration file
  
  
mpi
---------

* **mpi.ens_size=** *<integer>*

  | The number of ensemble members.  **(required)**
  
* **mpi.ppn=** *<integer>*
  
  | The number of processors per node. **(default: 1)**
  | Optional, but helps improve I/O performance by evenly distributing the PEs which perform simulttaneous I/O across nodes. 


solver
---------

* **solver.save_diag=** *<logical>*

  | If true, the `diag.solver.nc` file is saved at the end of the UMD-LETKF run. **(default: True)**  
  | This file contains diagnostic information such as the number of observations used per grid cell.
  
  
* **solver.inflation.rtps=** *<real>*

  | The percentage of :ref:`RTPS` to apply. **(default: 0.0)**  
  | Valid parameters are betwen 0.0 and 1.0. Value of 0.0 indicates RTPS is off, 1.0 indicates analysis spread is relaxed 100% back toward the background spread. Values between 0.5 and 0.8 are often good choices. You could in theory use values greater than 1.0 to result in analysis spread that is larger than background spread, but I have no idea why you would want to do this. Cannot be used if RTPP is enabled.
  
* **solver.inflation.rtpp=** *<real>*

  | The percentage of :ref:`RTPP` to apply. **(default: 0.0)** 
  | Valid parameters are between 0.0 and 1.0. Value of 0.0 indicates RTPS is off, 1.0 indicates the analysis ensemble perturbations are relaxed 100% back toward the background perturbation. Unless you know what you are doing, you are better off using :ref:`RTPS`. Cannot be used if RTPS is enabled
  
* **solver.inflation.mul=** *<real>*

  | The amount of :ref:`mul_infl` inflation to apply. **(default: 1.0)**
  | Valid parameters are greater than or equal to 1.0. Value of 1.0 indicates multiplicative inflation is off.


state
--------

* **state.verbose**
* ioclass

* hzgrid
* vtgrid
* statedef


localization
-------------------

* class
* everything else depends on the specific localization class being used

observation
---------------

* class
* obsdef
* platdef
  
