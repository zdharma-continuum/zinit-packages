#!/usr/bin/env bash

# Regenerate this list with
# ./gen-pkg.sh --update-ices
ZINIT_ICES=(
  "aliases"
  "as"
  "atclone"
  "atdelete"
  "atinit"
  "atload"
  "atpull"
  "autoload"
  "!bash"
  "bash"
  "binary"
  "bindmap"
  "blockf"
  "bpick"
  "cargo"
  "cloneonly"
  "cloneopts"
  "compile"
  "countdown"
  "cp"
  "!csh"
  "csh"
  "debug"
  "depth"
  "dl"
  "dlink"
  "eval"
  "extract"
  "fbin"
  "ferc"
  "fmod"
  "from"
  "fsrc"
  "gem"
  "git"
  "has"
  "id-as"
  "if"
  "install"
  "is-snippet"
  "!ksh"
  "ksh"
  "light-mode"
  "load"
  "lucid"
  "make"
  "multisrc"
  "mv"
  "nocd"
  "nocompile"
  "nocompletions"
  "node"
  "notify"
  "null"
  "on-update-of"
  "opts"
  "pack"
  "param"
  "patch"
  "pick"
  "pip"
  "proto"
  "ps-on-unload"
  "ps-on-update"
  "pullopts"
  "reset"
  "reset-prompt"
  "run-atpull"
  "rustup"
  "sbin"
  "service"
  "!sh"
  "sh"
  "silent"
  "src"
  "subscribe"
  "subst"
  "svn"
  "trackbinds"
  "trigger-load"
  "unload"
  "ver"
  "verbose"
  "wait"
  "wrap"
)

PACKAGE_VARS=(
  AUTHOR
  DESCRIPTION
  LICENSE
  MESSAGE
  REQUIREMENTS
  URL
  VERSION
)

# Note: this function needs to be defined below ZINIT_ICES (not above)
# Otherwise perl will update the regex below instead of the actual
# ZINIT_ICES array
update_zinit_ice_list() {
  local file
  file="${1:-$(basename "$0")}"

  if [[ "$file" == "bash" ]]
  then
    echo_err "Cannot determine path to self."
    echo_err "Please provide filepath: $0 --update-ices FILEPATH"
    return 1
  fi

  # Note: We purposefully grep -v'd the pack ice here
  # The first sed add quotes around the ices and replaces " " with "\n"
  # The second one indents the values by 2 spaces
  local ices
  ices="$(zsh -ic "zinit --help" | tail -1 | \
    sed -r -e 's/([^ ]+)/"\1"/g' -e $'s/ /\\\n/g' | \
    sed -e 's/^/  /g' | \
    grep -vE '^"pack"$' | \
    sort -u)"

  if [[ -z "$ices" ]]
  then
    echo_err "Failed to build ice list. Is zinit installed correctly?"
    return 1
  fi

  echo_info "Updating ice list with:\n$ices"
  echo_info "File to update (self): $file"

  perl -i -p0e \
    's/(ZINIT_ICES)=([^)]*)/\1=(\n'"${ices}"'\n/s' \
    "$file"
}

echo_debug() {
  [[ -z "$DEBUG" ]] && return
  echo -e "\e[35m🐝 ${*}\e[0m" >&2
}

echo_info() {
  echo -e "\e[34m🫐 ${*}\e[0m" >&2
}

echo_sucess() {
  echo -e "\e[32m✅ ${*}\e[0m" >&2
}

echo_warn() {
  echo -e "\e[33m🚸 ${*}\e[0m" >&2
}

echo_err() {
  echo -e "\e[31m❌ ${*}\e[0m" >&2
}

zinit_parse_ice() {
  local ice="$1" arg="$2" tmp

  # Remove the atclone=? prefix
  tmp="${arg##${ice}?(=)}"
  # Remove quotes
  tmp="${tmp#\"}"
  tmp="${tmp%\"}"
  tmp="${tmp#\'}"
  tmp="${tmp%\'}"

  # Replace newlines with spaces (the first sed expr)
  # Then: replace tabs chars with spaces, remove duplicate spaces, and trim
  sed -rz \
    -e 's/\n/ /g' \
    -e 's/\t/ /g' \
    -e 's/ +/ /g' \
    -e 's/  *$//' \
    <<< "$tmp"
}

# Fake zinit function that outputs the ices as JSON
zinit() {
  echo_debug "zinit invoked with: ${*@Q}"

  local -A ices
  local arg ice matched
  local for repo plugin_org plugin_name

  shopt -s extglob

  for arg in "$@"
  do
    case "$arg" in
      for)
        # for is special, the next argument will be the repo
        for=1
        ;;
      *)
        if [[ -n "$for" ]]
        then
          # remove leading '@', as in 'zinit xxx for @direnv/direnv'
          repo="${arg#@}"
          plugin_org="${repo%%/*}"
          plugin_name="${repo##*/}"
          # Ignore remaining args
          break
        else
          matched=""
          for ice in "${ZINIT_ICES[@]}"
          do
            if [[ "$arg" =~ ^${ice} ]]
            then
              matched="$arg"
              break
            fi
          done

          if [[ -z "$matched" ]]
          then
            echo_err "Unknown ice: $arg"
            return 1
          fi

          ices["$ice"]="$(zinit_parse_ice "$ice" "$arg")"
        fi
        ;;
    esac
  done

  # Display PACKAGE_VARS
  local var
  for var in "${PACKAGE_VARS[@]}"
  do
    echo_debug "${var}=${!var}"
  done
  echo_debug "repo: $repo (org: $plugin_org - name: $plugin_name)"
  # shellcheck disable=2030
  echo_debug "ices: $(typeset -p ices)"

  if [[ -z "$repo" ]]
  then
    echo_err "Missing repo name"
    return 1
  fi

  # JSON output
  local key

  # shellcheck disable=2031
  for key in "${!ices[@]}"
  do
    echo "$key"
    echo "${ices[$key]}"
  done | jq -e -n -R \
    --arg author "$AUTHOR" \
    --arg description "$DESCRIPTION" \
    --arg license "$LICENSE" \
    --arg message "$MESSAGE" \
    --arg plugin_name "$plugin_name" \
    --arg plugin_org "$plugin_org" \
    --arg repo "$repo" \
    --arg requirements "$REQUIREMENTS" \
    --arg url "$URL" \
    --arg version "$VERSION" \
    '{
      "author": $author,
      "description": $description,
      "ices": (reduce inputs as $i ({}; . + {
        ($i): (input | (tonumber? // .))
      })),
      "license": $license,
      "message": $message,
      "plugin_name": $plugin_name,
      "plugin_org": $plugin_org,
      "repo": $repo,
      "url": $url,
      "version": $version,
    }'
}

get_zinit_json_data() {
  local pkg="$1" profile="$2"
  local srcfile="${pkg}/${profile}.ices.zsh"

  if ! [[ -e "$srcfile" ]]
  then
    echo_err "source file does not exist: $srcfile"
    return 1
  fi

  # call our fake zinit func
  # shellcheck disable=1090
  source "$srcfile"
}

list_packages() {
  local dir="$1"

  while IFS= read -r -d '' pkg
  do
    basename "$pkg"
  done < <(find "$dir" -maxdepth 1 -mindepth 1 -type d \
             -and -not -path "${dir}/.git" -print0)
}

list_profiles() {
  local package="$1"

  find "$package" -iname '*.ices.zsh' -print0 | \
    xargs -0 -L1 basename | \
    sed -nr 's#(.+).ices.zsh#\1#p'
}

update_ices() {
  cd "$(cd "$(dirname "$0")" >/dev/null 2>&1; pwd -P)" || exit 9

  local pkg="$1"
  local profile="$2"
  local zinit_json="$3"
  local srcfile="${pkg}/${profile}.ices.zsh"
  local pkgfile="${pkg}/package.json"

  echo_debug "Updating $pkgfile with:\n$(jq -c <<< "$zinit_json")"

  # If the target package does not already have a package.json file,
  # we need to use the template to get the min boilerplate
  local input_file="$pkgfile"
  if ! [[ -e "$pkgfile" ]]
  then
    input_file="$PWD/package.template.json"
  fi

  local tmpfile
  tmpfile="$(mktemp)"
  trap 'rm -f $tmpfile' EXIT INT

  # shellcheck disable=2153
  jq -e --arg profile "$profile" \
    --argjson data "$zinit_json" \
    '.author = $data.author |
     .description = $data.description |
     .homepage = $data.url |
     .license = $data.license |
     .name = $data.repo |
     .version = $data.version |
     .["zsh-data"]["plugin-info"].message = $data.message |
     .["zsh-data"]["plugin-info"].plugin = $data.plugin_name |
     .["zsh-data"]["plugin-info"].user = $data.plugin_org |
     .["zsh-data"]["plugin-info"].version = $data.version |
     .["zsh-data"]["zinit-ices"][$profile] = $data.ices' \
    "$input_file" > "$tmpfile" || return 1

  local data
  data="$(jq -e . "$tmpfile")"
  local rc="$?"

  if [[ -n "$CHECK" ]]
  then
    local diff_msg
    if diff_msg="$(diff \
      <(jq --sort-keys . <<< "$data") \
      <(jq --sort-keys . $pkgfile))"
    then
      echo_sucess "$pkgfile [$profile]: No change."
      return
    else
      echo_warn "$pkgfile [$profile]: Files differ!"
      echo "$diff_msg" >&2
      return 1
    fi
  fi

  if [[ -n "$DRY_RUN" ]]
  then
    cat <<< "$data"
    return "$rc"
  fi

  if [[ "$rc" -eq 0 ]]
  then
    mv "$tmpfile" "$pkgfile"
    return "$?"
  fi

  return "$rc"
}

generate_package_json_profile() {
  local package="$1"
  local profile="$2"
  local zinit_json_data

  echo_debug "Processing package $package - profile: $profile"
  if ! zinit_json_data="$(get_zinit_json_data "$package" "$profile")"
  then
    return "$?"
  fi

  if update_ices "$package" "$profile" "$zinit_json_data"
  then
    echo_sucess "Generated ${profile}/package.json"
  fi
}

generate_package_json() {
  local package="$1"; shift
  local -a profiles=("$@")
  local filename
  local filepath
  local ice_file
  local profile

  echo_debug "Processing package $package"

  # Check if we were provided with a file path
  # eg: gen-pkg.sh null/default.ices.zsh
  if [[ -f "$package" ]]
  then
    filepath="$(realpath "$package")"
    filename="$(basename "$filepath")"
    package="$(basename "$(dirname "$filepath")")"
    profile="${filename//.ices.zsh}"
  fi

  # No profile provide, assume all
  if [[ -z "${profiles[*]}" ]]
  then
    while IFS= read -r -d '' ice_file
    do
      profiles+=("$(basename "${ice_file//.ices.zsh}")")
    done < <(find "$package" -type f -iname '*.ices.zsh' -print0)
  fi

  if [[ "${#profiles[@]}" -eq 0 ]]
  then
    echo_warn "Package $package doesn't contain any *.ices.zsh file"
    return 1
  fi

  for profile in "${profiles[@]}"
  do
    generate_package_json_profile "$package" "$profile"
    # Unset vars which may be set from the .ices.zsh files
    eval unset "${PACKAGE_VARS[*]}"
  done
}

generate_ices_zsh_files() {
  local package="$1"; shift
  local -a profiles=("$@")

  echo_info "Generating ices.zsh for package $package"
  local srcfile pkgfile="$package/package.json"
  local content ice ice_data ice_val metadata plugin
  local author description license message plugin_url requirements url version
  local -a ices

  # Constants
  local default_plugin="zdharma-continuum/null"
  local modeline='# vim: set ft=zsh et ts=2 sw=2 :'

  if ! [[ -f "$pkgfile" ]]
  then
    echo_err "Missing package.json in ${package}/"
    return 1
  fi

  if ! jq -e . "$pkgfile" >/dev/null
  then
    echo_err "$pkgfile: Invalid JSON"
    return 1
  fi

  if [[ -z "${profiles[*]}" ]]
  then
    readarray -t profiles < <(\
      jq -e -r -c '.["zsh-data"]["zinit-ices"] | keys[]' "$pkgfile")
  fi

  echo_info "Selected profiles: ${profiles[*]:-default}"

  local profile
  for profile in "${profiles[@]}"
  do
    echo_debug "Processing profile $profile"
    srcfile="${package}/${profile}.ices.zsh"

    metadata="$(jq -e -r '.["zsh-data"]["plugin-info"]' "$pkgfile")"
    ice_data="$(jq -e -r --arg profile "$profile" \
                '.["zsh-data"]["zinit-ices"][$profile]' "$pkgfile")"

    # Metadata
    # TODO Add more/better fallback logic here? For snippets for example
    # we need to use the snippet url, or the $package name
    plugin="$(jq -er --arg default "$default_plugin" '
      (.user + "/" + .plugin) as $n |
      if ($n != "/") then
        $n
      else
        $default
      end' <<< "$metadata")"
    # items in root
    author="$(jq -er '.author // ""' "$pkgfile")"
    description="$(jq -er '.description // ""' "$pkgfile")"
    license="$(jq -er '.license // ""' "$pkgfile")"
    url="$(jq -er '.homepage // ""' "$pkgfile")"
    version="$(jq -er '.version // ""' "$pkgfile")"
    # items in plugin-info
    message="$(jq -er '.message // ""' <<< "$metadata")"
    plugin_url="$(jq -er '.url // ""' <<< "$metadata")"
    # FIXME The requirements field really shouldn't be in the ices array...
    requirements="$(jq -er '.requires // ""' <<< "$ice_data")"

    local now
    if [[ -n "$REPRODUCIBLE" ]]
    then
      # Re-use previous timestamp, fall back to UNIX ts 0
      now="$(awk '/^# [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\+[0-9]{2}:[0-9]{2}/ { print $2; exit }' "$srcfile" 2>/dev/null)"
      if [[ -z "$now" ]]
      then
        now="$(date -d @0 -Iseconds --utc)"
      fi
    else
      now="$(date -Iseconds)"
    fi

    # Sanitize metadata
    local var val
    for var in author description license message requirements url version
    do
      # FIXME the lines below feel wrong
      val="${!var}"
      [[ -z "$val" ]] && continue
      val="$(sed -z "s/'/\\\'/g; s/\n/\\\\\\\\\\\\\\\\n/g" <<< "$val")"
      val="${val%$'\\\\\\\\\\\\\\\\n'}"
      val="$(sed -z "s/\\\'/\\\\\'\\\\\\\\\\\\'\\\\\'/g" <<< "$val")"
      eval "${var}=\$'${val}'"
    done

    content="# zinit package for ${package} [${profile}]\n"
    content+="# Generated by $(basename "$0")\n"
    content+="# ${now}\n"
    content+="AUTHOR='${author}'\n"
    content+="DESCRIPTION='${description}'\n"
    content+="LICENSE='${license}'\n"
    content+="MESSAGE='${message}'\n"
    content+="REQUIREMENTS='${requirements}'\n"
    content+="URL='${url}'\n"
    content+="VERSION='${version}'\n"

    # Add zinit call to output (static)
    content+='\nzinit \\\n'

    # Process ices
    readarray -t ices < <(\
      jq -e -r -c 'keys[] | select(
        (contains("requires") | not) and
        (contains("plugin") | not))' <<< "$ice_data")

    # Prepend id-as, if not already in the ices array
    if ! [[ " ${ices[*]} " =~ " id-as " ]]
    then
      ices=(id-as "${ices[@]}")
    fi

    for ice in "${ices[@]}"  # note: $ices holds the ice names only
    do
      # 1st sed: escape '\n' to '\\n' to avoid it getting mangled by echo -e
      # (escapes '\\n' to '\\\n' too)
      # 2nd sed -> We need to properly encode single quotes since we are
      # using these to quote the ice values below
      ice_val="$(jq -e -r --arg ice "$ice" '.[$ice] // ""' <<< "$ice_data" | \
                 sed -r 's#(\\+n)#\\\\\\\1#g' | \
                 sed "s/'/'\\\''/g")"

      case "$ice" in
        is-snippet)
          is_snippet=1
          ;;
        id-as)
          # if the plugin does not have a propper id then use the package name
          # TODO It make sense to *first* try to use $plugin, and then fall
          # back to $package
          if [[ "$plugin" != "$default_plugin" ]]
          then
            ice_val="${ice_val:-${plugin}}"
          else
            ice_val="${ice_val:-zinit-package-${package}}"
          fi
          ;;
      esac

      echo_debug "$ice value: ${ice_val:-\"\"}"

      content+="    $ice"

      # 1st expr: Add newlines after && and ; (should only occur within
      # atclone/atpull)
      # 2nd expr: Remove trailing whitespace
      ice_val="$(sed -r \
        -e 's#(&&|;) #\1\n      #g' \
        <<< "$ice_val")"

      # Append the quoted value of the ice
      if [[ -n "$ice_val" ]]
      then
        content+="'${ice_val}'"
      fi

      content+=' \\\n'
    done

    if [[ -n "$is_snippet" ]] && [[ -n "$plugin_url" ]]
    then
      content+="  for \"${plugin_url}\""
    else
      content+="  for @${plugin}"
    fi

    content+="\n\n$modeline"
    echo_debug "Generated content for ${srcfile}:\n${content}"

    if [[ -n "$CHECK" ]]
    then
      if echo -e "$content" | diff "$srcfile" -
      then
        echo_sucess "$srcfile: No change."
        return
      else
        echo_warn "$srcfile: Files differ!"
        return 1
      fi
    fi

    if [[ -n "$DRY_RUN" ]]
    then
      echo -e "$content"
      echo
    else
      echo -e "$content" > "$srcfile" && {
        echo_sucess "Generated $srcfile"
      } || {
        echo_err "Failed to generate $srcfile"
        return 1
      }
    fi
  done
}

create_package() {
  local package="$1"; shift
  local profiles=("$@")

  local script_dir
  script_dir="$(cd "$(dirname "$0")" >/dev/null 2>&1 || return 1; pwd -P)"

  local dest="${script_dir}/${package}"
  local pkgfile="${dest}/package.json"

  echo_info "Creating new package: ${package} (${dest})"
  mkdir -pv "${dest}"
  if ! [[ -e ${pkgfile} ]]
  then
    cp -v "${script_dir}/package.template.json" "${pkgfile}"
  fi

  local pkgdata
  pkgdata="$(cat "$pkgfile")"

  # Create additional profiles
  local profile
  for profile in "${profiles[@]}"
  do
    echo_debug "Processing profile $profile"
    if [[ -e "${dest}/${profile}.ices.zsh" ]] && [[ -z "$FORCE" ]]
    then
      echo_err "Package profile $profile already exists for $package."
      return 1
    fi

    pkgdata="$(jq -e -r --arg profile "$profile" \
      '.["zsh-data"]["zinit-ices"][$profile].requires = ""' <<< "$pkgdata")"
  done

  echo "$pkgdata" > "$pkgfile"

  # Generate the .ices.zsh files
  generate_ices_zsh_files "$package"
}

fetch_zinit_docker_run() {
  if [[ -x docker-run.sh ]]
  then
    realpath docker-run.sh
    return
  fi

  local url="https://raw.githubusercontent.com/zdharma-continuum/zinit/main/scripts/docker-run.sh"

  cd "$(cd "$(dirname "$0")" >/dev/null 2>&1; pwd -P)" || exit 9
  rm -fv docker-run.sh

  echo_info "Fetching docker-run.sh from $url"
  if ! curl -fsSL "$url" > docker-run.sh
  then
    rm -f docker-run.sh
    echo_err "Failed to download docker-run.sh"
    return 1
  fi

  chmod +x docker-run.sh
  realpath docker-run.sh
}

run_package() {
  local package="$1"
  local profile="${2:-default}"
  shift 2

  if [[ "$profile" =~ -|-- ]]
  then
    profile="default"
  fi

  local -a cmd
  cmd=("$(fetch_zinit_docker_run)" --env QUIET=1)

  if [[ -n "$DEBUG" ]]
  then
    cmd=(bash -x "${cmd[0]}")
  fi

  local ices_file="${package}/${profile}.ices.zsh"

  if [[ -n "$REGENERATE" ]]
  then
    if [[ -n "$RUN_PACKAGE" ]]
    then
      if ! generate_package_json_profile "$package" "$profile"
      then
        echo_err "Failed to generate package.json"
        return 1
      fi
    else
      if ! generate_ices_zsh_files "$package" "$profile"
      then
        echo_err "Failed to generate ${profile}.ices.zsh"
        return 1
      fi
    fi
  fi

  if ! [[ -r "$ices_file" ]]
  then
    echo_err "Unable to read from ${ices_file}"
    return 2
  fi

  local args=()
  if [[ -n "$NON_INTERACTIVE" ]]
  then
    args=(zsh -ilsc '@zinit-scheduler burst')
    # args=(zsh -ilsc 'exit $?')
  fi

  if [[ -n "$RUN_PACKAGE" ]]
  then
    echo_info "🐳 Running zinit pack'${profile}' for ${package}"
    "${cmd[@]}" --config "zinit pack'${profile}' for ${package}" "${args[@]}"
  else
    echo_info "🐳 Running with file: $ices_file"
    "${cmd[@]}" --file "$ices_file" "${args[@]}"
  fi
}

usage() {
  echo "Usage: $(basename "$0") ACTION [ARGS] [PACKAGE] [PROFILES...]"
  echo "ACTIONS: create|gen-json|gen-ices|run|update-ices"
  echo
  echo "Global flags:"
  echo "  --check   Check if generated files are different"
  echo "  --debug   Debug mode"
  echo "  --dry-run Don't write files, just display what was generated to stdout"
  echo
  echo "Actions:"
  echo "  create   PACKAGE  [PROFILES...]   Create new packages or profiles"
  echo "           --force                  Force creation of files regardless if they already exist"
  echo "  gen-json [PACKAGE] [PROFILES...]  Generate package.json files from source ices.zsh"
  echo "  gen-ices [PACKAGE] [PROFILES...]  Generate ices.zsh from package.json"
  echo "           --reproducible           Re-use generation timestamps (defaults to UNIX time 0 if JSON/ices.zsh file does not exist yet)"
  echo "  run      PACKAGE [PROFILE]        Run a given package inside a container"
  echo "           --non-interactive        Don't keep the container running but exit right away"
  echo '           --pack                   Run zinit pack"PROFILE" PACKAGE instead of sourcing the ices.zsh file'
  echo "           --regenerate             Regenerate ices.zsh (or package.json if --pack) prior to running"
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  CHECK="${CHECK:-}"
  DEBUG="${DEBUG:-}"
  DRY_RUN="${DRY_RUN:-}"
  FORCE="${FORCE:-}"
  NON_INTERACTIVE="${NON_INTERACTIVE:-}"
  RUN_PACKAGE="${RUN_PACKAGE:-}"
  REPRODUCIBLE="${REPRODUCIBLE:-}"
  REGENERATE="${REGENERATE:-}"

  ACTION="${ACTION:-generate-json}"

  ARGS=("$@")
  for arg in "${ARGS[@]}"
  do
    case "$arg" in
      -d|--debug)
        DEBUG=1
        IFS=" " read -r -a ARGS <<< "${ARGS[@]/$arg}"
        ;;
      -f|--force)
        FORCE=1
        IFS=" " read -r -a ARGS <<< "${ARGS[@]/$arg}"
        ;;
      -k|--dry-run)
        DRY_RUN=1
        IFS=" " read -r -a ARGS <<< "${ARGS[@]/$arg}"
        ;;
      -n|--non-interactive|-ni|--exit|-e)
        NON_INTERACTIVE=1
        IFS=" " read -r -a ARGS <<< "${ARGS[@]/$arg}"
        ;;
      -p|--pack|--package)
        RUN_PACKAGE=1
        IFS=" " read -r -a ARGS <<< "${ARGS[@]/$arg}"
        ;;
      -R|-rp|--rep|--repro|--reproducible)
        REPRODUCIBLE=1
        IFS=" " read -r -a ARGS <<< "${ARGS[@]/$arg}"
        ;;
      -c|--check)
        CHECK=1
        IFS=" " read -r -a ARGS <<< "${ARGS[@]/$arg}"
        ;;
      --regen*|-rr)
        REGENERATE=1
        IFS=" " read -r -a ARGS <<< "${ARGS[@]/$arg}"
        ;;
      # Action flags
      -C|--create|-i|--init)
        ACTION=create
        IFS=" " read -r -a ARGS <<< "${ARGS[@]/$arg}"
        ;;
      -r|--rev|--reverse)
        ACTION=generate-ices-zsh
        IFS=" " read -r -a ARGS <<< "${ARGS[@]/$arg}"
        ;;
      --run)
        ACTION=run
        IFS=" " read -r -a ARGS <<< "${ARGS[@]/$arg}"
        ;;
      --update-ices)
        ACTION=update-ices
        IFS=" " read -r -a ARGS <<< "${ARGS[@]/$arg}"
        ;;
      -h|--help)
        usage
        exit 0
        ;;
    esac
  done
  set -- "${ARGS[@]}"

  # Alternative usage: $0 create|gen-json|gen-ices|run|update-ices
  case "$1" in
    create|init|c|i)
      ACTION=create
      shift
      ;;
    json|generate|gen|gen-json|g|j)
      ACTION=generate-json
      shift
      ;;
    gen-ices|reverse|rev|r)
      ACTION=generate-ices-zsh
      shift
      ;;
    run|R)
      ACTION=run
      shift
      ;;
    update-self|update-ices|u)
      ACTION=update-ices
      shift
      ;;
  esac

  # Special snowflake, let's execute this right away.
  if [[ "$ACTION" == update-ices ]]
  then
    update_zinit_ice_list "$1"
    exit "$?"
  fi

  PACKAGE="$1"; shift
  PROFILES=("$@")

  if [[ -z "$PACKAGE" ]]
  then
    echo_err "Missing PACKAGE name"
    usage >&2
    exit 2
  fi

  PACKAGES=()
  # Check if we were provided with a file
  # eg: gen-pkg.sh null/default.ices.zsh
  if [[ -f "$PACKAGE" ]]
  then
    FILENAME="${PACKAGE##*/}"
    PACKAGES=("$(basename "$(dirname "$PACKAGE")")")
    PROFILES=("${FILENAME%%.ices.zsh}")
  # Check if we were provided with a dir
  # eg: gen-pkg.sh .
  # Since packages are also directories, we need to check if the provided dir
  # is a package dir (ie. with an *.ices.zsh file) and not proceed it that's the
  # case. Otherwise we will end up looking for package dirs inside a package
  # dir.
  # shellcheck disable=SC2010
  elif [[ -d "$PACKAGE" ]]
  then
    # Search for valid packages
    if ! ls -1 "$PACKAGE" | grep -qE '.ices.zsh$|^package.json$'
    then
      for pkg in $(list_packages "$PACKAGE")
      do
        PACKAGES+=("$pkg")
      done
    else
      # Single package
      PACKAGES+=("$PACKAGE")
    fi
  fi

  if [[ "$ACTION" != create ]] && [[ -z "${PACKAGES[*]}" ]]
  then
    echo_warn "Nothing to do (no such package: $PACKAGE)"
    echo_info "Available packages:\n$(list_packages "$PWD")"
    echo_info "To create a new package restart with:" \
              "$0 create ${PACKAGE:-PACKAGE_NAME}"
    exit 0
  fi

  rc=0
  failed_pkgs=()

  echo_info "Running action: $ACTION"

  case "$ACTION" in
    create)
      if [[ -z "$FORCE" ]] && [[ -z "${PROFILES[*]}" ]] && \
         [[ -e "${PACKAGE}/package.json" ]]
      then
        echo_err "Package $PACKAGE already exists"
        exit 1
      fi

      if create_package "$PACKAGE" "${PROFILES[@]}"
      then
        echo_info "Created ${PACKAGE} with profiles: ${PROFILES[*]:-default}"
        echo_info "Available profiles for ${PACKAGE}:"
        echo_info "$(list_profiles "$PACKAGE")"
      else
        echo_err "Something went wrong while creating $PACKAGE with "\
                 "profiles: ${PROFILES[*]}"
        rc=1
      fi
      ;;
    generate-json)
      # Generate package.json files
      for pkg in "${PACKAGES[@]}"
      do
        if ! generate_package_json "$pkg" "${PROFILES[@]}"
        then
          failed_pkgs+=("$pkg")
          rc=1
        fi
      done
      ;;
    run)
      # The PROFILES[@] may seem weird but that's the easiest way to forward
      # all the CLI args to run_package after all the parsing from above
      # it will only consume the first profile, and not all of them.
      run_package "${PACKAGES[0]}" "${PROFILES[@]}"
      ;;
    generate-ices-zsh)
      # Generate ices.zsh files
      for pkg in "${PACKAGES[@]}"
      do
        if ! generate_ices_zsh_files "$pkg" "${PROFILES[@]}"
        then
          failed_pkgs+=("$pkg")
          rc=1
        fi
      done

      if [[ "$rc" -ne 0 ]]
      then
        echo_err "Some packages failed to update:"
        echo_err "${failed_pkgs[*]}"
      fi
      ;;
    *)
      echo_err "Unknown action: $ACTION"
      usage >&2
      exit 2
      ;;
  esac

  if [[ "$rc" -ne 0 ]] && [[ -n "${failed_pkgs[*]}" ]]
  then
    echo_err "Some packages failed to update:"
    for pkg in "${failed_pkgs[@]}"
    do
      echo_err "$pkg"
    done
  fi

  exit "$rc"
fi
