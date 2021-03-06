!================================================================================
!> The main LETKF library module
!================================================================================
MODULE letkf

  USE letkf_config
  USE letkf_loc
  USE letkf_mpi
  USE letkf_obs
  USE letkf_solver
  USE letkf_state

  USE pluginloader_letkf_stateio
  USE pluginloader_letkf_obsio
  USE pluginloader_letkf_localizer

  USE timing
  USE getmem

  IMPLICIT NONE
  PRIVATE


  ! use this to get the repository version at compile time
#ifndef CVERSION
#define CVERSION "Unknown"
#endif


  !================================================================================
  !================================================================================
  ! Public module components
  !================================================================================
  !================================================================================

  PUBLIC :: letkf_init
  PUBLIC :: letkf_run
  PUBLIC :: letkf_register_hook



  !================================================================================
  !================================================================================
  ! Private module components
  !================================================================================
  !================================================================================

  TYPE(configuration) :: config



CONTAINS



  !================================================================================
  !> Initialize the LETKF library.
  !! This needs to be done before any other user-called functions are performed.
  !! This initializes the MPI backend, and loads the default stateio, obsio, and
  !! localizer classes
  !--------------------------------------------------------------------------------
  SUBROUTINE letkf_init(config_filename)
    CHARACTER(len=*) :: config_filename !< json configuration file to load

    ! temprary pointers for initializing and registering the default classes
    CLASS(letkf_obsio),     POINTER :: obsio_ptr
    CLASS(letkf_stateio),   POINTER :: stateio_ptr
    CLASS(letkf_localizer), POINTER :: localizer_ptr

    ! initialize the mpi backend
    CALL letkf_mpi_preinit()
    CALL getmem_init(pe_root, letkf_mpi_comm)

    ! initialize global timers
    CALL timing_init(letkf_mpi_comm, 0)
    CALL timing_start("pre-init")


    ! print out the welcome screen
    IF (pe_isroot) THEN
       PRINT *, "======================================================================"
       PRINT *, "======================================================================"
       PRINT *, "Universal Multi-Domain Local Ensemble Transform Kalman Filter"
       PRINT *, " (UMD-LETKF)"
       PRINT *, " version:  ", CVERSION
       PRINT *, "======================================================================"
       PRINT *, "======================================================================"
       PRINT *, ""
    END IF

    ! load in the configuration file
    IF (pe_isroot) THEN
       PRINT *, "Using configuration file: " // TRIM(config_filename)
       PRINT *, ""
    END IF
    letkf_config_log = pe_isroot
    CALL letkf_config_loadfile(config_filename, config)


    ! setup the default plugin classes
    CALL register_plugins_letkf_obsio()
    CALL register_plugins_letkf_stateio()
    CALL register_plugins_letkf_localizer()

    CALL timing_stop("pre-init")

  END SUBROUTINE letkf_init
  !================================================================================



  !================================================================================
  !> Does all the fun stuff of actually running the LETKF
  !--------------------------------------------------------------------------------
  SUBROUTINE letkf_run()

    ! LETKF initialization
    ! module initialization order is somewhat important
    ! "obs" must be initialized before "state" because, in the case of the test obs
    ! reader, the "obs" module might create hooks to get information from the state
    ! before "obs_read" is called.
    CALL timing_start("init", TIMER_SYNC)

    CALL letkf_mpi_init(config%get_child("mpi"))
    CALL letkf_mpi_barrier()

    CALL letkf_state_init(config%get_child("state"))
    CALL letkf_mpi_barrier()

    CALL letkf_obs_init(config%get_child("observation"))
    CALL letkf_mpi_barrier()

    CALL letkf_obs_read()
    CALL letkf_mpi_barrier()

    CALL letkf_loc_init(config%get_child("localization"))
    CALL letkf_mpi_barrier()

    CALL letkf_solver_init(config%get_child("solver"))
    CALL letkf_mpi_barrier()

    CALL timing_stop("init")

    ! run the LETKF solver
    CALL letkf_solver_run()
    CALL letkf_mpi_barrier()


    ! LETKF final output
    ! ------------------------------------------------------------
    CALL timing_start("output", TIMER_SYNC)

    ! miscellaneous diagnostics from the LETKF solver
    CALL letkf_solver_final()
    CALL localizer_class%FINAL()

    ! ensemble mean, spread
    CALL letkf_state_write_meansprd("ana")

    ! save ensemble members
    CALL letkf_state_write_ens()

    CALL timing_stop("output")



    ! all done
    CALL letkf_mpi_barrier()
    CALL timing_print()
    CALL getmem_print()
    CALL letkf_mpi_final()

  END SUBROUTINE letkf_run
  !================================================================================


  !================================================================================
  !> Register a callback function for one of the hooks where
  !! users can implement custom functionality
  !! @TODO implement this
  !--------------------------------------------------------------------------------
  SUBROUTINE letkf_register_hook
    PRINT *, "NOT yet implemented (letkf_register_hook)"
    STOP 1
  END SUBROUTINE letkf_register_hook
  !================================================================================



END MODULE letkf
