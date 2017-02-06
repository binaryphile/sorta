source sorta.bash
source shpec-helper.bash

stop_on_error=true

describe '_array_declaration_'
  it "declares an array from an existing array"
    samples=( one two )
    _results_=()
    _array_declaration_ array samples a
    printf -v expected 'declare -a array=%s([0]="one" [1]="two")%s' \' \'
    assert equal "$expected" "${_results_[0]}"
  end

  it "passes a literal declaration to _literal_declaration_"
    _results_=()
    _array_declaration_ array '( one two )' a
    printf -v expected 'declare -a array=%s([0]="one" [1]="two")%s' \' \'
    assert equal "$expected" "${_results_[0]}"
  end

  it "declares a hash from an existing hash"
    declare -A sampleh=( [one]=1 [two]=2 )
    _results_=()
    _array_declaration_ hash sampleh A
    printf -v expected 'declare -A hash=%s([one]="1" [two]="2" )%s' \' \'
    assert equal "$expected" "${_results_[0]}"
  end

  it "errors on an array with a hash option"
    samples=( one two )
    _results_=()
    stop_on_error off
    _array_declaration_ array samples A
    assert unequal 0 $?
    stop_on_error
  end

  it "propagates an error from _literal_declaration_"
    _results_=()
    stop_on_error off
    _array_declaration_ array '( one two )' A
    assert unequal 0 $?
    stop_on_error
  end

  it "errors on a hash with an array option"
    declare -A sampleh=( [one]=1 [two]=2 )
    _results_=()
    stop_on_error off
    _array_declaration_ hash sampleh a
    assert unequal 0 $?
    stop_on_error
  end

  it "doesn't work if the argument is named _argument_"
    _argument_=( one two )
    _results_=()
    stop_on_error off
    _array_declaration_ array _argument_ a
    assert unequal 0 $?
    stop_on_error
  end

  # it "works if the argument is named _argument_"
  #   _argument_=( one two )
  #   _results_=()
  #   _array_declaration_ array _arguments_ a
  #   printf -v expected 'declare -a array=%s([0]="one" [1]="two")%s' \' \'
  #   assert equal "$expected" "${_results_[0]}"
  # end

  it "works if the argument is named _arguments_"
    _arguments_=( one two )
    _results_=()
    _array_declaration_ array _arguments_ a
    printf -v expected 'declare -a array=%s([0]="one" [1]="two")%s' \' \'
    assert equal "$expected" "${_results_[0]}"
  end

  it "doesn't work if the argument is named _parameter_"
    _parameter_=( one two )
    _results_=()
    stop_on_error off
    _array_declaration_ array _parameter_ a
    assert unequal 0 $?
    stop_on_error
  end

  # it "works if the argument is named _parameter_"
  #   _parameter_=( one two )
  #   _results_=()
  #   _array_declaration_ array _parameter_ a
  #   printf -v expected 'declare -a array=%s([0]="one" [1]="two")%s' \' \'
  #   assert equal "$expected" "${_results_[0]}"
  # end

  it "works if the argument is named _parameters_"
    _parameters_=( one two )
    _results_=()
    _array_declaration_ array _parameters_ a
    printf -v expected 'declare -a array=%s([0]="one" [1]="two")%s' \' \'
    assert equal "$expected" "${_results_[0]}"
  end

  it "doesn't work if the argument is named _option_"
    _option_=( one two )
    _results_=()
    stop_on_error off
    _array_declaration_ array _option_ a
    assert unequal 0 $?
    stop_on_error
  end

  # it "works if the argument is named _option_"
  #   _option_=( one two )
  #   _results_=()
  #   _array_declaration_ array _option_ a
  #   printf -v expected 'declare -a array=%s([0]="one" [1]="two")%s' \' \'
  #   assert equal "$expected" "${_results_[0]}"
  # end
end

describe 'assign'
  it "assigns an array result"
    printf -v sample    'declare -a sample=%s([0]="zero" [1]="one")%s' \' \'
    printf -v expected  'declare -a otherv=%s([0]="zero" [1]="one")%s' \' \'
    assert equal "$expected" "$(assign otherv "$sample")"
  end

  it "assigns a hash result"
    printf -v sample    'declare -A sample=%s([one]="1" [zero]="0" )%s' \' \'
    printf -v expected  'declare -A otherv=%s([one]="1" [zero]="0" )%s' \' \'
    assert equal "$expected" "$(assign otherv "$sample")"
  end
end

describe 'assigna'
  it "assigns a set of array results"
    printf -v sample    'declare -a sample=%s([0]="zero" [1]="one")%s;declare -a sample2=%s([0]="three" [1]="four")%s' \' \' \' \'
    printf -v expected  'declare -a other1=%s([0]="zero" [1]="one")%s;declare -a other2=%s([0]="three" [1]="four")%s' \' \' \' \'
    names=( other1 other2 )
    assert equal "$expected" "$(assigna names "$sample")"
  end
end

describe '_contains_'
  it "returns true if it finds a string in another string"
    _contains_ "one" "stones"
    assert equal 0 $?
  end

  it "returns false if it doesn't find a string in another string"
    stop_on_error off
    _contains_ "xor" "stones"
    assert unequal 0 $?
    stop_on_error
  end
end

describe '_copy_declaration_'
  it "creates a declaration from an existing scalar variable with the supplied variable name"
    _results_=()
    sample=one
    _copy_declaration_ sample result
    assert equal 'declare -- result="one"' "${_results_[0]}"
  end

  it "errors if the name doesn't exist"
    _results_=()
    unset -v sample
    stop_on_error off
    _copy_declaration_ sample result
    assert unequal 0 $?
    stop_on_error
  end
end

describe '_deref_declaration_'
  it "declares the parameter as dereferencing the argument"
    example=''
    sample=example
    _results_=()
    _deref_declaration_ result sample
    assert equal 'declare -n result="sample"' "${_results_[0]}"
  end

  it "errors if the named variable is not set"
    unset -v sample
    _results_=()
    stop_on_error off
    _deref_declaration_ result sample
    assert unequal 0 $?
    stop_on_error
  end

  it "errors if the named variable is an array item reference"
    samples=( one )
    _results_=()
    stop_on_error off
    _deref_declaration_ result samples[0]
    assert unequal 0 $?
    stop_on_error
  end
end

describe 'froma'
  it "imports named keys"
    unset -v zero one
    declare -A sampleh=( [zero]="0" [one]="1" )
    params=( one )
    assert equal 'declare -- one="1"' "$(froma sampleh params)"
  end
end

describe 'fromh'
  it "imports a hash key into the current scope given a name"
    unset -v zero
    declare -A sampleh=( [zero]=0 )
    declare -A keys=( [zero]=one )
    assert equal 'declare -- one="0"' "$(fromh sampleh keys)"
  end
end

describe 'froms'
  it "imports a hash key into the current scope"
    unset -v zero
    declare -A sampleh=( [zero]=0 )
    assert equal 'declare -- zero="0"' "$(froms sampleh zero)"
  end

  it "imports all keys if given *"
    unset -v zero one
    declare -A sampleh=( [zero]="0" [one]="1" )
    assert equal 'declare -- one="1";declare -- zero="0"' "$(froms sampleh '*')"
  end

  it "imports all keys with a prefix if given prefix_*"
    unset -v zero one
    declare -A sampleh=( [zero]="0" [one]="1" )
    assert equal 'declare -- prefix_one="1";declare -- prefix_zero="0"' "$(froms sampleh 'prefix_*')"
  end

  it "imports a key with a space in its value"
    unset -v zero
    declare -A sampleh=( [zero]="0 1" )
    assert equal 'declare -- zero="0 1"' "$(froms sampleh zero)"
  end
end

describe '_includes_'
  it "returns true if a string is in an array"
    unset -v one
    samples=( one two three )
    _includes_ one samples
    assert equal 0 $?
  end

  it "returns true if a string is in an array more than once"
    unset -v one
    samples=( one two three one )
    _includes_ one samples
    assert equal 0 $?
  end

  it "returns false if a string isn't in an array"
    samples=( one two three )
    stop_on_error off
    _includes_ four samples
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if only a substring is in an array"
    samples=( one two three )
    stop_on_error off
    _includes_ on samples
    assert unequal 0 $?
    stop_on_error
  end
end

describe 'intoa'
  it "generates a declaration for a hash with the named keys from the local namespace"
    one=1
    two=2
    declare -A hash=()
    printf -v expected 'declare -A hash=%s([one]="1" [two]="2" )%s' \' \'
    assert equal "$expected" "$(intoa hash '( one two )')"
  end

  it "generates a declaration for a hash merging the named keys with the existing key(s)"
    one=1
    two=2
    declare -A sampleh=([three]=3)
    printf -v expected 'declare -A sampleh=%s([one]="1" [two]="2" [three]="3" )%s' \' \'
    assert equal "$expected" "$(intoa sampleh '( one two )')"
  end
end

describe 'intoh'
  it "generates a declaration for a hash with the named keys from the local namespace"
    one=1
    two=2
    declare -A hash=()
    printf -v expected 'declare -A hash=%s([dumpty]="2" [humpty]="1" )%s' \' \'
    assert equal "$expected" "$(intoh hash '( [one]=humpty [two]=dumpty )')"
  end

  it "generates a declaration for a hash merging the named keys with the existing key(s)"
    one=1
    two=2
    declare -A sampleh=([three]=3)
    printf -v expected 'declare -A sampleh=%s([dumpty]="2" [humpty]="1" [three]="3" )%s' \' \'
    assert equal "$expected" "$(intoh sampleh '( [one]=humpty [two]=dumpty )')"
  end
end

describe 'intos'
  it "generates a declaration for a hash with the named key from the local namespace"
    one=1
    ref=one
    declare -A hash=()
    printf -v expected 'declare -A hash=%s([one]="1" )%s' \' \'
    assert equal "$expected" "$(intos hash ref)"
  end

  it "generates a declaration for a hash merging the named key with the existing key(s)"
    one=1
    ref=one
    declare -A sampleh=([two]=2)
    printf -v expected 'declare -A sampleh=%s([one]="1" [two]="2" )%s' \' \'
    assert equal "$expected" "$(intos sampleh ref)"
  end
end

describe '_is_array_'
  it "returns true if the argument is the name of an array"
    samples=( one )
    _is_array_ samples
    assert equal 0 $?
  end

  it "returns false if the argument is an indexed array reference"
    samples=( one )
    stop_on_error off
    _is_array_ samples[0]
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument is the name of a scalar"
    sample=one
    stop_on_error off
    _is_array_ sample
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument is the name of a hash"
    declare -A sampleh=( [one]=1 )
    stop_on_error off
    _is_array_ sampleh
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument is unset"
    unset -v sample
    stop_on_error off
    _is_array_ sample
    assert unequal 0 $?
    stop_on_error
  end
end

describe '_is_array_literal_'
  it "returns true if the argument is a string starting and ending with parentheses"
    _is_array_literal_ '()'
    assert equal 0 $?
  end

  it "returns false if the argument doesn't end with a parenthesis"
    stop_on_error off
    _is_array_literal_ '('
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument doesn't start with a parenthesis"
    stop_on_error off
    _is_array_literal_ ')'
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument is blank"
    stop_on_error off
    _is_array_literal_ ''
    assert unequal 0 $?
    stop_on_error
  end
end

describe '_is_declared_array_'
  it "returns true for a declared array"
    unset -v samples
    declare -a samples
    _is_declared_array_ samples
    assert equal 0 $?
  end

  it "returns false for not declared array"
    unset -v samples
    stop_on_error off
    _is_declared_array_ samples
    assert unequal 0 $?
    stop_on_error
  end
end

describe '_is_declared_hash_'
  it "returns true for a declared array"
    unset -v sampleh
    declare -A sampleh
    _is_declared_hash_ sampleh
    assert equal 0 $?
  end

  it "returns false for not declared array"
    unset -v sampleh
    stop_on_error off
    _is_declared_hash_ sampleh
    assert unequal 0 $?
    stop_on_error
  end
end

describe '_is_declared_type_'
  it "returns true for a declared array"
    unset -v samples
    declare -a samples
    _is_declared_type_ a samples
    assert equal 0 $?
  end

  it "returns false for not declared array"
    unset -v samples
    stop_on_error off
    _is_declared_type_ a samples
    assert unequal 0 $?
    stop_on_error
  end
end


describe '_is_hash_literal_'
  it "returns true for a parenthetical list of indices"
    _is_hash_literal_ '([one]=1)'
    assert equal 0 $?
  end

  it "returns true for a parenthetical list of indices with a leading space"
    _is_hash_literal_ '( [one]=1)'
    assert equal 0 $?
  end

  it "returns false for a parenthetical list without an initial bracket"
    stop_on_error off
    _is_hash_literal_ '({one]=1 )'
    assert unequal 0 $?
    stop_on_error
  end
end

describe '_is_name_'
  it "returns true if argument is the name of a scalar"
    sample=one
    _is_name_ sample
    assert equal 0 $?
  end

  it "returns true if argument is the name of an array"
    samples=( one )
    _is_name_ samples
    assert equal 0 $?
  end

  it "returns true if argument is the name of a hash"
    declare -A sampleh=( [one]=1 )
    _is_name_ sampleh
    assert equal 0 $?
  end

  it "returns false if argument is an indexed array reference"
    samples=( one )
    stop_on_error off
    _is_name_ samples[0]
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if argument is an indexed hash reference"
    declare -A sampleh=( [one]=1 )
    stop_on_error off
    _is_name_ samples[one]
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if argument is unset"
    unset -v sample
    stop_on_error off
    _is_name_ sample
    assert unequal 0 $?
    stop_on_error
  end
end

describe '_is_ref_'
  it "returns true if the named variable holds the name of another variable"
    unset -v example
    example=''
    sample=example
    _is_ref_ sample
    assert equal 0 $?
  end

  it "returns false if the named variable just holds a string"
    unset -v example
    sample=example
    stop_on_error off
    _is_ref_ sample
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the named variable is an array"
    samples=( example )
    stop_on_error off
    _is_ref_ samples
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the named variable is an array whose first element is a 'ref'"
    example=one
    samples=( example )
    stop_on_error off
    _is_ref_ samples
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the named variable is a hash"
    declare -A sampleh=( [example]=one )
    stop_on_error off
    _is_ref_ sampleh
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the named variable is a hash whose first element in a 'ref'"
    example=one
    declare -A sampleh=( [0]=example )
    stop_on_error off
    _is_ref_ sampleh
    assert unequal 0 $?
    stop_on_error
  end
end

describe '_is_set_'
  it "returns true if the argument is the name of a scalar variable"
    sample=one
    _is_set_ sample
    assert equal 0 $?
  end

  it "returns true if the argument is the name of a scalar variable starting with underscore"
    _sample=one
    _is_set_ _sample
    assert equal 0 $?
  end

  it "returns true if the argument is an indexed item of an array variable"
    samples=( one )
    _is_set_ samples[0]
    assert equal 0 $?
  end

  it "returns true if the argument is an indexed item of a hash variable"
    declare -A sampleh=( [one]=1 )
    _is_set_ sampleh[one]
    assert equal 0 $?
  end

  it "returns false if the argument is an array index that isn't set"
    samples=( one )
    stop_on_error off
    _is_set_ samples[1]
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument is a hash index that isn't set"
    declare -A sampleh=( [one]=1 )
    stop_on_error off
    _is_set_ sampleh[two]
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument doesn't exist"
    unset -v samples
    stop_on_error off
    _is_set_ samples[0]
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument doesn't start with a variable name character"
    set -- one
    stop_on_error off
    _is_set_ 1
    assert unequal 0 $?
    stop_on_error
  end
end

describe '_is_type_'
  it "returns true if the arguments are a scalar and a dash"
    sample=one
    _is_type_ sample -
    assert equal 0 $?
  end

  it "returns false if the arguments are a scalar and an a"
    sample=one
    stop_on_error off
    _is_type_ sample a
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the arguments are a scalar and an A"
    sample=one
    stop_on_error off
    _is_type_ sample A
    assert unequal 0 $?
    stop_on_error
  end

  it "returns true if the arguments are an array and an a"
    samples=( one )
    _is_type_ samples a
    assert equal 0 $?
  end

  it "returns false if the arguments are an array and a dash"
    samples=( one )
    stop_on_error off
    _is_type_ samples -
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the arguments are an array and an A"
    samples=( one )
    stop_on_error off
    _is_type_ samples -
    assert unequal 0 $?
    stop_on_error
  end

  it "returns true if the arguments are a hash and an A"
    declare -A sampleh=( [one]=1 )
    _is_type_ sampleh A
    assert equal 0 $?
  end

  it "returns false if the arguments are a hash and a dash"
    declare -A sampleh=( [one]=1 )
    stop_on_error off
    _is_type_ sampleh -
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the arguments are a hash and an a"
    declare -A sampleh=( [one]=1 )
    stop_on_error off
    _is_type_ sampleh a
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument doesn't exist and has a dash"
    unset -v sample
    stop_on_error off
    _is_type_ sample -
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument doesn't exist and has an a"
    unset -v sample
    stop_on_error off
    _is_type_ sample a
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument doesn't exist and has an A"
    unset -v sample
    stop_on_error off
    _is_type_ sample A
    assert unequal 0 $?
    stop_on_error
  end
end

describe 'keys_of'
  it "declares the keys of a hash"
    declare -A sampleh=([zero]=0 [one]=1)
    printf -v expected 'declare -a results=%s([0]="one" [1]="zero")%s' \' \'
    assert equal "$expected" "$(keys_of sampleh)"
  end
end

describe '_literal_declaration_'
  it "declares an array from an array literal"
    _results_=()
    _literal_declaration_ array '( one two )' a
    printf -v expected 'declare -a array=%s([0]="one" [1]="two")%s' \' \'
    assert equal "$expected" "${_results_[0]}"
  end

  it "declares a hash from a hash literal"
    _results_=()
    _literal_declaration_ hash '( [one]=1 [two]=2 )' A
    printf -v expected 'declare -A hash=%s([one]="1" [two]="2" )%s' \' \'
    assert equal "$expected" "${_results_[0]}"
  end

  it "errors on an array literal with a hash option"
    _results_=()
    stop_on_error off
    _literal_declaration_ array '( one two )' A
    assert unequal 0 $?
    stop_on_error
  end
end

describe '_map_arg_type_'
  it "creates a hash declaration"
    _results_=()
    declare -A sampleh=()
    _map_arg_type_ %resulth sampleh
    printf -v expected 'declare -A resulth=%s()%s' \' \'
    assert equal "$expected" "${_results_[0]}"
  end

  it "creates a deref declaration"
    _results_=()
    example=''
    sample=example
    _map_arg_type_ '&result' sample
    assert equal 'declare -n result="sample"' "${_results_[0]}"
  end

  it "creates a ref declaration"
    _results_=()
    sample=''
    _map_arg_type_ *result sample
    assert equal 'declare -- result="sample"' "${_results_[0]}"
  end

  it "creates an array declaration"
    _results_=()
    samples=()
    _map_arg_type_ @res samples
    printf -v expected 'declare -a res=%s()%s' \' \'
    assert equal "$expected" "${_results_[0]}"
  end

  it "creates a scalar declaration"
    _results_=()
    _map_arg_type_ result sample
    assert equal 'declare -- result=""' "${_results_[0]}"
  end

  it "errors if _array_declaration_ errors on a hash"
    samples=( one two )
    _results_=()
    stop_on_error off
    _map_arg_type_ %hash samples A
    assert unequal 0 $?
    stop_on_error
  end

  it "errors if _array_declaration_ errors on an array"
    declare -A sampleh=( [one]=1 [two]=2 )
    _results_=()
    stop_on_error off
    _map_arg_type_ @array sampleh a
    assert unequal 0 $?
    stop_on_error
  end
end

describe '_name_from_declaration_'
  it "returns the name of a simple declaration"
    result=$(_name_from_declaration_ 'declare -- sample="one"')
    assert equal sample "$result"
  end

  it "errors if the format doesn't have an equals sign"
    stop_on_error off
    _name_from_declaration_ 'declare -- sample"one"'
    assert unequal 0 $?
    stop_on_error
  end
end

describe '_names_from_declarations_'
  it "returns the name of a single declaration in 'names'"
    declarations=( 'declare -- sample="one"' )
    names=()
    _names_from_declarations_
    printf -v expected 'declare -a names=%s([0]="sample")%s' \' \'
    assert equal "$expected" "$(declare -p names)"
  end

  it "errors on a declaration missing an equals sign"
    declarations=( 'declare -- sample"one"' )
    names=()
    stop_on_error off
    _names_from_declarations_
    assert unequal 0 $?
    stop_on_error
  end
end

describe 'pass'
  it "declares a variable"
    sample=var
    assert equal 'declare -- sample="var"' "$(pass sample)"
  end
end

describe 'passed'
  it "creates a scalar declaration from an array naming a single parameter with the value passed after"
    set -- 0
    params=( zero )
    assert equal 'declare -- zero="0"' "$(passed params "$@")"
  end

  it "allows a literal for parameters"
    set -- 0
    assert equal 'declare -- zero="0"' "$(passed '( zero )' "$@")"
  end

  it "allows multiple items"
    set -- 0 1
    params=( zero one )
    assert equal 'declare -- zero="0";declare -- one="1"' "$(passed params "$@")"
  end

  it "works if the params list is named '_argument_'"
    unset -v one
    set -- one
    _argument_=( sample )
    assert equal 'declare -- sample="one"' "$(passed _argument_ "$@")"
  end

  it "works if the params list is named '_arguments_'"
    unset -v one
    set -- one
    _arguments_=( sample )
    assert equal 'declare -- sample="one"' "$(passed _arguments_ "$@")"
  end

  it "works if the params list is named '_parameters_'"
    unset -v one
    set -- one
    _parameters_=( sample )
    assert equal 'declare -- sample="one"' "$(passed _parameters_ "$@")"
  end

  it "works if the params list is named '_results_'"
    unset -v one
    set -- one
    _results_=( sample )
    assert equal 'declare -- sample="one"' "$(passed _results_ "$@")"
  end

  it "works if the params list is named '_option_'"
    unset -v one
    set -- one
    _option_=( sample )
    assert equal 'declare -- sample="one"' "$(passed _option_ "$@")"
  end

  # it "doesn't work if the params list is named '_argument_'"
  #   set -- ''
  #   _argument_=( sample )
  #   stop_on_error off
  #   passed _argument_ "$@" >/dev/null
  #   assert unequal 0 $?
  #   stop_on_error
  # end
  #
  # it "doesn't work if the params list is named '_arguments_'"
  #   set -- ''
  #   _arguments_=( sample )
  #   stop_on_error off
  #   passed _arguments_ "$@" >/dev/null
  #   assert unequal 0 $?
  #   stop_on_error
  # end
  #
  # it "doesn't work if the params list is named '_i_'"
  #   set -- ''
  #   _i_=( sample )
  #   stop_on_error off
  #   passed _i_ "$@" >/dev/null
  #   assert unequal 0 $?
  #   stop_on_error
  # end
  #
  # it "doesn't work if the params list is named '_parameter_'"
  #   set -- ''
  #   _parameter_=( sample )
  #   stop_on_error off
  #   passed _parameter_ "$@" >/dev/null
  #   assert unequal 0 $?
  #   stop_on_error
  # end
  #
  # it "doesn't work if the params list is named '_parameters_'"
  #   set -- ''
  #   _parameters_=( sample )
  #   stop_on_error off
  #   passed _parameters_ "$@" >/dev/null
  #   assert unequal 0 $?
  #   stop_on_error
  # end
  #
  # it "doesn't work if the params list is named '_results_'"
  #   set -- ''
  #   _results_=( sample )
  #   stop_on_error off
  #   passed _results_ "$@" >/dev/null
  #   assert unequal 0 $?
  #   stop_on_error
  # end
end

describe '_print_joined_'
  it "prints arguments joined by a delimiter"
    assert equal 'one;two' "$(_print_joined_ ';' one two)"
  end
end

describe '_process_parameters_'
  it "creates a scalar declaration from an array naming a single parameter with the value passed after"
    _results_=()
    _arguments_=( 0 )
    _parameters_=( zero )
    _process_parameters_
    assert equal 'declare -- zero="0"' "${_results_[0]}"
  end

  it "allows multiple items"
    _results_=()
    _arguments_=( 0 1 )
    _parameters_=( zero one )
    _process_parameters_
    assert equal 'declare -- zero="0" declare -- one="1"' "${_results_[*]}"
  end

  it "accepts empty values"
    _results_=()
    _arguments_=()
    _parameters_=( zero )
    _process_parameters_
    assert equal 'declare -- zero=""' "${_results_[0]}"
  end

  it "allows default values"
    _results_=()
    _arguments_=()
    _parameters_=( zero="one two" )
    _process_parameters_
    assert equal 'declare -- zero="one two"' "${_results_[0]}"
  end

  it "overrides default values with empty parameters"
    _results_=()
    _arguments_=( '' )
    _parameters_=( zero="one two" )
    _process_parameters_
    assert equal 'declare -- zero=""' "${_results_[0]}"
  end
end

describe '_ref_declaration_'
  it "declares a scalar with the name of a variable with a normal value"
    unset -v one
    sample=one
    _results_=()
    _ref_declaration_ result sample
    assert equal 'declare -- result="sample"' "${_results_[0]}"
  end

  it "declares a scalar with the value of a variable which is the name of another variable"
    one=1
    sample=one
    _results_=()
    _ref_declaration_ result sample
    assert equal 'declare -- result="one"' "${_results_[0]}"
  end
end

describe 'reta'
  it "sets an array of values in a named variable"
    my_func() { local examples=( one two three ); local "$1" && reta examples "$1" ;}
    samples=()
    my_func samples
    printf -v expected 'declare -a samples=%s([0]="one" [1]="two" [2]="three")%s' \' \'
    assert equal "$expected" "$(declare -p samples)"
  end

  it "sets an array of values in a named variable of the same name as a local"
    my_func() { local samples=( one two three ); local "$1" && reta samples "$1" ;}
    samples=()
    my_func samples
    printf -v expected 'declare -a samples=%s([0]="one" [1]="two" [2]="three")%s' \' \'
    assert equal "$expected" "$(declare -p samples)"
  end

  it "sets an array of values in a named variable with a literal"
    my_func() { local "$1" && reta '( one two three )' "$1" ;}
    samples=()
    my_func samples
    printf -v expected 'declare -a samples=%s([0]="one" [1]="two" [2]="three")%s' \' \'
    assert equal "$expected" "$(declare -p samples)"
  end
end

describe 'reth'
  it "sets an hash of values in a named variable"
    my_func() { local -A sampleh=( [one]=1 [two]=2 [three]=3 ); local "$1" && reth sampleh "$1" ;}
    declare -A sampleh=()
    my_func sampleh
    printf -v expected 'declare -A sampleh=%s([one]="1" [two]="2" [three]="3" )%s' \' \'
    assert equal "$expected" "$(declare -p sampleh)"
  end

  it "sets an hash of values in a named variable with a literal"
    my_func() { local "$1" && reth '( [one]=1 [two]=2 [three]=3 )' "$1" ;}
    declare -A sampleh=()
    my_func sampleh
    printf -v expected 'declare -A sampleh=%s([one]="1" [two]="2" [three]="3" )%s' \' \'
    assert equal "$expected" "$(declare -p sampleh)"
  end
end

describe 'rets'
  it "sets a string value in a named variable"
    my_func() { local sample=0; local "$1" && rets sample "$1" ;}
    sample=''
    my_func sample
    assert equal '0' "$sample"
  end

  it "sets a string value in a named variable with a literal"
    my_func() { local "$1" && rets 0 "$1" ;}
    sample=''
    my_func sample
    assert equal '0' "$sample"
  end
end

describe '_scalar_declaration_'
  it "declares a scalar with a supplied value"
    unset -v sample
    _results_=()
    _scalar_declaration_ result sample
    assert equal 'declare -- result="sample"' "${_results_[0]}"
  end

  it "declares a scalar with the value of a supplied variable name"
    sample=one
    _results_=()
    _scalar_declaration_ result sample
    assert equal 'declare -- result="one"' "${_results_[0]}"
  end

  it "declares a scalar with a supplied value when the value is also the name of an array"
    samples=()
    _results_=()
    _scalar_declaration_ result samples
    assert equal 'declare -- result="samples"' "${_results_[0]}"
  end

  it "declares a scalar with a supplied value when the value is also the name of a hash"
    declare -A sampleh=()
    _results_=()
    _scalar_declaration_ result sampleh
    assert equal 'declare -- result="sampleh"' "${_results_[0]}"
  end

  it "declares a scalar with the value of a supplied array item reference"
    samples=( one )
    _results_=()
    _scalar_declaration_ result samples[0]
    assert equal 'declare -- result="one"' "${_results_[0]}"
  end

  it "declares a scalar with the value of a supplied hash item reference"
    declare -A sampleh=( [one]=1 )
    _results_=()
    _scalar_declaration_ result sampleh[one]
    assert equal 'declare -- result="1"' "${_results_[0]}"
  end
end

describe 'values_of'
  it "declares the values of a hash"
    declare -A sampleh=([zero]=0 [one]=1)
    printf -v expected 'declare -a results=%s([0]="1" [1]="0")%s' \' \'
    assert equal "$expected" "$(values_of sampleh)"
  end
end
