[[ -n ${_sorta:-} ]] && return
readonly _sorta=loaded

_array_declaration() {
  local parameter=$1
  local argument=$2
  local option=$3
  local declaration

  [[ $argument == '('* ]] && { _literal_declaration "$parameter" "$argument" "$option"; return ;}
  declaration=$(declare -p "$argument")
  [[ $declaration == 'declare -'"$option"* ]] || return
  results+=( "${declaration/$argument/$parameter}" )
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
  local _i

  IFS=';'
  set -- $_value
  IFS=$' \t\n'
  _values=( "$@" )
  for _i in "${!_values[@]}"; do
    _results+=( "$(assign "${_refa[$_i]}" "${_values[$_i]}")" )
  done
  IFS=';'
  printf '%s\n' "${_results[*]}"
}

_deref_declaration() {
  local parameter=$1
  local argument=$2
  local declaration

  _is_ref "$argument" || return
  printf -v declaration 'declare -n %s="%s"' "$parameter" "$argument"
  results+=( "$declaration" )
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
  eval "$(passed '( %hash @keys )' "$@")"
  local key

  for key in "${keys[@]}"; do
    eval "$(intos hash key)"
  done
  [[ -z $1 || $1 == '('* ]] && { pass hash; return ;}
  assign "$1" "$(pass hash)"
}

intoh() {
  eval "$(passed '( %hash %keyh )' "$@")"
  local -a keys
  local -a values

  eval "$(assign keys "$(keys_of keyh)")"
  eval "$(assign resulth "$(intoa hash keys)")"
  for key in "${keys[@]}"; do
    hash[${keyh[$key]}]=${resulth[$key]}
  done
  [[ -z $1 || $1 == '('* ]] && { pass hash; return ;}
  assign "$1" "$(pass hash)"
}

intos() {
  eval "$(passed '( %hash ref )' "$@")"

  hash[$ref]=${!ref}
  [[ -z $1 || $1 == '('* ]] && { pass hash; return ;}
  assign "$1" "$(pass hash)"
}

_is_name()        { declare -p "$1" >/dev/null 2>&1 ;}
_is_ref()         { _is_set "${!1}"       ;}
_is_scalar_set()  { [[ ${!1+x} == 'x' ]]  ;}
_is_set()         { _is_name "$1" || _is_scalar_set "$1" ;}

keys_of() {
  eval "$(passed '( %hash )' "$@")"

  local -a results

  results=( "${!hash[@]}" )
  pass results
}

_literal_declaration() {
  local parameter=$1
  local argument=$2
  local option=$3
  local message

  message=$(declare -"$option" "$parameter"="$argument" 2>&1)
  [[ -z $message ]] || return
  declare -"$option" "$parameter"="$argument"
  results+=( "$(declare -p "$parameter")" )
}

_map_arg_type() {
  local parameter=$1
  local argument=$2
  local parm
  local type

  type=${parameter:0:1}
  parm=${parameter:1}
  case $type in
    '%' ) _array_declaration  "$parm"       "$argument" A ;;
    '&' ) _deref_declaration  "$parm"       "$argument"   ;;
    '*' ) _ref_declaration    "$parm"       "$argument"   ;;
    '@' ) _array_declaration  "$parm"       "$argument" a ;;
    *   ) _scalar_declaration "$parameter"  "$argument"   ;;
  esac
}

pass() { declare -p "$1" ;}

passed() {
  local temp=$1; shift
  local -a arguments=( "$@" )
  local -a results=()
  local argument=''
  local i
  local parameter

  if _is_ref temp; then
    local -n parameters="$temp"
  else
    local -a parameters="$temp"
  fi
  for i in "${!parameters[@]}"; do
    parameter=${parameters[$i]}
    [[ $parameter == *=* ]] && { argument=${parameter#*=}; parameter=${parameter%%=*} ;}
    _is_set arguments[$i] && argument=${arguments[$i]}
    _map_arg_type "$parameter" "$argument" || return
  done
  _print_joined ';' "${results[@]}"
}

_print_joined() {
  local IFS=$1; shift

  printf '%s\n' "$*"
}

_ref_declaration() {
  local parameter=$1
  local argument=$2
  local declaration

  _is_set "$argument" || return
  if _is_ref "$argument"; then
    declaration=$(declare -p "$argument")
  else
    declaration=$(declare -p argument)
  fi
  declaration=${declaration#*=}
  printf -v declaration 'declare -- %s=%s' "$parameter" "$declaration"
  results+=( "$declaration" )
}

reta() {
  eval "$(passed '( @_values "*_ref" )' "$@")"
  local _declaration

  unset -v "$_ref"
  _declaration=$(declare -p _values)
  _declaration=${_declaration#*=}
  _declaration=${_declaration:1:-1}
  eval "$(printf '%s=%s' "$_ref" "$_declaration")"
}

reth() {
  eval "$(passed '( %_valueh "*_ref" )' "$@")"
  local _declaration

  unset -v "$_ref"
  _declaration=$(declare -p _valueh)
  _declaration=${_declaration#*=}
  _declaration=${_declaration:1:-1}
  eval "$(printf '%s=%s' "$_ref" "$_declaration")"
}

rets() {
  eval "$(passed '( _value "*_ref" )' "$@")"

  unset -v "$_ref"
  printf -v "$_ref" '%s' "$_value"
}

_scalar_declaration() {
  local parameter=$1
  local argument=$2
  local declaration

  declaration=$(declare -p "$argument" 2>/dev/null) ||:
  [[ $declaration == '' || $declaration == 'declare -'[aA]* ]] && {
    [[ $argument == *[* && ${!argument+x} == 'x' ]] && {
      argument=${!argument}
    }
    declaration=$(declare -p argument)
  }
  declaration=${declaration#*=}
  printf -v declaration 'declare -- %s=%s' "$parameter" "$declaration"
  results+=( "$declaration" )
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
