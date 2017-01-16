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

keys_of() {
  eval "$(passed '( %hash )' "$@")"

  local -a results

  results=( "${!hash[@]}" )
  pass results
}

pass() { declare -p "$1" ;}

passed() {
  local __temp=$1; shift
  local -a __arguments=( "$@" )
  local -a __results
  local IFS
  local __argument=''
  local __declaration
  local __i
  local __parameter
  local __type

  if declare -p "$__temp" >/dev/null 2>&1; then
    local -n __parameters=$__temp
  else
    local -a __parameters=$__temp
  fi
  for __i in "${!__parameters[@]}"; do
    __parameter=${__parameters[$__i]}
    [[ $__parameter == *=* ]] && __argument=${__parameter#*=}
    __parameter=${__parameter%%=*}
    [[ ${__arguments[$__i]+x} == 'x' ]] && __argument=${__arguments[$__i]}
    __type=${__parameter:0:1}
    case $__type in
      '@' | '%' )
        __parameter=${__parameter:1}
        if [[ $__argument == '('* ]]; then
          declare -"$(_options "$__type")" "$__parameter"="$__argument"
          __declaration=$(declare -p "$__parameter")
        else
          __declaration=$(declare -p "$__argument") || return
          case $__type in
            '@' ) [[ $__declaration == 'declare -a'* ]] || return;;
            '%' ) [[ $__declaration == 'declare -A'* ]] || return;;
          esac
          __declaration=${__declaration/$__argument/$__parameter}
        fi
        ;;
      '&' )
        __parameter=${__parameter:1}
        __declaration=$(printf 'declare -n %s="%s"' "$__parameter" "$__argument")
        ;;
      '*' )
        __parameter=${__parameter:1}
        declare -p "$__argument" >/dev/null 2>&1 || return
        if declare -p "${!__argument}" >/dev/null 2>&1; then
          __declaration=$(declare -p "$__argument")
        else declare -p "$argument" >/dev/null 2>&1
          __declaration=$(declare -p __argument)
        fi
        __declaration=${__declaration#*=}
        printf -v __declaration 'declare -- %s=%s' "$__parameter" "$__declaration"
        ;;
      * )
        __declaration=$(declare -p "$__argument" 2>/dev/null)
        if [[ $__declaration == '' || $__declaration == 'declare -'[aA]* ]]; then
          [[ $__argument == *[* && ${!__argument+x} == 'x' ]] && {
            __argument=${!__argument}
          }
          __declaration=$(declare -p __argument)
        else
          __declaration=$(declare -p "$__argument")
        fi
        __declaration=${__declaration#*=}
        printf -v __declaration 'declare -- %s=%s' "$__parameter" "$__declaration"
        ;;
    esac
    __results+=( "$__declaration" )
  done
  IFS=';'
  printf '%s\n' "${__results[*]}"
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

values_of() {
  eval "$(passed '( %hash )' "$@")"

  local -a results
  local key

  for key in "${!hash[@]}"; do
    results+=( "${hash[$key]}" )
  done
  pass results
}
