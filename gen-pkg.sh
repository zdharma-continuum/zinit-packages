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
    "$input_file" > "$tmpfile"

  if [[ -n "$DRY_RUN" ]]
  then
    jq -e . "$tmpfile"
    return "$?"
  fi

  mv "$tmpfile" "$pkgfile"
}

process_package_profile() {
  local package="$1"
  local profile="$2"
  local zinit_json_data

  echo_debug "Processing package $package - profile: $profile"
  if ! zinit_json_data="$(get_zinit_json_data "$package" "$profile")"
  then
    return "$?"
  fi

  update_ices "$package" "$profile" "$zinit_json_data"
}

process_package() {
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
    process_package_profile "$package" "$profile"
    # Unset vars which may be set from the .ices.zsh files
    eval unset "${PACKAGE_VARS[*]}"
  done
}

reverse_process_package() {
  local package="$1"; shift
  local -a profiles=("$@")

  echo_info "Generating ices.zsh for package $package"
  local srcfile pkgfile="$package/package.json"
  local content ice ice_data ice_val metadata plugin
  local author description license version requirements url
  local -a ices
  local default_plugin="zdharma-continuum/null"
  local modeline='# vim: set ft=zsh et ts=2 sw=2 :'

  if ! [[ -f "$pkgfile" ]]
  then
    echo_err "Missing package.json in ${package}/"
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
    author="$(jq -er '.author // ""' "$pkgfile")"
    description="$(jq -er '.description // ""' "$pkgfile")"
    license="$(jq -er '.license // ""' "$pkgfile")"
    message="$(jq -er '.message // ""' <<< "$metadata")"
    # FIXME The requirements field really shouldn't be in the ices array...
    requirements="$(jq -er '.requires // ""' <<< "$ice_data")"
    url="$(jq -er '.homepage // ""' "$pkgfile")"
    version="$(jq -er '.version // ""' <<< "$metadata")"

    local now
    if [[ -n "$REPRODUCIBLE" ]]
    then
      now="$(date -d @0 -Iseconds --utc)"
    else
      now="$(date -Iseconds)"
    fi
    content="# zinit package for ${package} [${profile}]\n"
    content+="# Generated by $(basename "$0")\n"
    content+="# ${now}\n"
    content+="AUTHOR=\"${author}\"\n"
    content+="DESCRIPTION=\"${description}\"\n"
    content+="LICENSE=\"${license}\"\n"
    content+="MESSAGE=\"${message}\"\n"
    content+="REQUIREMENTS=\"${requirements}\"\n"
    content+="URL=\"${url}\"\n"
    content+="VERSION=\"${version}\"\n"
    plugin="$(jq -er --arg default "$default_plugin" '
      (.user + "/" + .plugin) as $n |
      if ($n != "/") then
        $n
      else
        $default
      end' <<< "$metadata")"

    # Add zinit call to output (static)
    content+='\nzinit \\\n'

    # Process ices
    readarray -t ices < <(\
      jq -e -r -c \
      'keys[] | select((contains("requires") | not) and (contains("plugin") | not))' <<< "$ice_data")

    for ice in "${ices[@]}"  # note: $ices holds the ice names only
    do
      content+="    $ice"
      # Note: We need to properly encode single quotes since we are using these
      # to quote the ice values below
      ice_val="$(jq -e -r --arg ice "$ice" '.[$ice]' <<< "$ice_data" | sed "s/'/'\\\''/g")"

      # Add newlines after && and ; (should only occur within atclone/atpull)
      # FIXME This breaks a few awk and sed calls
      # in dircolors for eg there's an: ${P}sed -i '/DIR/c\DIR 38;5;63;1'
      ice_val="$(sed -r 's#(&&|;)#\1\n     #g' <<< "$ice_val")"

      # Append the quoted value of the ice
      if [[ -n "$ice_val" ]]
      then
        content+="'${ice_val}'"
      fi

      content+=' \\\n'
    done

    content+="  for @${plugin}\n\n"
    content+="$modeline"

    echo_debug "Generated content for ${srcfile}:\n${content}"
    if [[ -n "$DRY_RUN" ]]
    then
      echo -e "$content"
      echo
    else
      echo -e "$content" > "$srcfile"
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
  reverse_process_package "$package"
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
  cmd=("$(fetch_zinit_docker_run)")

  if [[ -n "$DEBUG" ]]
  then
    cmd=(bash -x "${cmd[0]}")
  fi

  local ices_file="${package}/${profile}.ices.zsh"

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
  echo "  --debug   Debug mode"
  echo "  --dry-run Don't anything, just echo what would be generated"
  echo
  echo "Actions:"
  echo "  create   PACKAGE  [PROFILES...]   Create new packages or profiles"
  echo "           --force                  Force creation of files regardless if they already exist"
  echo "  gen-json [PACKAGE] [PROFILES...]  Generate package.json files from source ices.zsh"
  echo "  gen-ices [PACKAGE] [PROFILES...]  Generate ices.zsh from package.json"
  echo "           --reproducible           Set timestamps to UNIX time 0"
  echo "  run      PACKAGE [PROFILE]        Run a given package inside a container"
  echo "           --non-interactive        Don't keep the container running but exit right away"
  echo '           --pack                   Run zinit pack"PROFILE" PACKAGE instead of sourcing the ices.zsh file'
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  DEBUG="${DEBUG:-}"
  DRY_RUN="${DRY_RUN:-}"
  FORCE="${FORCE:-}"
  NON_INTERACTIVE="${NON_INTERACTIVE:-}"
  RUN_PACKAGE="${RUN_PACKAGE:-}"
  REPRODUCIBLE="${REPRODUCIBLE:-}"

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
      -n|--non-interactive)
        NON_INTERACTIVE=1
        IFS=" " read -r -a ARGS <<< "${ARGS[@]/$arg}"
        ;;
      -p|--pack|--package)
        RUN_PACKAGE=1
        IFS=" " read -r -a ARGS <<< "${ARGS[@]/$arg}"
        ;;
      -R|--reproducible)
        REPRODUCIBLE=1
        IFS=" " read -r -a ARGS <<< "${ARGS[@]/$arg}"
        ;;
      # Action flags
      -c|--create|-i|--init)
        ACTION=create
        IFS=" " read -r -a ARGS <<< "${ARGS[@]/$arg}"
        ;;
      -r|--reverse)
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
    gen-ices|reverse|r)
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
    # "normal" mode, not --reverse
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
        if ! process_package "$pkg" "${PROFILES[@]}"
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
        if ! reverse_process_package "$pkg" "${PROFILES[@]}"
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
