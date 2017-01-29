[[ -n ${_sorta_:-} ]] && return
readonly _sorta_=loaded

_array_declaration_() {
  local _parameter_=$1
  local _argument_=$2
  local _option_=$3

  _is_array_literal_ "$_argument_" && { _literal_declaration_ "$_parameter_" "$_argument_" "$_option_"; return ;}
  _is_type_ "$_argument_" "$_option_" || return
  _copy_declaration_ "$_argument_" "$_parameter_"
}

assign() {
  local _ref_=$1
  local _value_=$2
  local _name_

  _name_=${_value_%%=*}
  _name_=${_name_##* }
  printf '%s\n' "${_value_/$_name_/$_ref_}"
}

assigna() {
  local -n _refa_=$1
  local _value_=$2
  local -a _results_
  local -a _values_
  local IFS
  local _i_

  IFS=';'
  set -- $_value_
  IFS=$' \t\n'
  _values_=( "$@" )
  for _i_ in "${!_values_[@]}"; do
    _results_+=( "$(assign "${_refa_[$_i_]}" "${_values_[$_i_]}")" )
  done
  _print_joined_ ';' "${_results_[@]}"
}

_contains_() { [[ $2 == *"$1"* ]] ;}

_copy_declaration_() {
  _is_name_ "$1" || return
  set -- "$1" "$2" "$(declare -p "$1")"
  _results_+=( "${3/$1/$2}" )
}

_deref_declaration_() {
  local _parameter_=$1
  local _argument_=$2

  _is_name_ "$_argument_" || return
  _results_+=( "$(printf 'declare -n %s="%s"' "$_parameter_" "$_argument_")" )
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
  { [[ -z $1 ]] || _is_array_literal_ "$1" ;} && { pass hash; return ;}
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
  { [[ -z $1 ]] || _is_array_literal_ "$1" ;} && { pass hash; return ;}
  assign "$1" "$(pass hash)"
}

intos() {
  eval "$(passed '( %hash ref )' "$@")"

  hash[$ref]=${!ref}
  { [[ -z $1 ]] || _is_array_literal_ "$1" ;} && { pass hash; return ;}
  assign "$1" "$(pass hash)"
}

_is_array_()          { _is_type_ "$1" a ;}
_is_array_literal_()  { [[ $1 == '('* && $1 == *')'  ]] ;}
_is_hash_literal_()   { _is_array_literal_ "$1" && [[ ${1// /} == '(['* ]] ;}
_is_name_()           { declare -p "$1" >/dev/null 2>&1 ;}
_is_ref_()            { _is_name_ "${!1}" ;}
_is_set_()            { [[ $1 == [[:alpha:]_]* && ${!1+x} == 'x' ]] ;}
_is_type_()           { [[ $(declare -p "$1" 2>/dev/null) == 'declare -'"$2"* ]] ;}

keys_of() {
  eval "$(passed '( %hash )' "$@")"
  local -a results

  results=( "${!hash[@]}" )
  pass results
}

_literal_declaration_() {
  case $3 in
    a ) _is_array_literal_  "$2" || return;;
    A ) _is_hash_literal_   "$2" || return;;
  esac
  declare -"$3" "$1"="$2"
  _results_+=( "$(declare -p "$1")" )
}

_map_arg_type_() {
  local _parameter_=$1
  local _argument_=$2

  case ${_parameter_:0:1} in
    '%' ) _array_declaration_  "${_parameter_:1}" "$_argument_" A ;;
    '&' ) _deref_declaration_  "${_parameter_:1}" "$_argument_"   ;;
    '*' ) _ref_declaration_    "${_parameter_:1}" "$_argument_"   ;;
    '@' ) _array_declaration_  "${_parameter_:1}" "$_argument_" a ;;
    *   ) _scalar_declaration_ "$_parameter_"     "$_argument_"   ;;
  esac
}

pass() { declare -p "$1" ;}

passed() {
  _is_array_ "$1" || _is_array_literal_ "$1" || return
  if _is_array_ "$1"; then
    set -- "$(declare -p "$1")" "$@"
    eval "${1/$2/_parameters_}"
    shift
  else
    local -a _parameters_="$1"
  fi
  shift
  local _results_=()
  local _arguments_=( "$@" )
  _process_parameters_ || return
  _print_joined_ ';' "${_results_[@]}"
}

_print_joined_() {
  local IFS=$1; shift

  printf '%s\n' "$*"
}

_process_parameters_() {
  local _argument_=''
  local _i_
  local _parameter_

  for _i_ in "${!_parameters_[@]}"; do
    _parameter_=${_parameters_[$_i_]}
    _contains_ '=' "$_parameter_" && { _argument_=${_parameter_#*=}; _parameter_=${_parameter_%%=*} ;}
    _is_set_ _arguments_[$_i_] && _argument_=${_arguments_[$_i_]}
    _map_arg_type_ "$_parameter_" "$_argument_" || return
  done
}

_ref_declaration_() {
  local _parameter_=$1
  local _argument_=$2

  _is_name_ "$_argument_" || return
  if _is_ref_ "$_argument_"; then
    _copy_declaration_ "$_argument_" "$_parameter_"
  else
    _copy_declaration_ _argument_ "$_parameter_"
  fi
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

_scalar_declaration_() {
  local _parameter_=$1
  local _argument_=$2

  _is_set_ "$_argument_" && _argument_=${!_argument_}
  _copy_declaration_ _argument_ "$_parameter_"
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
