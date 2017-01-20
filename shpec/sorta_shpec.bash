source sorta.bash

describe '_array_declaration'
  it "declares an array from an existing array"
    samples=( one two )
    results=()
    _array_declaration array samples a
    printf -v expected 'declare -a array=%s([0]="one" [1]="two")%s' \' \'
    assert equal "$expected" "${results[0]}"
  end

  it "passes a literal declaration to _literal_declaration"
    results=()
    _array_declaration array '( one two )' a
    printf -v expected 'declare -a array=%s([0]="one" [1]="two")%s' \' \'
    assert equal "$expected" "${results[0]}"
  end

  it "declares a hash from an existing hash"
    declare -A sampleh=( [one]=1 [two]=2 )
    results=()
    _array_declaration hash sampleh A
    printf -v expected 'declare -A hash=%s([one]="1" [two]="2" )%s' \' \'
    assert equal "$expected" "${results[0]}"
  end

  it "errors on an array with a hash option"
    samples=( one two )
    results=()
    _array_declaration array samples A
    assert unequal 0 $?
  end

  it "propagates an error from _literal_declaration"
    results=()
    _array_declaration array '( one two )' A
    assert unequal 0 $?
  end

  it "errors on a hash with an array option"
    declare -A sampleh=( [one]=1 [two]=2 )
    results=()
    _array_declaration hash sampleh a
    assert unequal 0 $?
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

describe '_deref_declaration'
  it "declares the parameter as dereferencing the argument"; (
    example=''
    sample=example
    results=()
    _deref_declaration result sample
    assert equal 'declare -n result="sample"' "${results[0]}"
    return "$_shpec_failures" )
  end

  it "errors if the named variable is not a reference"
    unset -v example
    sample=example
    results=()
    _deref_declaration result sample
    assert unequal 0 $?
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

describe 'intoa'
  it "generates a declaration for a hash with the named keys from the local namespace"; (
    one=1
    two=2
    declare -A hash=()
    printf -v expected 'declare -A hash=%s([one]="1" [two]="2" )%s' \' \'
    assert equal "$expected" "$(intoa hash '( one two )')"
    return "$_shpec_failures" )
  end

  it "generates a declaration for a hash merging the named keys with the existing key(s)"; (
    one=1
    two=2
    declare -A sampleh=([three]=3)
    printf -v expected 'declare -A sampleh=%s([one]="1" [two]="2" [three]="3" )%s' \' \'
    assert equal "$expected" "$(intoa sampleh '( one two )')"
    return "$_shpec_failures" )
  end
end

describe 'intoh'
  it "generates a declaration for a hash with the named keys from the local namespace"; (
    one=1
    two=2
    declare -A hash=()
    printf -v expected 'declare -A hash=%s([dumpty]="2" [humpty]="1" )%s' \' \'
    assert equal "$expected" "$(intoh hash '( [one]=humpty [two]=dumpty )')"
    return "$_shpec_failures" )
  end

  it "generates a declaration for a hash merging the named keys with the existing key(s)"; (
    one=1
    two=2
    declare -A sampleh=([three]=3)
    printf -v expected 'declare -A sampleh=%s([dumpty]="2" [humpty]="1" [three]="3" )%s' \' \'
    assert equal "$expected" "$(intoh sampleh '( [one]=humpty [two]=dumpty )')"
    return "$_shpec_failures" )
  end
end

describe 'intos'
  it "generates a declaration for a hash with the named key from the local namespace"; (
    one=1
    ref=one
    declare -A hash=()
    printf -v expected 'declare -A hash=%s([one]="1" )%s' \' \'
    assert equal "$expected" "$(intos hash ref)"
    return "$_shpec_failures" )
  end

  it "generates a declaration for a hash merging the named key with the existing key(s)"; (
    one=1
    ref=one
    declare -A sampleh=([two]=2)
    printf -v expected 'declare -A sampleh=%s([one]="1" [two]="2" )%s' \' \'
    assert equal "$expected" "$(intos sampleh ref)"
    return "$_shpec_failures" )
  end
end

describe '_is_ref'
  it "returns true if the named variable holds the name of a variable"; (
    unset -v example
    example=''
    sample=example
    _is_ref sample
    assert equal 0 $?
    return "$_shpec_failures" )
  end

  it "returns false if the named variable just holds a string"
    unset -v example
    sample=example
    _is_ref sample
    assert unequal 0 $?
  end
end

describe '_is_set'
  it "returns true if the named scalar has a value"
    sample='example'
    _is_set sample
    assert equal 0 $?
  end

  it "returns true if the named scalar has a blank value"
    sample=''
    _is_set sample
    assert equal 0 $?
  end

  it "returns true if the named array has a value"
    samples=( one )
    _is_set samples
    assert equal 0 $?
  end

  it "returns true if the named array has a blank value"
    samples=()
    _is_set samples
    assert equal 0 $?
  end

  it "returns true if the named hash has a value"
    sampleh=( [one]=1 )
    _is_set sampleh
    assert equal 0 $?
  end

  it "returns true if the named hash has a blank value"
    sampleh=()
    _is_set sampleh
    assert equal 0 $?
  end

  it "returns true if the named array item has a value"
    samples=( one )
    _is_set samples[0]
    assert equal 0 $?
  end

  it "returns true if the named array item has a blank value"
    samples=( '' )
    _is_set samples[0]
    assert equal 0 $?
  end

  it "returns true if the named hash item has a value"
    sampleh=( [one]=1 )
    _is_set sampleh[one]
    assert equal 0 $?
  end

  it "returns true if the named hash item has a blank value"
    sampleh=( [one]='' )
    _is_set sampleh[one]
    assert equal 0 $?
  end

  it "returns false if the named array item does not exist"
    samples=( one )
    _is_set samples[1]
    assert unequal 0 $?
  end

  it "returns false if the named hash item does not exist"
    sampleh=( [one]=1 )
    _is_set sampleh[two]
    assert unequal 0 $?
  end
end

describe 'keys_of'
  it "declares the keys of a hash"
    declare -A sampleh=([zero]=0 [one]=1)
    printf -v expected 'declare -a results=%s([0]="one" [1]="zero")%s' \' \'
    assert equal "$expected" "$(keys_of sampleh)"
  end
end

describe '_literal_declaration'
  it "declares an array from an array literal"
    results=()
    _literal_declaration array '( one two )' a
    printf -v expected 'declare -a array=%s([0]="one" [1]="two")%s' \' \'
    assert equal "$expected" "${results[0]}"
  end

  it "declares a hash from a hash literal"
    results=()
    _literal_declaration hash '( [one]=1 [two]=2 )' A
    printf -v expected 'declare -A hash=%s([one]="1" [two]="2" )%s' \' \'
    assert equal "$expected" "${results[0]}"
  end

  it "errors on an array literal with a hash option"
    results=()
    _literal_declaration array '( one two )' A
    assert unequal 0 $?
  end
end

describe '_map_arg_type'
  it "creates a hash declaration"
    results=()
    declare -A sampleh=()
    _map_arg_type %resulth sampleh
    printf -v expected 'declare -A resulth=%s()%s' \' \'
    assert equal "$expected" "${results[0]}"
  end

  it "creates a deref declaration"; (
    results=()
    example=''
    sample=example
    _map_arg_type '&result' sample
    assert equal 'declare -n result="sample"' "${results[0]}"
    return "$_shpec_failures" )
  end

  it "creates a ref declaration"
    results=()
    sample=''
    _map_arg_type *result sample
    assert equal 'declare -- result="sample"' "${results[0]}"
  end

  it "creates an array declaration"
    results=()
    samples=()
    _map_arg_type @res samples
    printf -v expected 'declare -a res=%s()%s' \' \'
    assert equal "$expected" "${results[0]}"
  end

  it "creates a scalar declaration"
    results=()
    _map_arg_type result sample
    assert equal 'declare -- result=""' "${results[0]}"
  end

  it "errors if _array_declaration errors on a hash"
    samples=( one two )
    results=()
    _map_arg_type %hash samples A
    assert unequal 0 $?
  end

  it "errors if _ref_declaration errors"
    unset -v sample
    results=()
    _map_arg_type *ref sample
    assert unequal 0 $?
  end

  it "errors if _array_declaration errors on an array"
    declare -A sampleh=( [one]=1 [two]=2 )
    results=()
    _map_arg_type @array sampleh a
    assert unequal 0 $?
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

  it "allows a multiple items"
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
    set -- ""
    params=( zero="one two" )
    assert equal 'declare -- zero=""' "$(passed params "$@")"
  end

  it "errors if _map_arg_type errors"
    set -- ''
    params=( '*ref' )
    passed params "$@"
    assert unequal 0 $?
  end
end

describe '_print_joined'
  it "prints arguments joined by a delimiter"
    assert equal 'one;two' "$(_print_joined ';' one two)"
  end
end

describe '_ref_declaration'
  it "declares a scalar with the name of a variable with a normal value"
    unset -v one
    sample=one
    results=()
    _ref_declaration result sample
    assert equal 'declare -- result="sample"' "${results[0]}"
  end

  it "declares a scalar with the value of a variable which is the name of another variable"; (
    one=1
    sample=one
    results=()
    _ref_declaration result sample
    assert equal 'declare -- result="one"' "${results[0]}"
    return "$_shpec_failures" )
  end

  it "errors on an argument which isn't set"
    unset -v sample
    _ref_declaration result sample
    assert unequal 0 $?
  end
end

describe 'reta'
  it "sets an array of values in a named variable"; (
    my_func() { local values=( one two three ); local "$1"= && reta values "$1" ;}
    samples=()
    my_func samples
    printf -v expected 'declare -a samples=%s([0]="one" [1]="two" [2]="three")%s' \' \'
    assert equal "$expected" "$(declare -p samples)"
    return $_shpec_failures )
  end

  it "sets an array of values in a named variable with a literal"; (
    my_func() { local -a "$1"= && reta '( one two three )' "$1" ;}
    samples=()
    my_func samples
    printf -v expected 'declare -a samples=%s([0]="one" [1]="two" [2]="three")%s' \' \'
    assert equal "$expected" "$(declare -p samples)"
    return $_shpec_failures )
  end
end

describe 'reth'
  it "sets an hash of values in a named variable"; (
    my_func() { local -A valueh=( [one]=1 [two]=2 [three]=3 ); local "$1"= && reth valueh "$1" ;}
    declare -A sampleh=()
    my_func sampleh
    printf -v expected 'declare -A sampleh=%s([one]="1" [two]="2" [three]="3" )%s' \' \'
    assert equal "$expected" "$(declare -p sampleh)"
    return $_shpec_failures )
  end

  it "sets an hash of values in a named variable with a literal"; (
    my_func() { local "$1"= && reth '( [one]=1 [two]=2 [three]=3 )' "$1" ;}
    declare -A sampleh=()
    my_func sampleh
    printf -v expected 'declare -A sampleh=%s([one]="1" [two]="2" [three]="3" )%s' \' \'
    assert equal "$expected" "$(declare -p sampleh)"
    return $_shpec_failures )
  end
end

describe 'rets'
  it "sets a string value in a named variable"; (
    my_func() { local value=0; local "$1"= && rets value "$1" ;}
    sample=''
    my_func sample
    assert equal '0' "$sample"
    return $_shpec_failures )
  end

  it "sets a string value in a named variable with a literal"; (
    my_func() { local "$1"= && rets 0 "$1" ;}
    sample=''
    my_func sample
    assert equal '0' "$sample"
    return $_shpec_failures )
  end
end

describe '_scalar_declaration'
  it "declares a scalar with a supplied value"
    unset -v sample
    results=()
    _scalar_declaration result sample
    assert equal 'declare -- result="sample"' "${results[0]}"
  end

  it "declares a scalar with the value of a supplied variable name"
    sample=one
    results=()
    _scalar_declaration result sample
    assert equal 'declare -- result="one"' "${results[0]}"
  end

  it "declares a scalar with a supplied value when the value is also the name of an array"
    samples=()
    results=()
    _scalar_declaration result samples
    assert equal 'declare -- result="samples"' "${results[0]}"
  end

  it "declares a scalar with a supplied value when the value is also the name of a hash"
    declare -A sampleh=()
    results=()
    _scalar_declaration result sampleh
    assert equal 'declare -- result="sampleh"' "${results[0]}"
  end

  it "declares a scalar with the value of a supplied array item reference"; (
    samples=( one )
    results=()
    _scalar_declaration result samples[0]
    assert equal 'declare -- result="one"' "${results[0]}"
    return "$_shpec_failures" )
  end

  it "declares a scalar with the value of a supplied hash item reference"; (
    declare -A sampleh=( [one]=1 )
    results=()
    _scalar_declaration result sampleh[one]
    assert equal 'declare -- result="1"' "${results[0]}"
    return "$_shpec_failures" )
  end
end

describe 'values_of'
  it "declares the values of a hash"
    declare -A sampleh=([zero]=0 [one]=1)
    printf -v expected 'declare -a results=%s([0]="1" [1]="0")%s' \' \'
    assert equal "$expected" "$(values_of sampleh)"
  end
end
