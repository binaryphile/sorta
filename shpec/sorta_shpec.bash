source import.bash

shpec_helper_imports=(
  cleanup
  initialize_shpec_helper
  shpec_source
  stop_on_error
  validate_dirname
)
eval "$(importa shpec-helper shpec_helper_imports)"
initialize_shpec_helper
stop_on_error=true
stop_on_error

shpec_source lib/sorta.bash

describe '__array_declaration'
  it "declares an array from an existing array"
    samples=( one two )
    __results=()
    __array_declaration array samples a
    printf -v expected 'declare -a array=%s([0]="one" [1]="two")%s' \' \'
    assert equal "$expected" "${__results[0]}"
  end

  it "passes a literal declaration to _literal_declaration_"
    __results=()
    __array_declaration array '( one two )' a
    printf -v expected 'declare -a array=%s([0]="one" [1]="two")%s' \' \'
    assert equal "$expected" "${__results[0]}"
  end

  it "declares a hash from an existing hash"
    declare -A sampleh=( [one]=1 [two]=2 )
    __results=()
    __array_declaration hash sampleh A
    printf -v expected 'declare -A hash=%s([one]="1" [two]="2" )%s' \' \'
    assert equal "$expected" "${__results[0]}"
  end

  it "errors on an array with a hash option"
    samples=( one two )
    __results=()
    stop_on_error off
    __array_declaration array samples A
    assert unequal 0 $?
    stop_on_error
  end

  it "propagates an error from _literal_declaration_"
    __results=()
    stop_on_error off
    __array_declaration array '( one two )' A
    assert unequal 0 $?
    stop_on_error
  end

  it "errors on a hash with an array option"
    declare -A sampleh=( [one]=1 [two]=2 )
    __results=()
    stop_on_error off
    __array_declaration hash sampleh a
    assert unequal 0 $?
    stop_on_error
  end

  it "doesn't work if the argument is named _argument_"
    __argument=( one two )
    __results=()
    stop_on_error off
    __array_declaration array __argument a
    assert unequal 0 $?
    stop_on_error
  end

  # it "works if the argument is named _argument_"
  #   __argument=( one two )
  #   __results=()
  #   __array_declaration array __arguments a
  #   printf -v expected 'declare -a array=%s([0]="one" [1]="two")%s' \' \'
  #   assert equal "$expected" "${__results[0]}"
  # end

  it "works if the argument is named _arguments_"
    __arguments=( one two )
    __results=()
    __array_declaration array __arguments a
    printf -v expected 'declare -a array=%s([0]="one" [1]="two")%s' \' \'
    assert equal "$expected" "${__results[0]}"
  end

  it "doesn't work if the argument is named _parameter_"
    __parameter=( one two )
    __results=()
    stop_on_error off
    __array_declaration array __parameter a
    assert unequal 0 $?
    stop_on_error
  end

  # it "works if the argument is named _parameter_"
  #   __parameter=( one two )
  #   __results=()
  #   __array_declaration array __parameter a
  #   printf -v expected 'declare -a array=%s([0]="one" [1]="two")%s' \' \'
  #   assert equal "$expected" "${__results[0]}"
  # end

  it "works if the argument is named _parameters_"
    __parameters=( one two )
    __results=()
    __array_declaration array __parameters a
    printf -v expected 'declare -a array=%s([0]="one" [1]="two")%s' \' \'
    assert equal "$expected" "${__results[0]}"
  end

  it "doesn't work if the argument is named _option_"
    __option=( one two )
    __results=()
    stop_on_error off
    __array_declaration array __option a
    assert unequal 0 $?
    stop_on_error
  end

  # it "works if the argument is named _option_"
  #   __option=( one two )
  #   __results=()
  #   __array_declaration array __option a
  #   printf -v expected 'declare -a array=%s([0]="one" [1]="two")%s' \' \'
  #   assert equal "$expected" "${__results[0]}"
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

describe '__contains'
  it "returns true if it finds a string in another string"
    __contains "one" "stones"
    assert equal 0 $?
  end

  it "returns false if it doesn't find a string in another string"
    stop_on_error off
    __contains "xor" "stones"
    assert unequal 0 $?
    stop_on_error
  end
end

describe '__copy_declaration'
  it "creates a declaration from an existing scalar variable with the supplied variable name"
    __results=()
    sample=one
    __copy_declaration sample result
    assert equal 'declare -- result="one"' "${__results[0]}"
  end

  it "errors if the name doesn't exist"
    __results=()
    unset -v sample
    stop_on_error off
    __copy_declaration sample result
    assert unequal 0 $?
    stop_on_error
  end
end

describe '__deref_declaration'
  it "declares the parameter as dereferencing the argument"
    example=''
    sample=example
    __results=()
    __deref_declaration result sample
    assert equal 'declare -n result="sample"' "${__results[0]}"
  end

  it "errors if the named variable is not set"
    unset -v sample
    __results=()
    stop_on_error off
    __deref_declaration result sample
    assert unequal 0 $?
    stop_on_error
  end

  it "errors if the named variable is an array item reference"
    samples=( one )
    __results=()
    stop_on_error off
    __deref_declaration result samples[0]
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

describe '__includes'
  it "returns true if a string is in an array"
    unset -v one
    samples=( one two three )
    __includes one samples
    assert equal 0 $?
  end

  it "returns true if a string is in an array more than once"
    unset -v one
    samples=( one two three one )
    __includes one samples
    assert equal 0 $?
  end

  it "returns false if a string isn't in an array"
    samples=( one two three )
    stop_on_error off
    __includes four samples
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if only a substring is in an array"
    samples=( one two three )
    stop_on_error off
    __includes on samples
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

describe '__is_array'
  it "returns true if the argument is the name of an array"
    samples=( one )
    __is_array samples
    assert equal 0 $?
  end

  it "returns false if the argument is an indexed array reference"
    samples=( one )
    stop_on_error off
    __is_array samples[0]
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument is the name of a scalar"
    sample=one
    stop_on_error off
    __is_array sample
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument is the name of a hash"
    declare -A sampleh=( [one]=1 )
    stop_on_error off
    __is_array sampleh
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument is unset"
    unset -v sample
    stop_on_error off
    __is_array sample
    assert unequal 0 $?
    stop_on_error
  end
end

describe '__is_array_literal'
  it "returns true if the argument is a string starting and ending with parentheses"
    __is_array_literal '()'
    assert equal 0 $?
  end

  it "returns false if the argument doesn't end with a parenthesis"
    stop_on_error off
    __is_array_literal '('
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument doesn't start with a parenthesis"
    stop_on_error off
    __is_array_literal ')'
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument is blank"
    stop_on_error off
    __is_array_literal ''
    assert unequal 0 $?
    stop_on_error
  end
end

describe '__is_declared_array'
  it "returns true for a declared array"
    unset -v samples
    declare -a samples
    __is_declared_array samples
    assert equal 0 $?
  end

  it "returns false for not declared array"
    unset -v samples
    stop_on_error off
    __is_declared_array samples
    assert unequal 0 $?
    stop_on_error
  end
end

describe '__is_declared_hash'
  it "returns true for a declared array"
    unset -v sampleh
    declare -A sampleh
    __is_declared_hash sampleh
    assert equal 0 $?
  end

  it "returns false for not declared array"
    unset -v sampleh
    stop_on_error off
    __is_declared_hash sampleh
    assert unequal 0 $?
    stop_on_error
  end
end

describe '__is_declared_scalar'
  it "returns true for a declared scalar"
    unset -v sample
    samplef() { local sample; __is_declared_scalar sample ;}
    samplef
    assert equal 0 $?
  end

  it "returns false for not declared scalar"
    unset -v sample
    samplef() { __is_declared_scalar sample ;}
    stop_on_error off
    samplef
    assert unequal 0 $?
    stop_on_error
  end

  it "doesn't alter a global variable's contents"
    sample=one
    samplef() { local sample; __is_declared_scalar sample ;}
    samplef
    assert equal one "$sample"
  end
end

describe '__is_declared_type'
  it "returns true for a declared array"
    unset -v samples
    declare -a samples
    __is_declared_type a samples
    assert equal 0 $?
  end

  it "returns false for not declared array"
    unset -v samples
    stop_on_error off
    __is_declared_type a samples
    assert unequal 0 $?
    stop_on_error
  end
end


describe '__is_hash_literal'
  it "returns true for a parenthetical list of indices"
    __is_hash_literal '([one]=1)'
    assert equal 0 $?
  end

  it "returns true for a parenthetical list of indices with a leading space"
    __is_hash_literal '( [one]=1)'
    assert equal 0 $?
  end

  it "returns false for a parenthetical list without an initial bracket"
    stop_on_error off
    __is_hash_literal '({one]=1 )'
    assert unequal 0 $?
    stop_on_error
  end
end

describe '__is_name'
  it "returns true if argument is the name of a scalar"
    sample=one
    __is_name sample
    assert equal 0 $?
  end

  it "returns true if argument is the name of an array"
    samples=( one )
    __is_name samples
    assert equal 0 $?
  end

  it "returns true if argument is the name of a hash"
    declare -A sampleh=( [one]=1 )
    __is_name sampleh
    assert equal 0 $?
  end

  it "returns false if argument is an indexed array reference"
    samples=( one )
    stop_on_error off
    __is_name samples[0]
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if argument is an indexed hash reference"
    declare -A sampleh=( [one]=1 )
    stop_on_error off
    __is_name samples[one]
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if argument is unset"
    unset -v sample
    stop_on_error off
    __is_name sample
    assert unequal 0 $?
    stop_on_error
  end
end

describe '__is_ref'
  it "returns true if the named variable holds the name of another variable"
    unset -v example
    example=''
    sample=example
    __is_ref sample
    assert equal 0 $?
  end

  it "returns false if the named variable just holds a string"
    unset -v example
    sample=example
    stop_on_error off
    __is_ref sample
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the named variable is an array"
    samples=( example )
    stop_on_error off
    __is_ref samples
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the named variable is an array whose first element is a 'ref'"
    example=one
    samples=( example )
    stop_on_error off
    __is_ref samples
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the named variable is a hash"
    declare -A sampleh=( [example]=one )
    stop_on_error off
    __is_ref sampleh
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the named variable is a hash whose first element in a 'ref'"
    example=one
    declare -A sampleh=( [0]=example )
    stop_on_error off
    __is_ref sampleh
    assert unequal 0 $?
    stop_on_error
  end
end

describe '__is_set'
  it "returns true if the argument is the name of a scalar variable"
    sample=one
    __is_set sample
    assert equal 0 $?
  end

  it "returns true if the argument is the name of a scalar variable starting with underscore"
    _sample=one
    __is_set _sample
    assert equal 0 $?
  end

  it "returns true if the argument is an indexed item of an array variable"
    samples=( one )
    __is_set samples[0]
    assert equal 0 $?
  end

  it "returns true if the argument is an indexed item of a hash variable"
    declare -A sampleh=( [one]=1 )
    __is_set sampleh[one]
    assert equal 0 $?
  end

  it "returns false if the argument is an array index that isn't set"
    samples=( one )
    stop_on_error off
    __is_set samples[1]
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument is a hash index that isn't set"
    declare -A sampleh=( [one]=1 )
    stop_on_error off
    __is_set sampleh[two]
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument doesn't exist"
    unset -v samples
    stop_on_error off
    __is_set samples[0]
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument doesn't start with a variable name character"
    set -- one
    stop_on_error off
    __is_set 1
    assert unequal 0 $?
    stop_on_error
  end
end

describe '__is_type'
  it "returns true if the arguments are a scalar and a dash"
    sample=one
    __is_type sample -
    assert equal 0 $?
  end

  it "returns false if the arguments are a scalar and an a"
    sample=one
    stop_on_error off
    __is_type sample a
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the arguments are a scalar and an A"
    sample=one
    stop_on_error off
    __is_type sample A
    assert unequal 0 $?
    stop_on_error
  end

  it "returns true if the arguments are an array and an a"
    samples=( one )
    __is_type samples a
    assert equal 0 $?
  end

  it "returns false if the arguments are an array and a dash"
    samples=( one )
    stop_on_error off
    __is_type samples -
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the arguments are an array and an A"
    samples=( one )
    stop_on_error off
    __is_type samples -
    assert unequal 0 $?
    stop_on_error
  end

  it "returns true if the arguments are a hash and an A"
    declare -A sampleh=( [one]=1 )
    __is_type sampleh A
    assert equal 0 $?
  end

  it "returns false if the arguments are a hash and a dash"
    declare -A sampleh=( [one]=1 )
    stop_on_error off
    __is_type sampleh -
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the arguments are a hash and an a"
    declare -A sampleh=( [one]=1 )
    stop_on_error off
    __is_type sampleh a
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument doesn't exist and has a dash"
    unset -v sample
    stop_on_error off
    __is_type sample -
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument doesn't exist and has an a"
    unset -v sample
    stop_on_error off
    __is_type sample a
    assert unequal 0 $?
    stop_on_error
  end

  it "returns false if the argument doesn't exist and has an A"
    unset -v sample
    stop_on_error off
    __is_type sample A
    assert unequal 0 $?
    stop_on_error
  end
end

describe 'keys_of'
  it "declares the keys of a hash"
    declare -A sampleh=([zero]=0 [one]=1)
    expected='declare -a results='\''([0]="one" [1]="zero")'\'
    assert equal "$expected" "$(keys_of sampleh)"
  end

  it "returns the keys of a hash"
    declare examples=()
    declare -A sampleh=([zero]=0 [one]=1)
    keys_of sampleh examples
    expected='declare -a examples='\''([0]="one" [1]="zero")'\'
    assert equal "$expected" "$(declare -p examples)"
  end
end

describe '__literal_declaration'
  it "declares an array from an array literal"
    __results=()
    __literal_declaration array '( one two )' a
    printf -v expected 'declare -a array=%s([0]="one" [1]="two")%s' \' \'
    assert equal "$expected" "${__results[0]}"
  end

  it "declares a hash from a hash literal"
    __results=()
    __literal_declaration hash '( [one]=1 [two]=2 )' A
    printf -v expected 'declare -A hash=%s([one]="1" [two]="2" )%s' \' \'
    assert equal "$expected" "${__results[0]}"
  end

  it "errors on an array literal with a hash option"
    __results=()
    stop_on_error off
    __literal_declaration array '( one two )' A
    assert unequal 0 $?
    stop_on_error
  end
end

describe '__map_arg_type'
  it "creates a hash declaration"
    __results=()
    declare -A sampleh=()
    __map_arg_type %resulth sampleh
    printf -v expected 'declare -A resulth=%s()%s' \' \'
    assert equal "$expected" "${__results[0]}"
  end

  it "creates a deref declaration"
    __results=()
    example=''
    sample=example
    __map_arg_type '&result' sample
    assert equal 'declare -n result="sample"' "${__results[0]}"
  end

  it "creates a ref declaration"
    __results=()
    sample=''
    __map_arg_type *result sample
    assert equal 'declare -- result="sample"' "${__results[0]}"
  end

  it "creates an array declaration"
    __results=()
    samples=()
    __map_arg_type @res samples
    printf -v expected 'declare -a res=%s()%s' \' \'
    assert equal "$expected" "${__results[0]}"
  end

  it "creates a scalar declaration"
    __results=()
    __map_arg_type result sample
    assert equal 'declare -- result=""' "${__results[0]}"
  end

  it "errors if __array_declaration errors on a hash"
    samples=( one two )
    __results=()
    stop_on_error off
    __map_arg_type %hash samples A
    assert unequal 0 $?
    stop_on_error
  end

  it "errors if __array_declaration errors on an array"
    declare -A sampleh=( [one]=1 [two]=2 )
    __results=()
    stop_on_error off
    __map_arg_type @array sampleh a
    assert unequal 0 $?
    stop_on_error
  end
end

describe '__name_from_declaration'
  it "returns the name of a simple declaration"
    result=$(__name_from_declaration 'declare -- sample="one"')
    assert equal sample "$result"
  end

  it "errors if the format doesn't have an equals sign"
    stop_on_error off
    __name_from_declaration 'declare -- sample"one"'
    assert unequal 0 $?
    stop_on_error
  end
end

describe '__names_from_declarations'
  it "returns the name of a single declaration in 'names'"
    declarations=( 'declare -- sample="one"' )
    names=()
    __names_from_declarations
    printf -v expected 'declare -a names=%s([0]="sample")%s' \' \'
    assert equal "$expected" "$(declare -p names)"
  end

  it "errors on a declaration missing an equals sign"
    declarations=( 'declare -- sample"one"' )
    names=()
    stop_on_error off
    __names_from_declarations
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

  it "works if the params list is named '__argument'"
    unset -v one
    set -- one
    __argument=( sample )
    assert equal 'declare -- sample="one"' "$(passed __argument "$@")"
  end

  it "works if the params list is named '__arguments'"
    unset -v one
    set -- one
    __arguments=( sample )
    assert equal 'declare -- sample="one"' "$(passed __arguments "$@")"
  end

  it "works if the params list is named '__parameters'"
    unset -v one
    set -- one
    __parameters=( sample )
    assert equal 'declare -- sample="one"' "$(passed __parameters "$@")"
  end

  it "works if the params list is named '__results'"
    unset -v one
    set -- one
    __results=( sample )
    assert equal 'declare -- sample="one"' "$(passed __results "$@")"
  end

  it "works if the params list is named '__option'"
    unset -v one
    set -- one
    __option=( sample )
    assert equal 'declare -- sample="one"' "$(passed __option "$@")"
  end

  # it "doesn't work if the params list is named '__argument'"
  #   set -- ''
  #   __argument=( sample )
  #   stop_on_error off
  #   passed __argument "$@" >/dev/null
  #   assert unequal 0 $?
  #   stop_on_error
  # end
  #
  # it "doesn't work if the params list is named '__arguments'"
  #   set -- ''
  #   __arguments=( sample )
  #   stop_on_error off
  #   passed __arguments "$@" >/dev/null
  #   assert unequal 0 $?
  #   stop_on_error
  # end
  #
  # it "doesn't work if the params list is named '__i'"
  #   set -- ''
  #   __i=( sample )
  #   stop_on_error off
  #   passed __i "$@" >/dev/null
  #   assert unequal 0 $?
  #   stop_on_error
  # end
  #
  # it "doesn't work if the params list is named '__parameter'"
  #   set -- ''
  #   __parameter=( sample )
  #   stop_on_error off
  #   passed __parameter "$@" >/dev/null
  #   assert unequal 0 $?
  #   stop_on_error
  # end
  #
  # it "doesn't work if the params list is named '__parameters'"
  #   set -- ''
  #   __parameters=( sample )
  #   stop_on_error off
  #   passed __parameters "$@" >/dev/null
  #   assert unequal 0 $?
  #   stop_on_error
  # end
  #
  # it "doesn't work if the params list is named '__results'"
  #   set -- ''
  #   __results=( sample )
  #   stop_on_error off
  #   passed __results "$@" >/dev/null
  #   assert unequal 0 $?
  #   stop_on_error
  # end

  it "errors if __process_parameters errors"
    set -- ''
    params=( '*ref' )
    stop_on_error off
    passed params "$@" >/dev/null
    assert unequal 0 $?
    stop_on_error
  end
end

describe '__print_joined'
  it "prints arguments joined by a delimiter"
    assert equal 'one;two' "$(__print_joined ';' one two)"
  end
end

describe '__process_parameters'
  it "creates a scalar declaration from an array naming a single parameter with the value passed after"
    __results=()
    __arguments=( 0 )
    __parameters=( zero )
    __process_parameters
    assert equal 'declare -- zero="0"' "${__results[0]}"
  end

  it "allows multiple items"
    __results=()
    __arguments=( 0 1 )
    __parameters=( zero one )
    __process_parameters
    assert equal 'declare -- zero="0" declare -- one="1"' "${__results[*]}"
  end

  it "accepts empty values"
    __results=()
    __arguments=()
    __parameters=( zero )
    __process_parameters
    assert equal 'declare -- zero=""' "${__results[0]}"
  end

  it "allows default values"
    __results=()
    __arguments=()
    __parameters=( zero="one two" )
    __process_parameters
    assert equal 'declare -- zero="one two"' "${__results[0]}"
  end

  it "overrides default values with empty parameters"
    __results=()
    __arguments=( '' )
    __parameters=( zero="one two" )
    __process_parameters
    assert equal 'declare -- zero=""' "${__results[0]}"
  end

  it "errors if __map_arg_type errors"
    __results=()
    __arguments=( '' )
    __parameters=( '*ref' )
    stop_on_error off
    __process_parameters
    assert unequal 0 $?
    stop_on_error
  end
end

describe '__ref_declaration'
  it "declares a scalar with the name of a variable with a normal value"
    unset -v one
    sample=one
    __results=()
    __ref_declaration result sample
    assert equal 'declare -- result="sample"' "${__results[0]}"
  end

  it "declares a scalar with the value of a variable which is the name of another variable"
    one=1
    sample=one
    __results=()
    __ref_declaration result sample
    assert equal 'declare -- result="one"' "${__results[0]}"
  end

  it "errors on an argument which isn't set"
    unset -v sample
    stop_on_error off
    __ref_declaration result sample
    assert unequal 0 $?
    stop_on_error
  end

  it "errors on a blank argument"
    stop_on_error off
    __ref_declaration result ''
    assert unequal 0 $?
    stop_on_error
  end
end

describe 'ret'
  it "calls _ret"; (
    stub_command _ret 'echo called'

    assert equal called "$(ret)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe '__scalar_declaration'
  it "declares a scalar with a supplied value"
    unset -v sample
    __results=()
    __scalar_declaration result sample
    assert equal 'declare -- result="sample"' "${__results[0]}"
  end

  it "declares a scalar with the value of a supplied variable name"
    sample=one
    __results=()
    __scalar_declaration result sample
    assert equal 'declare -- result="one"' "${__results[0]}"
  end

  it "declares a scalar with a supplied value when the value is also the name of an array"
    samples=()
    __results=()
    __scalar_declaration result samples
    assert equal 'declare -- result="samples"' "${__results[0]}"
  end

  it "declares a scalar with a supplied value when the value is also the name of a hash"
    declare -A sampleh=()
    __results=()
    __scalar_declaration result sampleh
    assert equal 'declare -- result="sampleh"' "${__results[0]}"
  end

  it "declares a scalar with the value of a supplied array item reference"
    samples=( one )
    __results=()
    __scalar_declaration result samples[0]
    assert equal 'declare -- result="one"' "${__results[0]}"
  end

  it "declares a scalar with the value of a supplied hash item reference"
    declare -A sampleh=( [one]=1 )
    __results=()
    __scalar_declaration result sampleh[one]
    assert equal 'declare -- result="1"' "${__results[0]}"
  end
end

describe 'values_of'
  it "declares the values of a hash"
    declare -A sampleh=([zero]=0 [one]=1)
    printf -v expected 'declare -a results=%s([0]="1" [1]="0")%s' \' \'
    assert equal "$expected" "$(values_of sampleh)"
  end
end
