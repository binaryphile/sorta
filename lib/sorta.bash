[[ -n ${_sorta:-} ]] && return
readonly _sorta=loaded

source nano.bash

__array_declaration () {
  local __parameter=$1
  local __argument=$2
  local __option=$3

  __is_array_literal "$__argument" && { __literal_declaration "$__parameter" "$__argument" "$__option"; return ;}
  __is_type "$__argument" "$__option" || return
  __copy_declaration "$__argument" "$__parameter"
}

assign () {
  local __ref=$1
  local __value=$2
  local __name

  __name=${__value%%=*}
  __name=${__name##* }
  printf '%s\n' "${__value/$__name/$__ref}"
}

assigna () {
  local -n __refa=$1
  local __value=$2
  local -a __results
  local -a __values
  local IFS
  local __i

  IFS=';'
  set -- $__value
  IFS=$' \t\n'
  __values=( "$@" )
  for __i in "${!__values[@]}"; do
    __results+=( "$(assign "${__refa[$__i]}" "${__values[$__i]}")" )
  done
  __print_joined ';' "${__results[@]}"
}

__contains () { [[ $2 == *"$1"* ]] ;}

__copy_declaration () {
  __is_name "$1" || return
  set -- "$(declare -p "$1")" "$@"
  set -- "${1%%=*}=" "${1#*=}" "${@:2}"
  set -- "$1" "${2#\'}" "${@:3}"
  set -- "$1" "${2%\'}" "${@:3}"
  __results+=( "${1/$3/$4}$2" )
}

__deref_declaration () {
  local __parameter=$1
  local __argument=$2

  __is_name "$__argument" || return
  __results+=( "$(printf 'declare -n %s="%s"' "$__parameter" "$__argument")" )
}

froma () {
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

fromh () {
  local _params=( %hash %keyh )
  eval "$(passed _params "$@")"
  local -a keys
  local -a values

  eval "$(assign keys "$(keys_of keyh)")"
  eval "$(assign values "$(values_of keyh)")"
  assigna values "$(froma hash keys)"
}

froms () {
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

__includes () {
  eval "$(passed '( item @items )' "$@")"
  local expression
  local status
  local retval

  printf -v expression '+(%s)' "$(__print_joined '|' "${items[@]}")"
  status=$(set -- $(shopt extglob); echo "$2")
  shopt -s extglob
  [[ $1 == $expression ]]
  retval=$?
  [[ $status == 'off' ]] && shopt -u extglob
  return "$retval"
}

intoa () {
  eval "$(passed '( %hash @keys )' "$@")"
  local key

  for key in "${keys[@]}"; do
    eval "$(intos hash key)"
  done
  { [[ -z $1 ]] || __is_array_literal "$1" ;} && { pass hash; return ;}
  assign "$1" "$(pass hash)"
}

intoh () {
  eval "$(passed '( %hash %keyh )' "$@")"
  local -a keys
  local -a values

  eval "$(assign keys "$(keys_of keyh)")"
  eval "$(assign resulth "$(intoa hash keys)")"
  for key in "${keys[@]}"; do
    hash[${keyh[$key]}]=${resulth[$key]}
  done
  { [[ -z $1 ]] || __is_array_literal "$1" ;} && { pass hash; return ;}
  assign "$1" "$(pass hash)"
}

intos () {
  eval "$(passed '( %hash ref )' "$@")"

  hash[$ref]=${!ref}
  { [[ -z $1 ]] || __is_array_literal "$1" ;} && { pass hash; return ;}
  assign "$1" "$(pass hash)"
}

__is_array ()          { __is_type "$1" a ;}
__is_array_literal ()  { [[ $1 == '('* && $1 == *')'  ]] ;}

__is_declared_array () { __is_declared_type a "$@" ;}
__is_declared_hash () { __is_declared_type A "$@" ;}

__is_declared_scalar () {
  local name=$1
  local names=()

  __is_name "$name" && return
  IFS=$'\n' read -rd '' -a names <<<"$(compgen -v)" ||:
  __includes "$name" names && return
  declare -g "$1"=''
  ! __is_name "$1"
}

__is_declared_type () {
  local option=$1
  local name=$2
  local declarations=()
  local names=()

  __is_type "$2" "$1" && return
  IFS=$'\n' read -rd '' -a declarations <<<"$(declare -"$option")" ||:
  __names_from_declarations
  __includes "$name" names
}

__is_hash_literal ()   { __is_array_literal "$1" && [[ ${1// /} == '(['* ]] ;}
__is_name ()           { declare -p "$1" >/dev/null 2>&1 ;}
__is_ref ()            { __is_scalar "$1" && __is_name "${!1}" ;}
__is_scalar ()         { __is_type "$1" - ;}
__is_set ()            { local __expression='^[[:alpha:]_][][[:alnum:]_]*$'; [[ $1 =~ $__expression && ${!1+x} == 'x' ]] ;}
__is_type ()           { [[ $(declare -p "$1" 2>/dev/null) == 'declare -'"$2"* ]] ;}

keys_of () {
  eval "$(passed '( %hash )' "$@")"
  local results=( "${!hash[@]}" )

  pass results
}

__literal_declaration () {
  case $3 in
    a ) __is_array_literal  "$2" || return;;
    A ) __is_hash_literal   "$2" || return;;
  esac
  eval "declare -$3 $1=$2"
  set -- "$(declare -p "$1")"
  set -- "${1%%=*}=" "${1#*=}"
  set -- "$1" "${2%\'}"
  set -- "$1" "${2#\'}"
  __results+=( "$1$2" )
}

__map_arg_type () {
  local __parameter=$1
  local __argument=$2

  case ${__parameter:0:1} in
    '%' ) __array_declaration  "${__parameter:1}" "$__argument" A ;;
    '&' ) __deref_declaration  "${__parameter:1}" "$__argument"   ;;
    '*' ) __ref_declaration    "${__parameter:1}" "$__argument"   ;;
    '@' ) __array_declaration  "${__parameter:1}" "$__argument" a ;;
    *   ) __scalar_declaration "$__parameter"     "$__argument"   ;;
  esac
}

__name_from_declaration () {
  local name

  [[ $1 == 'declare -'*[[:alpha:]_]=* ]] || return
  name=${1%%=*}
  printf '%s\n' ${name##* }
}

__names_from_declarations () {
  local declaration

  for declaration in "${declarations[@]}"; do
    names+=( "$(__name_from_declaration "$declaration")" )
  done
}

pass () { declare -p "$1" ;}

passed () {
  __is_array "$1" || __is_array_literal "$1" || return
  if __is_array "$1"; then
    set -- "$(declare -p "$1")" "$@"
    set -- "${1#*=}" "${@:2}"
    set -- "${1#\'}" "${@:2}"
    set -- "${1%\'}" "${@:2}"
    eval "local -a __parameters=$1"
    shift
  else
    eval "local -a __parameters=$1"
  fi
  shift
  local __results=()
  local __arguments=( "$@" )
  __process_parameters || return
  __print_joined ';' "${__results[@]}"
}

__print_joined () {
  local IFS=$1; shift

  printf '%s\n' "$*"
}

__process_parameters () {
  local __argument=''
  local __i
  local __parameter

  for __i in "${!__parameters[@]}"; do
    __parameter=${__parameters[$__i]}
    __contains '=' "$__parameter" && { __argument=${__parameter#*=}; __parameter=${__parameter%%=*} ;}
    __is_set __arguments[$__i] && __argument=${__arguments[$__i]}
    __map_arg_type "$__parameter" "$__argument" || return
  done
}

__ref_declaration () {
  local __parameter=$1
  local __argument=$2

  [[ -n $__argument ]] || return
  __is_name "$__argument" || __is_declared_array "$__argument" || __is_declared_hash "$__argument" || __is_declared_scalar "$__argument" || return
  __is_ref "$__argument" && { __copy_declaration "$__argument" "$__parameter"; return ;}
  __copy_declaration __argument "$__parameter"
}

ret () { _ret "$@" ;}

__scalar_declaration () {
  local __parameter=$1
  local __argument=$2

  __is_set "$__argument" && __argument=${!__argument}
  __copy_declaration __argument "$__parameter"
}

values_of () {
  eval "$(passed '( %hash )' "$@")"

  local -a results
  local key

  for key in "${!hash[@]}"; do
    results+=( "${hash[$key]}" )
  done
  pass results
}
