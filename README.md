Sane Parameter Handling in Bash, Sorta [![Build Status](https://travis-ci.org/binaryphile/sorta.svg?branch=master)](https://travis-ci.org/binaryphile/sorta)
======================================

Sorta lets you write Bash functions which:

-   name your function parameters

-   specify the default values of parameters

-   accept variable names as arguments

-   expand those values into your named parameters

-   accept array and hash arguments

-   accept array and hash literals for those parameters

-   return array and hash values

-   pack/unpack variables into/out of hashes as key-value pairs

-   are able to be imported a la carte via `import.bash`

Basically, sorta is about controlling your variable namespace as much as
possible. These features are designed to help you do that.

The `import.bash` library is about doing the same for your function
namespace. See the bottom of this document for information on its usage.

Requires Bash 4.3 or higher.

So bash has an interesting way of passing variables. Since it has to
pass things to commands, which only take strings, it has to expand every
variable reference to a string prior to handing it to a
command/function. It doesn't have a concept of passing anything other
than a string, even though it has structured data types such as arrays
and hashes (a.k.a. associative arrays).

Sorta helps you pass arguments more like other languages do, by variable
name.

Of course this trickery has some consequences, so caveat emptor.

Examples
--------

<table>
<thead>
<tr>
<th>
With Sorta
</th>
<th>
Regular Bash
</th>
</tr>
</thead>
<tbody>
<tr valign="top">
<td>
<pre><code>
myvar=hello

my_function () {
  local _params=( greeting )
  eval "$(passed _params "$@")"

  echo "$greeting"
}

my_function myvar

&gt; hello
</code></pre>
</td>
<td>
<pre><code>
myvar=hello

my_function () {
  local greeting=$1


  echo "$greeting"
}

my_function "$myvar"

&gt; hello
</code></pre>
</td>
</tr>
</tbody>
</table>

Notice the call to `my_function` with the name of the variable, `myvar`,
rather than the shell expansion. `my_function`, however, doesn't see
that name, it just gets the already-expanded value `hello` in
`greeting`.

With the addition of the `eval` call at the beginning of `my_function`,
the function receives variables by name and has them automatically
expanded to their values. However, you can still pass literal strings as
well, such as `my_function "a string"`. Since the value "a string"
doesn't point to a variable, it will be received, unexpanded, into
`greeting`.

The resulting parameters are copies of the values, scoped locally to the
function. Changing their values doesn't change variables in the global
nor calling scopes, as it might if they weren't scoped locally.

Notice that the `passed` function accepts the parameter array by name
(no `"${_params[@]}"` expansion necessary):
`eval "$(passed _params "$@")"`.

You could also use a literal to save a line:
`eval "$(passed '( greeting )' "$@")"`.

So anyway, passing strings like that may be nicer than bash's syntax for
variable expansion, but it's not anything you can't do with bash as-is.

Instead, how about passing a hash and an array directly by name:

<table>
<thead>
<tr>
<th>
With Sorta
</th>
<th>
Regular Bash
</th>
</tr>
</thead>
<tbody>
<tr valign="top">
<td>
<pre><code>
myarray=( zero one )
declare -A myhash=( [zero]=0 [one]=1 )

my_function () {
  local _params=( %hash @array )
  eval "$(passed _params "$@")"




  declare -p hash
  declare -p array
}

my_function myhash myarray

&gt; declare -A hash='([zero]="0" [one]="1" )'
&gt; declare -a array='([0]="zero" [1]="one")'
</code></pre>
</td>
<td>
<pre><code>
myarray=( zero one )
declare -A myhash=( [zero]=0 [one]=1 )

my_function () {
  local hash_name=$1; shift
  local array=( "$@" )
  local -A to_hash

  # since you can't pass a hash in bash
  somehow_copy_the_hash_values_from "$hash_name" "to_hash"
  declare -p hash
  declare -p array
}

my_function myhash "${myarray[@]}"

&gt; declare -A hash='([zero]="0" [one]="1" )'
&gt; declare -a array='([0]="zero" [1]="one")'
</code></pre>
</td>
</tr>
</tbody>
</table>

You can do this with sorta by adding special type designators to the
`_params` list:

    local _params=( %hash @array )

Now your function has copies of `myhash` and `myarray` in the local
variables `hash` and `array`, respectively.

Note that `hash` and `array` could be any variable names, I'm just using
those names for clarity.

Your Dad's bash can't do that easily. As you can see on the right side,
there's no way to pass the hash. You could simply work on the hash
directly in the calling scope without passing it as an argument, but
then your namespaces are bound together. In fact, even passing its name
in as a reference gives the potential for naming conflicts with your
local variables if you aren't careful.

Additionally, with sorta you don't have to use curly brace expansion of
the array, nor worry about separating other arguments from the array
elements with `shift` at the receiving side.

Installation
------------

Clone this repository and place it's `lib` directory on your path.

In your scripts you can then use `source sorta.bash` and it will be
found automatically.

`import.bash` can also be sourced the same way since it's in the `lib`
directory as well. See the bottom of this document for information on
`import`.

Sorta Usage
-----------

Notably, `sorta` is not importable with `import` (see below), as it is
small and coherent enough that it's not meant to be imported by parts.

### Pass Scalar Values (strings and ints)

To write a function which receives variables this way, you need to
declare a local array of parameter names/types, then eval the output of
the `passed` function:

    source sorta.bash

    my_function () {
      local _params=( first second )
      eval "$(passed _params "$@")"

      echo "first: $first"
      echo "second: $second"
    }

Outputs:

    $ my_function 1 2
    first: 1
    second: 2

Similarly, you can call it with variable names:

    $ myvar1=1
    $ myvar2=2
    $ my_function myvar1 myvar2
    first: 1
    second: 2

Notice that no expansion was needed for the variable names. Of course,
that will still work:

    $ my_function "$myvar1" "$myvar2"
    first: 1
    second: 2

But that's because the expansion happens prior to the function call,
making this case the same as the first example which called
`my_function` with numeric literals.

You can also index arrays and hashes when supplying scalars:

    $ array=( 1 2 )
    $ my_function array[0] array[1]
    first: 1
    second: 2

    $ declare -A hash=( [one]=1 [two]=2 )
    $ my_function hash[one] hash[two]
    first: 1
    second: 2

Set Default Values
------------------

Like most high-level languages, setting a default value for a parameter
allows you to not pass that argument into the function. In that case,
the parameter will be automatically set to the default value.

Any default-valued parameters have to come in a contiguous set on the
end of the definition:

    source sorta.bash

    my_function2 () {
      local _params=( first=1 )
      eval "$(passed _params "$@")"

      echo "first: $first"
    }

Outputs:

    $ my_function2 one
    first: one

    $ my_function2
    first: 1

Note that supplying an empty string overrides the default:

    $ my_function2 ''
    first:

That means calling `my_function2 "$myvar"`, where `myvar` is empty or
unset, is different from calling `my_function2` without an argument.
Caller beware.

Pass Arrays
-----------

Arrays can be passed by name or with an array literal (see below). The
array is passed by value, which means the receiving function gets its
own copy of the array, not a reference to the original.

To receive an array, the entry in the parameter list is simply prefixed
with an "@" which symbolizes the expected type:

    source sorta.bash

    my_function3 () {
      local _params=( @first )
      eval "$(passed _params "$@")"

      declare -p first
    }

`declare -p` shows you bash's conception of the variable, namely that
"first" is an array, shown by the "declare -a" response:

    $ array=( 1 2 )
    $ my_function3 array
    declare -a first='([0]="1" [1]="2")'

To pass a literal, use the same syntax as the right-hand side of an
assignment statement (everything after the equals sign):

    $ my_function3 '( 1 2 )'
    declare -a first='([0]="1" [1]="2")'

You can use any syntax that an assignment accepts, indexed or
non-indexed.

Pass Hashes
-----------

Hashes, or associative arrays, are much the same as arrays, just
specified with a "%" (thanks, Perl) rather than an "@":

    source sorta.bash

    my_function4 () {
      local _params=( %first )
      eval "$(passed _params "$@")"

      declare -p first
    }

    $ declare -A hash=( [one]=1 [two]=2 ) # hashes require a "declare -A"
    $ my_function4 hash
    declare -A first='([one]="1" [two]="2" )'

Literals work much the same but require keys (unlike arrays):

    $ my_function4 '( [one]=1 [two]=2 )'
    declare -A first='([one]="1" [two]="2" )'

Be careful to quote the values of your key-value pairs if they contain
spaces.

Return Arrays and Hashes
------------------------

Returning scalars from functions doesn't require any special syntax
since you can already do this in bash:

    do_something_with "$(echo "a string returned by echo")"

Returning arrays and hashes isn't natively supported by bash however.
With sorta, you can write your functions to return a special form:

    source sorta.bash

    my_function5 () {
      local array=( 1 2 )
      pass array
    }

The "special form" is just a declaration string actually. But with a
little bit of help from another function, you can get it back into your
namespace thusly:

    $ eval "$(assign myarray "$(my_function5)")"
    $ declare -p myarray
    declare -a myarray='([0]="1" [2]="2")'

That's a bit much to digest so I'll break it down:

`my_function5` returns a declaration string for the array it defined:

    declare -a array='([0]="1" [1]="2")'

`assign` changes the name to "myarray":

    declare -a myarray='([0]="1" [1]="2")'

And finally, `eval` executes the declaration, putting the resulting
array in your scope as `myarray`.

Notice `my_function5` was called with the normal shell substitution
parentheses around it to get the string it was returning.

Hashes are passed the same way. There's no difference in syntax for
dealing with arrays versus hashes.

Import Hash Key-Values into Local Variables
-------------------------------------------

Finally, we address importing hash values into the local namespace.

Now that hashes can be passed around, it can be handy to pass a hash to
a function and then import key-value pairs from that hash into the local
namespace on the receiving side. `froms` imports a single key name:

    source sorta.bash

    my_function6 () {
      local _params=( %myhash )
      eval "$(passed _params "$@")"

      eval "$(froms myhash one)"
      echo "one: $one"
    }

Outputs:

    $ declare -A hash=( [one]=1 )
    $ my_function6 hash
    one: 1

`froms` can also import *all* keys from the named hash by passing `*`
for the name:

    eval "$(froms myhash '*')"

Since that operation can result in namespace collisions, you can make it
safer by applying a prefix to all of the imported names like so:

    eval "$(froms myhash 'prefix_*')"

For example, a key named `myhash[key]` imported this way gives the
variable `prefix_key`.

Alternatively, `froma` takes an array of key names (a literal or named
array variable):

    source sorta.bash

    my_function7 () {
      local _params=( %myhash )
      eval "$(passed _params "$@")"

      local keys=( one two three )
      eval "$(froma myhash keys)"
      echo "one: $one"
      echo "two: $two"
      echo "three: $three"
    }

Outputs:

    $ declare -A hash=( [one]=1 [two]=2 [three]=3 )
    $ my_function7 hash
    one: 1
    two: 2
    three: 3

`fromh` does the same as `froma` but uses a hash mapping to specify the
names of the variables to import the keys to:

    source sorta.bash

    my_function8 () {
      local _params=( %myhash )
      eval "$(passed _params "$@")"

      local -A keymap=( [one]=singing [two]=inthe [three]=rain )
      eval "$(fromh myhash keymap)"
      echo "singing: $singing"
      echo "inthe: $inthe"
      echo "rain: $rain"
    }

Outputs:

    $ declare -A hash=( [one]=1 [two]=2 [three]=3 )
    $ my_function8 hash
    singing: 1
    inthe: 2
    rain: 3

FAQ
---

-   *Why?*

    The command line is the fundamental tool for system management, and
    bash is its de facto interface. For many such uses, it's the lowest
    impedance tool for the job, beating out other scripting tools by
    virtue of staying out of your way. Bash has the added virtue of
    being preinstalled on almost every major Unix distribution.

    When trying to do anything somewhat sophisticated however, bash
    quickly falls on its face due to its weak support for passing
    parameters, its use of [dynamic scoping] and its lack of support for
    reasonable packaging of libraries.

    Sorta is aimed at improving parameter passing just a bit, so you can
    more effectively use the tools which bash does provide.

-   *Why "\_params"?*

    In order for the `passed` function to determine whether an argument
    needs to be expanded, it has to check the outside scope for the
    existence of variable names. If it finds one, it reads in
    that value. Therefore you don't want to declare any local variables
    before calling `passed`, since those might mask an outside variable
    name that was passed as an argument.

    If the parameter list is declared as a variable (as opposed to a
    literal), then it may also mask an argument. Prefixing it with an
    underscore prevents most possibilities for a name collision.

-   *What if I want to pass a string that happens to be a variable name
    as well? Won't it be expanded when I don't want it to be?*

    Short answer, yes, the string will be expanded if `passed` detects
    that it is a reference to a variable name. If you don't want it
    expanded, there are two things you can do (other than not use
    `passed`):

    -   Make the parameter an array instead and pass the argument as an
        entry in the array. Array items are not expanded.

    -   Make the parameter a reference type, by qualifying it with a
        "\*" in the parameter list. If the variable name held by the
        argument is not itself a reference, no expansion will be done.
        Since this is less reliable, option (1) is recommended instead.

-   *Should I use sorta's `passed` function to pass user input to
    functions?*

    As scalars, no, you generally shouldn't use `passed` for any data
    which might inadvertently contain just a variable name, which would
    get expanded when you wouldn't want it to.

    However you *can* pass such data through arrays, which are not
    expanded, as described above.

-   *What about the positional arguments, $1, $2, etc.?*

    The positional arguments are left intact and may be used in addition
    to the arguments created by `passed`. You may even use them to tell
    when an expansion has occurred, which is occasionally useful.

Sorta API
---------

"Accepts literals or variable names" means that the arguments may be
specified normally, using string literals or expansions for example, or
with the bare name of a variable (as a normal string argument). If the
receiving function detects that the supplied argument is the name of a
defined variable, it will automatically expand the variable itself.

Array and hash (associative array) literals may also be passed as
strings for parameters expecting those types. Any literal that would
work for the right-hand-side of an assignment statement works in that
case, such as `'( [one]=1 [two]=2 )'` (remember to use single- or
double-quotes).

-   **`assign`** *`variable_name declaration_statement`* - change the
    variable name of a declaration statement to `variable_name`

    *Returns*: the substituted declaration statement on stdout

    Allows you to assign the output of `pass` to a variable name in the
    local scope. You must `eval` the output of `assign` to do so.

-   **`assigna`** *`variable_name_array declaration_statement`* - change
    the names in a compound declaration statement

    *Returns*: the substituted declarations on stdout

    Allows you to reassign the names of a compound series of declaration
    statements to the names in the array. A compound declaration is a
    series of individual declaration statements, usually separated with
    semicolons, joined into a single string. It is up to you to ensure
    that the number of names and available statements match. You must
    `eval` the output of `assigna` to instantiate the variables locally.

-   **`froma`** *`hash keys`* - create declaration statements for a set
    of variables named in the array `keys`, values taken from the named
    hash

    Accepts literals or variable names.

    *Returns*: a compound declaration statement on stdout

    For the named hash, returns a set of declaration statements, joined
    by semicolons, for variables named in `keys`. The values are taken
    from the corresponding keys of `hash`.

    You must `eval` the output of `froma` to instantiate the
    variables locally.

-   **`fromh`** *`hash keyhash`* - create declaration statements for a
    set of variables named in the keys of `keyhash`, values taken from
    `hash`

    Accepts literals or variable names.

    *Returns*: a compound declaration statement on stdout

    For the named hash, returns a set of declaration statements, joined
    by semicolons, for the keys of `hash` corresponding to the keys of
    `keyhash`, mapped to variables named by the values of `keyhash`.

    You must `eval` the output of `froma` to instantiate the
    variables locally.

-   **`froms`** *`hash name_or_pattern`* - create
    declaration statement(s) for named variable or set of variables,
    values taken from from `hash`

    Accepts literals or variable names.

    *Returns*: a declaration statement or compound declaration statement
    on stdout

    When supplied with a single name, creates a declaration statement
    for the named variable with the value taken from the corresponding
    key in `hash`.

    When supplied with the pattern '\*' (include quotes to prevent
    globbing), creates a compound declaration statement for variables
    with *all* of the keys and values of `hash`.

    When supplied with a prefixed asterisk, such as 'myvars\_\*',
    creates a compound declaration as above but with the prefix on the
    resulting variable names.

    You must `eval` the output of `froms` to instantiate the
    variable(s) locally.

-   **`intoa`** *`hash keys [return_variable]`* - return a hash which
    includes the variables named in `keys` as new keys

    Accepts literals or variable names.

    *Returns*: a declaration statement on stdout, or a hash in
    `return_variable`, if supplied

    Adds the variables named in `keys`, and their values, to the
    named hash.

    Existing keys of the same name are overwritten. Other key-values in
    the hash are left alone. This is basically a merge operation.

    `return_variable`, if supplied, must be a hash variable declared
    outside the scope of `intoa`, and may be the same as the named hash.

    Otherwise you must `eval` the output of `intoa` to update the hash
    with the new values.

-   **`intoh`** *`hash keyhash [return_variable]`* - return a hash which
    includes the variables named in `keyhash` as new keys

    Accepts literals or variable names.

    *Returns*: a declaration statement on stdout, or a hash in
    `return_variable`, if supplied

    Adds the variables named in `keyhash`, and their values, to the
    named hash. `keyhash` is a mapping of the variables names to the
    keynames under which their values will be inserted into `hash`.

    Existing keys of the same name are overwritten. Other key-values in
    the hash are left alone. This is basically a merge operation.

    `return_variable`, if supplied, must be a hash variable declared
    outside the scope of `intoh`.

    Otherwise you must `eval` the output of `intoh` to update the hash
    with the new values.

-   **`intos`** *`hash key [return_variable]`* - return a hash which
    includes the variable named in `key`

    Accepts literals or variable names.

    *Returns*: a declaration statement on stdout, or a hash in
    `return_variable`, if supplied

    Adds the variable named by `key`, and its value, to the named hash.

    An existing key of the same name is overwritten. Other key-values in
    the hash are left alone. This is basically a merge operation.

    `return_variable`, if supplied, must be a hash variable declared
    outside the scope of `intos`, and may be the same as the named hash.

    Otherwisee you must `eval` the output of `intos` to update the hash
    with the new values.

-   **`keys_of`** *`hash [return_variable]`* - return an array of the
    key names from `hash`

    Accepts a literal or variable name.

    *Returns*: a declaration statement on stdout or the value in
    `return_variable`, if supplied

    `return_variable`, if supplied, must be an array variable declared
    outside the scope of `values_of`.

    Finds and returns an `eval`able array of the key names from the
    named `hash`.

-   **`pass`** *`variable_name`* - create a declaration statement for an
    the named variable

    *Returns*: a declaration statement on stdout

    Returns an `eval`able statement to instantiate the given variable in
    a scope, usually as a return value from a function.

    Equivalent to `declare -p <variable_name> 2>/dev/null`.

-   **`passed`** *`parameter_array arg1 [arg2...]`* - create a compound
    declaration statement for the named variable parameters with the
    supplied argument values

    Accepts literals or variable names.

    *Returns*: a declaration statement on stdout

    Reserves for internal use any variable names starting with double
    underscores, so such names are not allowed in parameter lists.
    `passed` does not support such parameter names.

    Returns an `eval`able statement to instantiate the given variables
    in a scope, usually as the first task in your function.

    Named parameters are presumed to be scalars unless prefixed with the
    following qualifiers:

    -   `@` - argument is an array name or literal

    -   `%` - argument is a hash name or literal

    -   `&` - parameter is aliased to the variable name given by
        argument with `declare -n`

    -   `*` - argument is a reference to another variable name

    Note that `&` and `*` require the quoting since bash treats them as
    special characters.

    Scalar arguments are tested to see if they refer to variables. If
    so, they are dereferenced so the resulting declaration holds the
    value of the referenced variable.

    Array and hash parameters are presumed to hold references to an
    array or hash in the outer scope, or to hold an array/hash literal.
    A literal, in this case, is any string which qualifies as the
    right-hand side of an assignment statement, i.e. that which follows
    the equals sign. See the format of any `declare -p` output
    for examples.

    The `*` reference type tells `passed` to expect the result to be a
    variable name. It still dereferences an argument if the dereferenced
    argument's value is the name of another variable, but will prevent
    dereferencing if the argument is simply a variable reference and
    nothing more.

    The `&` dereference type sets the parameter to point to the variable
    named by the argument directly, effectively making it call
    by reference. Changes to the parameter variable in the function body
    will affect the original variable directly in the outer scope. This
    is not call by value.

    All parameters in the list may have a default value specified by
    appending `=<value>` to the parameter name. Parameters with default
    values must, however, be contiguous at the end of the list.

    You must `eval` the output of `passed` to instantiate the variables.

-   **`ret`** *`return_variable string_value|array_name|hash_name`* -
    return a value via a named return variable

    *Returns*: the value, in `return_variable`

    `return_variable` must exist outside of your function scope, usually
    declared by your function's caller. The existing variable must also
    be the appropriate type; scalar, array or hash (a.k.a.
    associative array).

    `return_variable` is therefore usually passed into your function as
    an argument, which is then passed onto `ret`.

    Example:

          myfunc () {
            return_variable=$1

            local "$return_variable" || return
            ret "$return_variable" 'my value' # pass back a string
          }

    Before calling `ret`, your function must also declare
    `return_variable` locally, as shown. Since the variable name may not
    be a valid identifier string, this is usually done with a `return`
    clause in case it errors. This should only be done right before
    calling `ret`.

    You could accomplish the same thing without `ret` by using
    indirection via `local -n ref` or `${!ref}`, but both of these allow
    the referenced variable name to conflict with your local variables.
    `ret` prevents naming conflicts with your local variables.

    Calling `ret`, however, does unset the named variable in your
    function's scope. If the variable name is also used by one of your
    local variables (always possible), then your variable will be unset.
    Therefore you may not be able to rely on variables after calling
    `ret`, so you should only do so right before your function returns.

    The returned value(s) may be a scalar value, or may be contained in
    a named array or hash. If passing an array or hash, simply use the
    variable name as the second argument. If passing back a scalar
    value, use the value, not its variable name (if stored in
    a variable).

    As a corollary, the `ret` function is unable to pass back the names
    of arrays or hashes as scalar values. They will always be passed as
    their array values. Be forewarned.

    `ret` is based on the discussion \[here\], but is enhanced to pass
    arrays by name.

    It is also a wrapper for the `_ret` function from \[nano\], which is
    the actual implementation.

-   **`values_of`** *`hash [return_variable]`* - return an array of the
    values (corresponding to keys) from `hash`

    Accepts a literal or variable name.

    *Returns*: a declaration statement on stdout, or the value in
    `return_variable`, if supplied

    `return_variable`, if supplied, must be an array variable declared
    outside the scope of `values_of`.

    Finds and returns an `eval`able array of the values from the named
    `hash`.

import.bash
===========

`import.bash` is another library included with sorta. It allows you to
write libraries that may have their functions imported a la carte.

For example, if you have a library named `my_great_library.bash` which
has been written with `import` in mind, you can get functions from it
like so:

    source import.bash

    mgl_imports=(
      my_great_function1
      my_great_function2
    )
    eval "$(importa my_great_library mgl_imports)"

If `my_great_library.bash` has 100 functions defined, you will only get
the two you wanted, plus dependencies.

Any functions which are dependencies of `my_great_library` will be
imported as well, but that is handled automatically at import time by
some meta-information you add to your library.

There are two primary benefits provided by `import.bash`:

-   it gives you control over the function namespace when sourcing
    libraries, making it easier to effectively structure your code into
    libraries or use others' code

-   it provides you a trail back to the source file of functions used in
    your code. By tying the function name to the source file when the
    function is imported, you are able to explicitly see where the
    function came from. This makes it easier to use multiple libraries
    in your code since you can tell from where functions originated when
    you need to examine their implementations.

`import.bash` works by opening a subshell, importing the named library,
and then extracting and `eval`ing the code for the functions you care
about. Performance may be an issue with large files, since you are
parsing potentially a large amount of code twice rather than once.

Import Usage
------------

The basic usage pattern for the consumer of an import-compatible library
is above. The `imports` function imports an individual function (the "s"
is for string), while the `importa` function imports an array of
function names.

The library name may be qualified with its file extension (e.g. `.sh`),
but if it is not qualified, it will be searched for without an
extension, then with ".bash" and ".sh" extensions.

Writing libraries which can be imported is the other half of the
picture. The only requirement is that any dependencies of the library's
functions are listed in a special variable, `_required_imports`,
declared by the library.

For example, if you have a function `one` which calls function `two`,
your library would look like so:

    _required_imports=(
      two
    )

    one () {
      echo "Calling 'two'..."
      two
    }

    two () {
      echo "Hello from 'two'."
    }

Note that you do not need to source `import.bash`.

The reason is that the `import` functions do not do any dependency
analysis of their own. Although `one` calls `two` and depends on it to
succeed, importing `one` won't automatically import `two` if you don't
import `two` explicitly as well. Because of that, calling `one` will
fail when it tries to use `two`, unless you include it in your
`_required_imports`.

The same goes for dependencies satisfied by libraries sourced by your
library. To make it possible for any function in your library to be
imported, you will have to determine all of the functions called by any
of your library's, wherever they have been defined, and list their names
in `_required_imports` in your library. For example, if `two` had been
defined in a separated file, it still would have needed to be listed in
`_required_imports` in the file where `one` is defined.

Anything in `_required_imports` will automatically be imported so the
consumer of your library won't have to handle that dependency analysis.

This means that if you have a lot of dependencies, you will be getting
some extra baggage with your imports, so be aware that just because you
named one function to import, it doesn't mean you won't get others as
well in the bargain. Still, you're usually keeping your namespace
cleaner than it would have been if you had imported the entirety of a
library that only had a handful of functions in which you were actually
interested.

  [dynamic scoping]: https://en.wikipedia.org/wiki/Scope_(computer_science)#Lexical_scoping_vs._dynamic_scoping
