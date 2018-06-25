module letkf_config
  use json_module
  use json_kinds
  
  implicit none
  private

  
  public :: letkf_config_loadfile


  
  type, public :: configuration
     
    type(json_value), pointer :: json

  contains
    
    generic, public :: get => get_child_name, get_child_idx, &
         get_integer_name, get_integer_idx, &
         get_real4_name,   get_real4_idx, &
         get_real8_name,   get_real8_idx, &
         get_string_name,  get_string_idx, &
         get_logical_name
    generic, public :: get_child => get_child_name_f, get_child_idx_f
    procedure, public :: count => get_array_count        
    procedure, public :: found => get_found

    
    procedure, private :: get_child_name, get_child_idx,&
         get_integer_name, get_integer_idx, &
         get_real4_name,   get_real4_idx, &
         get_real8_name,   get_real8_idx, &         
         get_string_name,  get_string_idx, &
         get_logical_name
    procedure, private :: get_child_name_f, get_child_idx_f
    
  end type configuration

  

  type(json_core) :: jcore, jcore2


  
contains



  subroutine letkf_config_loadfile(filename, res)
    character(len=*), intent(in) :: filename
    class(configuration), intent(out) :: res

    type(json_file) :: jfile
    type(json_core) :: core
    type(json_value), pointer :: ptr
    integer :: i
    logical :: found

    call jfile%initialize(stop_on_error=.true.)
    call jfile%load_file(filename)
    call jfile%get( res%json)

    call jcore%initialize(stop_on_error=.true.)
    call jcore2%initialize(stop_on_error=.false.)
    
  end subroutine letkf_config_loadfile

  

  function get_array_count(self) result(val)
    class(configuration) :: self
    integer :: val
    val = jcore%count(self%json)
  end function get_array_count


  
  subroutine get_child_name(self, key, p)
    class(configuration),intent(in) :: self
    character(len=*), intent(in) :: key
    class(configuration), intent(out) :: p
    call jcore%get_child(self%json, key, p%json)    
  end subroutine get_child_name
  
  subroutine get_child_idx(self, idx, p, name)
    class(configuration),intent(in) :: self
    integer, intent(in) :: idx
    class(configuration), intent(out) :: p
    character(:), allocatable, intent(out), optional :: name
    character(:), allocatable :: str    
    call jcore%get_child(self%json, idx, p%json)
    if(present(name)) then
       call jcore2%info(p%json, name=str)
       name = str
    end if
  end subroutine get_child_idx
  
  function get_child_name_f(self, key) result(res)
    class(configuration), intent(in) :: self
    character(len=*), intent(in) :: key
    type(configuration) :: res
    call jcore%get_child(self%json, key, res%json)
  end function get_child_name_f

  function get_child_idx_f(self, idx) result(res)
    class(configuration), intent(in) :: self
    integer, intent(in) :: idx
    type(configuration) :: res
    call jcore%get_child(self%json, idx, res%json)
  end function get_child_idx_f

  function get_found(self, key) result(res)
    class(configuration), intent(in) :: self
    character(len=*), intent(in) :: key
    logical :: res
    res = jcore2%valid_path(self%json, key)
  end function get_found
  
    
  subroutine get_integer_name(self, key, val)
    class(configuration),intent(in) :: self
    character(len=*), intent(in) :: key
    integer,intent(out) :: val
    call jcore%get(self%json, key, val)
  end subroutine get_integer_name

  subroutine get_integer_idx(self, idx, val)
    class(configuration),intent(in) :: self
    integer, intent(in) :: idx
    integer,intent(out) :: val
    type(json_value), pointer :: json
    call jcore%get_child(self%json, idx, json)    
    call jcore%get(json, val)
  end subroutine get_integer_idx

  

  subroutine get_real4_name(self, key, val)
    class(configuration),intent(in) :: self
    character(len=*), intent(in) :: key
    real(4), intent(out) :: val
    real(8) :: r
    call jcore%get(self%json, key, r)
    val=r
  end subroutine get_real4_name

  subroutine get_real4_idx(self, idx, val)
    class(configuration), intent(in) :: self
    integer, intent(in) :: idx
    real(4), intent(out) :: val
    real(8) :: r
    type(json_value), pointer :: json
    call jcore%get_child(self%json, idx, json)    
    call jcore%get(json, r)
    val =r 
  end subroutine get_real4_idx
  
  subroutine get_real8_name(self, key, val)
    class(configuration),intent(in) :: self
    character(len=*), intent(in) :: key
    real(8), intent(out) :: val
    call jcore%get(self%json, key, val)
  end subroutine get_real8_name

  subroutine get_real8_idx(self, idx, val)
    class(configuration), intent(in) :: self
    integer, intent(in) :: idx
    real(8), intent(out) :: val
    type(json_value), pointer :: json
    call jcore%get_child(self%json, idx, json)
    call jcore%get(json, val)
  end subroutine get_real8_idx


  
  subroutine get_string_name(self, key, val)
    class(configuration),intent(in) :: self
    character(len=*), intent(in) :: key
    character(len=:), allocatable, intent(out) :: val
    call jcore%get(self%json, key, val)
  end subroutine get_string_name

  subroutine get_string_idx(self, idx, val)
    class(configuration), intent(in) :: self
    integer, intent(in) :: idx
    character(len=:), allocatable, intent(out) :: val

    type(json_value), pointer :: json
    call jcore%get_child(self%json, idx, json)
    call jcore%get(json, val)
  end subroutine get_string_idx

  
  
  subroutine get_logical_name(self, key, val, default)
    class(configuration),intent(in) :: self
    character(len=*), intent(in) :: key
    logical, intent(out) :: val
    logical, optional, intent(in) :: default
    if (present(default) .and. .not. jcore2%valid_path(self%json, key)) then
       val = default
    else
       call jcore%get(self%json, key, val)
    end if
  end subroutine get_logical_name
  
end module letkf_config