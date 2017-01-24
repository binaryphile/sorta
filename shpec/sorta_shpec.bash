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

describe '_in_'
  it "returns true if it finds an item in an array"
    samples=( one two )
    _in_ one "${samples[@]}"
    assert equal 0 $?
  end

  it "returns false if it doesn't find an item in an array"
    samples=( one two )
    stop_on_error off
    _in_ zero "${samples[@]}"
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

  it "returns false if argument isn't the name of a variable"
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

  it "returns false if the named variable is a hash"
    declare -A sampleh=( [example]=one )
    stop_on_error off
    _is_ref_ sampleh
    assert unequal 0 $?
    stop_on_error
  end
end

describe '_is_scalar_set_'
  it "returns true if the argument is the name of a scalar variable"
    sample=one
    _is_scalar_set_ sample
    assert equal 0 $?
  end

  it "returns true if the argument is the name of a scalar variable starting with underscore"
    _sample=one
    _is_scalar_set_ _sample
    assert equal 0 $?
  end

  it "returns true if the argument is an indexed item of an array variable"
    samples=( one )
    _is_scalar_set_ samples[0]
    assert equal 0 $?
  end

  it "returns true if the argument is an indexed item of a hash variable"
    declare -A sampleh=( [one]=1 )
    _is_scalar_set_ sampleh[one]
    assert equal 0 $?
  end

  it "returns false if the argument is an array index that isn't set"
    samples=( one )
    stop_on_error off
    _is_scalar_set_ samples[1]
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument is a hash index that isn't set"
    sampleh=( [one]=1 )
    stop_on_error off
    _is_scalar_set_ sampleh[two]
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument doesn't exist"
    unset -v samples
    stop_on_error off
    _is_scalar_set_ samples[0]
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument doesn't start with a variable name character"
    set -- one
    stop_on_error off
    _is_scalar_set_ 1
    assert unequal 0 $?
    stop_on_error
  end
end

describe '_is_set_'
  it "returns true if the named scalar exists"
    sample=''
    _is_set_ sample
    assert equal 0 $?
  end

  it "returns true if the named array item is set"
    samples=( '' )
    _is_set_ samples[0]
    assert equal 0 $?
  end

  it "returns false if the named scalar doesn't exist"
    unset -v sample
    stop_on_error off
    _is_set_ sample
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

  it "errors if _ref_declaration_ errors"
    unset -v sample
    _results_=()
    stop_on_error off
    _map_arg_type_ '*ref' sample
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

  it "accepts empty values"
    set --
    params=( zero )
    assert equal 'declare -- zero=""' "$(passed params "$@")"
  end

  it "allows default values"
    set --
    params=( zero="one two" )
    assert equal 'declare -- zero="one two"' "$(passed params "$@")"
  end

  it "overrides default values with empty parameters"
    set -- ''
    params=( zero="one two" )
    assert equal 'declare -- zero=""' "$(passed params "$@")"
  end

  it "doesn't work if the params list is named '_argument_'"
    set -- ''
    _argument_=( sample )
    stop_on_error off
    passed _argument_ "$@" >/dev/null
    assert unequal 0 $?
    stop_on_error
  end

  it "doesn't work if the params list is named '_arguments_'"
    set -- ''
    _arguments_=( sample )
    stop_on_error off
    passed _arguments_ "$@" >/dev/null
    assert unequal 0 $?
    stop_on_error
  end

  it "doesn't work if the params list is named '_i_'"
    set -- ''
    _i_=( sample )
    stop_on_error off
    passed _i_ "$@" >/dev/null
    assert unequal 0 $?
    stop_on_error
  end

  it "doesn't work if the params list is named '_name_'"
    set -- ''
    _name_=( sample )
    stop_on_error off
    passed _name_ "$@" >/dev/null
    assert unequal 0 $?
    stop_on_error
  end

  it "doesn't work if the params list is named '_names_'"
    set -- ''
    _names_=( sample )
    stop_on_error off
    passed _names_ "$@" >/dev/null
    assert unequal 0 $?
    stop_on_error
  end

  it "doesn't work if the params list is named '_parameter_'"
    set -- ''
    _parameter_=( sample )
    stop_on_error off
    passed _parameter_ "$@" >/dev/null
    assert unequal 0 $?
    stop_on_error
  end

  it "doesn't work if the params list is named '_parameters_'"
    set -- ''
    _parameters_=( sample )
    stop_on_error off
    passed _parameters_ "$@" >/dev/null
    assert unequal 0 $?
    stop_on_error
  end

  it "doesn't work if the params list is named '_results_'"
    set -- ''
    _results_=( sample )
    stop_on_error off
    passed _results_ "$@" >/dev/null
    assert unequal 0 $?
    stop_on_error
  end

  it "doesn't work if the params list is named '_temp_'"
    set -- ''
    _temp_=( sample )
    stop_on_error off
    passed _temp_ "$@" >/dev/null
    assert unequal 0 $?
    stop_on_error
  end

  it "errors if passed an indexed item"
    sample=''
    params=( sample )
    stop_on_error off
    passed params[0] "$@" >/dev/null
    assert unequal 0 $?
    stop_on_error
  end

  it "errors if _map_arg_type_ errors"
    set -- ''
    params=( '*ref' )
    stop_on_error off
    passed params "$@" >/dev/null
    assert unequal 0 $?
    stop_on_error
  end
end

describe '_print_joined_'
  it "prints arguments joined by a delimiter"
    assert equal 'one;two' "$(_print_joined_ ';' one two)"
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

  it "errors on an argument which isn't set"
    unset -v sample
    stop_on_error off
    _ref_declaration_ result sample
    assert unequal 0 $?
    stop_on_error
  end
end

describe 'reta'
  it "sets an array of values in a named variable"
    my_func() { local values=( one two three ); local "$1"= && reta values "$1" ;}
    samples=()
    my_func samples
    printf -v expected 'declare -a samples=%s([0]="one" [1]="two" [2]="three")%s' \' \'
    assert equal "$expected" "$(declare -p samples)"
  end

  it "sets an array of values in a named variable with a literal"
    my_func() { local -a "$1"= && reta '( one two three )' "$1" ;}
    samples=()
    my_func samples
    printf -v expected 'declare -a samples=%s([0]="one" [1]="two" [2]="three")%s' \' \'
    assert equal "$expected" "$(declare -p samples)"
  end
end

describe 'reth'
  it "sets an hash of values in a named variable"
    my_func() { local -A valueh=( [one]=1 [two]=2 [three]=3 ); local "$1"= && reth valueh "$1" ;}
    declare -A sampleh=()
    my_func sampleh
    printf -v expected 'declare -A sampleh=%s([one]="1" [two]="2" [three]="3" )%s' \' \'
    assert equal "$expected" "$(declare -p sampleh)"
  end

  it "sets an hash of values in a named variable with a literal"
    my_func() { local "$1"= && reth '( [one]=1 [two]=2 [three]=3 )' "$1" ;}
    declare -A sampleh=()
    my_func sampleh
    printf -v expected 'declare -A sampleh=%s([one]="1" [two]="2" [three]="3" )%s' \' \'
    assert equal "$expected" "$(declare -p sampleh)"
  end
end

describe 'rets'
  it "sets a string value in a named variable"
    my_func() { local value=0; local "$1"= && rets value "$1" ;}
    sample=''
    my_func sample
    assert equal '0' "$sample"
  end

  it "sets a string value in a named variable with a literal"
    my_func() { local "$1"= && rets 0 "$1" ;}
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
