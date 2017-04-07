set -x

library=./shpec-helper.bash
source "${BASH_SOURCE%/*}/$library" 2>/dev/null || source "$library"
unset -v library

initialize_shpec_helper
shpec_source lib/import.bash

eval "$(imports kzn defs)"

describe 'importa'
  it "prints a function by array of names from a sourcefile"; (
    defs expected <<'EOS'
      absolute_path () 
      { 
          eval "$(passed '( path )' "$@")";
          local filename;
          unset -v CDPATH;
          is_file path && { 
              filename=$(basename path);
              path=$(dirname path)
          };
          is_directory path || return;
          path=$(cd "$path"; pwd) || return;
          puts "$path${filename:+/}${filename:-}"
      }
      dirname () 
      { 
          eval "$(passed '( path )' "$@")";
          if [[ $path == */* ]]; then
              puts "${path%/?*}";
          else
              puts .;
          fi
      }
      is_file () 
      { 
          eval "$(passed '( path )' "$@")";
          [[ -f $path ]]
      }
      is_directory () 
      { 
          eval "$(passed '( path )' "$@")";
          [[ -d $path ]]
      }
      puts () 
      { 
          eval "$(passed '( message )' "$@")";
          printf '%s\n' "$message"
      }
      putserr () 
      { 
          eval "$(passed '( message )' "$@")";
          puts message 1>&2
      }
      shpec_cleanup () 
      { 
          eval "$(passed '( path )' "$@")";
          validate_dirname path || return;
          $rm "$path"
      }
      validate_dirname () 
      { 
          eval "$(passed '( path )' "$@")";
          path=$(absolute_path "$path") || return 1;
          [[ -d $path && $path == /*/* ]]
      }
      imports () 
      { 
          ( eval "$(passed '( sourcefile function )' "$@")";
          importa sourcefile '( '"$function"' )' )
      }
EOS
    assert equal "$expected" "$(importa import '( imports )')"
    return "$_shpec_failures" )
  end
end

describe 'imports'
  it "prints a function by name from a sourcefile, including required imports"; (
    defs expected <<'EOS'
      absolute_path () 
      { 
          eval "$(passed '( path )' "$@")";
          local filename;
          unset -v CDPATH;
          is_file path && { 
              filename=$(basename path);
              path=$(dirname path)
          };
          is_directory path || return;
          path=$(cd "$path"; pwd) || return;
          puts "$path${filename:+/}${filename:-}"
      }
      dirname () 
      { 
          eval "$(passed '( path )' "$@")";
          if [[ $path == */* ]]; then
              puts "${path%/?*}";
          else
              puts .;
          fi
      }
      is_file () 
      { 
          eval "$(passed '( path )' "$@")";
          [[ -f $path ]]
      }
      is_directory () 
      { 
          eval "$(passed '( path )' "$@")";
          [[ -d $path ]]
      }
      puts () 
      { 
          eval "$(passed '( message )' "$@")";
          printf '%s\n' "$message"
      }
      putserr () 
      { 
          eval "$(passed '( message )' "$@")";
          puts message 1>&2
      }
      shpec_cleanup () 
      { 
          eval "$(passed '( path )' "$@")";
          validate_dirname path || return;
          $rm "$path"
      }
      validate_dirname () 
      { 
          eval "$(passed '( path )' "$@")";
          path=$(absolute_path "$path") || return 1;
          [[ -d $path && $path == /*/* ]]
      }
      imports () 
      { 
          ( eval "$(passed '( sourcefile function )' "$@")";
          importa sourcefile '( '"$function"' )' )
      }
EOS
    assert equal "$expected" "$(imports import imports)"
    return "$_shpec_failures" )
  end
end

describe '_print_function'
  it "prints a function's definition"; (
    samplef() { :;}
    defs expected <<'EOS'
      samplef () 
      { 
          :
      }
EOS
    assert equal "$expected" "$(_print_function samplef)"
    return "$_shpec_failures" )
  end
end
