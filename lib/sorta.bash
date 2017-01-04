[[ -n ${_sorta:-} ]] && return
readonly _sorta=loaded

_options() {
  case $1 in
    '@')
      printf 'a'
      ;;
    '%')
      printf 'A'
      ;;
  esac
}

assign() {
  local _ref=$1
  local _value=$2
  local _name

  _name=${_value%%=*}
  _name=${_name##* }
  printf '%s' "${_value/$_name/$_ref}"
}

froma() {
  # shellcheck disable=SC2034
  local _params=( %hash @keys )
  eval "$(passed _params "$@")"

  local -a declarations
  local IFS
  local key
  local value

  { (( ${#keys[@]} == 1 )) && [[ ${keys[0]} == '*' ]] ;} && keys=( "${!hash[@]}" )
  # shellcheck disable=SC2154
  for key in "${keys[@]}"; do
    value=${hash[$key]}
    value=$(declare -p value)
    value=${value#*=}
    declarations+=( "$(printf 'declare -- %s=%s' "$key" "$value")" )
  done
  IFS=';'
  printf '%s\n' "${declarations[*]}"
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

  # shellcheck disable=SC2015
  declare -p "$_temp" >/dev/null 2>&1 && local -n _parameters=$_temp || local -a '_parameters='"$_temp"
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
          # shellcheck disable=SC2030
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
