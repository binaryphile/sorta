[[ -n ${_sorta:-} ]] && return
readonly _sorta=loaded

_options() {
  case $1 in
    '@') printf 'a';;
    '%') printf 'A';;
  esac
}

assign() {
  local _ref=$1
  local _value=$2
  local _name

  _name=${_value%%=*}
  _name=${_name##* }
  printf '%s\n' "${_value/$_name/$_ref}"
}

assigna() {
  local -n _refa=$1
  local _value=$2
  local -a _results
  local -a _values
  local IFS
  local _IFS
  local _i

  _IFS=$IFS
  IFS=';'
  set -- $_value
  _values=( "$@" )
  IFS=$_IFS
  for _i in "${!_values[@]}"; do
    _results+=( "$(assign "${_refa[$_i]}" "${_values[$_i]}")" )
  done
  IFS=';'
  printf '%s\n' "${_results[*]}"
}

froma() {
  local _params=( %hash @keys )
  eval "$(passed _params "$@")"

  local -a results
  local IFS
  local key

  for key in "${keys[@]}"; do
    results+=( "$(froms hash key)" )
  done
  IFS=';'
  printf '%s\n' "${results[*]}"
}

fromh() {
  local _params=( %hash %keyh )
  eval "$(passed _params "$@")"
  local -a keys
  local -a values

  eval "$(assign keys "$(keys_of keyh)")"
  eval "$(assign values "$(values_of keyh)")"
  assigna values "$(froma hash keys)"
}

froms() {
  local _params=( %hash key )
  eval "$(passed _params "$@")"
  local -a keys
  local -a prefixes
  local prefix
  local value

  [[ $key == *'*' ]] && {
    prefix=${key%?}
    keys=( "${!hash[@]}" )
    for key in "${keys[@]}"; do
      prefixes+=( "$prefix$key" )
    done
    assigna prefixes "$(froma hash keys)"
    return
  }
  value=${hash[$key]}
  assign "$key" "$(declare -p value)"
}

intoa() {
  eval "$(passed '( @keys %hash="()" )' "$@")"
  local key

  for key in "${keys[@]}"; do
    eval "$(intos key hash)"
  done
  pass hash
}

intoh() {
  eval "$(passed '( %keyh %hash="()" )' "$@")"
  local -a keys
  local -a values
  local -A resulth

  eval "$(assign keys "$(keys_of keyh)")"
  eval "$(assign resulth "$(intoa keys hash)")"
  for key in "${keys[@]}"; do
    hash[${keyh[$key]}]=${resulth[$key]}
  done
  pass hash
}

intos() {
  eval "$(passed '( ref %hash="()" )' "$@")"

  hash[$ref]=${!ref}
  pass hash
}

keys_of() {
  eval "$(passed '( %hash )' "$@")"

  local -a results

  results=( "${!hash[@]}" )
  pass results
}

pass() { declare -p "$1" ;}

passed() {
  local _temp=$1; shift
  local -a _arguments=( "$@" )
  local -a _results
  local IFS
  local _argument=''
  local _declaration
  local _i
  local _parameter
  local _type

  declare -p "$_temp" >/dev/null 2>&1 && local -n _parameters=$_temp || local -a _parameters=$_temp
  for _i in "${!_parameters[@]}"; do
    _parameter=${_parameters[$_i]}
    [[ $_parameter == *=* ]] && _argument=${_parameter#*=}
    _parameter=${_parameter%%=*}
    [[ ${_arguments[$_i]+x} == 'x' ]] && _argument=${_arguments[$_i]}
    _type=${_parameter:0:1}
    case $_type in
      '@' | '%' )
        _parameter=${_parameter:1}
        if [[ $_argument == '('* ]]; then
          declare -"$(_options "$_type")" "$_parameter"="$_argument"
          _declaration=$(declare -p "$_parameter")
        else
          _declaration=$(declare -p "$_argument")
          _declaration=${_declaration/$_argument/$_parameter}
        fi
        _results+=( "$_declaration" )
        ;;
      '&' )
        _parameter=${_parameter:1}
        _results+=( "$(printf 'declare -n %s="%s"' "$_parameter" "$_argument")" )
        ;;
      * )
        if declare -p "$_argument" >/dev/null 2>&1; then
          _declaration=$(declare -p "$_argument")
          _declaration=${_declaration/$_argument/$_parameter}
        else
          { [[ $_argument == *[* ]] && declare -p "${_argument%[*}" >/dev/null 2>&1 ;} && {
            [[ ${!_argument+x} == 'x' ]] || return
            _argument=${!_argument}
          }
          _declaration=$(declare -p _argument)
          _declaration=${_declaration/_argument/$_parameter}
        fi
        _results+=( "$_declaration" )
        ;;
    esac
  done
  IFS=';'
  printf '%s\n' "${_results[*]}"
}

values_of() {
  eval "$(passed '( %hash )' "$@")"

  local -a results
  local key

  for key in "${!hash[@]}"; do
    results+=( "${hash[$key]}" )
  done
  pass results
}
