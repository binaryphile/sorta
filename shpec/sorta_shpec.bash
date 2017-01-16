source sorta.bash

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

describe 'keys_of'
  it "declares the keys of a hash"
    declare -A sampleh=([zero]=0 [one]=1)
    printf -v expected 'declare -a results=%s([0]="one" [1]="zero")%s' \' \'
    assert equal "$expected" "$(keys_of sampleh)"
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

  it "allows a literal for parameters with multiple items"
    set -- 0 1
    assert equal 'declare -- zero="0";declare -- one="1"' "$(passed '( zero one )' "$@")"
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

  it "allows default values in literals"
    set --
    assert equal 'declare -- zero="one two"' "$(passed '( zero="one two" )' "$@")"
  end

  it "overrides default values with empty parameters"
    set -- ""
    params=( zero="one two" )
    assert equal 'declare -- zero=""' "$(passed params "$@")"
  end

  it "creates a scalar declaration from a scalar variable name"
    sample=0
    set -- sample
    params=( zero )
    assert equal 'declare -- zero="0"' "$(passed params "$@")"
  end

  it "doesn't create a declaration from a variable name of the wrong type"
    declare -A sampleh=()
    set -- sampleh
    params=( zero )
    assert equal 'declare -- zero="sampleh"' "$(passed params "$@")"
  end

  it "creates a scalar declaration from an indexed array reference"
    samples=( 0 )
    set -- samples[0]
    params=( zero )
    assert equal 'declare -- zero="0"' "$(passed params "$@")"
  end

  it "ignores an what appears to be an unset array reference"
    samples=( 0 )
    set -- samples[1]
    params=( zero )
    assert equal 'declare -- zero="samples[1]"' "$(passed params "$@")"
  end

  it "works for two arguments"
    set -- 0 1
    params=( zero one )
    assert equal 'declare -- zero="0";declare -- one="1"' "$(passed params "$@")"
  end

  it "accepts strings with quotes"
    set -- 'string with "quotes"'
    params=( zero )
    assert equal 'declare -- zero="string with \"quotes\""' "$(passed params "$@")"
  end

  it "creates an array declaration from a special syntax"
    values=( zero one )
    set -- values
    params=( @array )
    expected=$(printf 'declare -a array=%s([0]="zero" [1]="one")%s' \' \')
    assert equal "$expected" "$(passed params "$@")"
  end

  it "errors on a non-declared array"; (
    unset -v values
    set -- values
    params=( @array )
    passed params "$@" >/dev/null 2>&1
    assert unequal 0 $?
    return "$_shpec_failures" )
  end

  it "creates an array declaration with quotes"
    values=( '"zero one"' two )
    set -- values
    params=( @array )
    expected=$(printf 'declare -a array=%s([0]="\\"zero one\\"" [1]="two")%s' \' \')
    assert equal "$expected" "$(passed params "$@")"
  end

  it "creates a hash declaration from a special syntax"
    declare -A values=( [zero]=0 [one]=1 )
    set -- values
    params=( %hash )
    expected=$(printf 'declare -A hash=%s([one]="1" [zero]="0" )%s' \' \')
    assert equal "$expected" "$(passed params "$@")"
  end

  it "creates a dereference declaration from a special syntax"
    set -- var
    params=( '&ref' )
    assert equal 'declare -n ref="var"' "$(passed params "$@")"
  end

  it "accepts an array literal"
    set -- '([0]="zero" [1]="one")'
    params=( @array )
    expected=$(printf 'declare -a array=%s([0]="zero" [1]="one")%s' \' \')
    assert equal "$expected" "$(passed params "$@")"
  end

  it "accepts an array literal without indices"
    set -- '( "zero" "one" )'
    params=( @array )
    expected=$(printf 'declare -a array=%s([0]="zero" [1]="one")%s' \' \')
    assert equal "$expected" "$(passed params "$@")"
  end

  it "accepts an empty array literal"
    set -- '()'
    params=( @array )
    expected=$(printf 'declare -a array=%s()%s' \' \')
    assert equal "$expected" "$(passed params "$@")"
  end

  it "allows array default values"
    set --
    params=( @array='( "zero" "one" )' )
    expected=$(printf 'declare -a array=%s([0]="zero" [1]="one")%s' \' \' )
    assert equal "$expected" "$(passed params "$@")"
  end

  it "accepts a hash literal"
    set -- '( [zero]="0" [one]="1" )'
    params=( %hash )
    expected=$(printf 'declare -A hash=%s([one]="1" [zero]="0" )%s' \' \' )
    assert equal "$expected" "$(passed params "$@")"
  end

  it "accepts an empty hash literal"
    set -- '()'
    params=( %hash )
    expected=$(printf 'declare -A hash=%s()%s' \' \' )
    assert equal "$expected" "$(passed params "$@")"
  end

  it "allows hash default values"
    set --
    params=( %hash='([zero]="0" [one]="1")' )
    expected=$(printf 'declare -A hash=%s([one]="1" [zero]="0" )%s' \' \')
    assert equal "$expected" "$(passed params "$@")"
  end

  it "accepts an empty array default"
    set --
    params=( @array='()' )
    expected=$(printf 'declare -a array=%s()%s' \' \' )
    assert equal "$expected" "$(passed params "$@")"
  end

  it "accepts an empty array default literal"
    set --
    expected=$(printf 'declare -a array=%s()%s' \' \' )
    assert equal "$expected" "$(passed '( @array="()" )' "$@")"
  end

  it "allows arrays with single quoted values"
    set -- "( '*' )"
    params=( @samples )
    expected=$(printf 'declare -a samples=%s([0]="*")%s' \' \')
    assert equal "$expected" "$(passed params "$@")"
  end

  it "accepts an empty hash default"
    set --
    params=( %hash='()' )
    expected=$(printf 'declare -A hash=%s()%s' \' \' )
    assert equal "$expected" "$(passed params "$@")"
  end

  it "accepts an empty hash default literal"
    set --
    expected=$(printf 'declare -A hash=%s()%s' \' \' )
    assert equal "$expected" "$(passed '( %hash="()" )' "$@")"
  end

  it "creates a reference to a variable name even when defined"
    sample=one
    set -- sample
    params=( '*ref' )
    assert equal 'declare -- ref="sample"' "$(passed params "$@")"
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

describe 'values_of'
  it "declares the values of a hash"
    declare -A sampleh=([zero]=0 [one]=1)
    printf -v expected 'declare -a results=%s([0]="1" [1]="0")%s' \' \'
    assert equal "$expected" "$(values_of sampleh)"
  end
end
