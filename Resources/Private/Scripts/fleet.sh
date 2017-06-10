#!/usr/bin/env sh
set -o nounset
set -e


print_error() {
     >&2 echo "[ERROR] $1";
}

detect_script_dir() {
    if hash realpath 2> /dev/null && [ -z ${BASH+x} ]; then
        cd "$(dirname $(realpath "$0" ))";
    elif hash readlink 2> /dev/null  && [ -z ${BASH+x} ] && [[ "$(uname -s)" != "Darwin" ]]; then
        cd "$(dirname $(readlink -f "$0" ))";
    else
        cd "$(dirname "$0" )";
    fi

    pwd
}

detect_extension_dir() {
    local base="$(detect_script_dir)/../../..";
    if hash realpath 2> /dev/null && [ -z ${BASH+x} ]; then
        realpath "$base";
    elif hash readlink 2> /dev/null  && [ -z ${BASH+x} ] && [[ "$(uname -s)" != "Darwin" ]]; then
        readlink -f "$base";
    else
        echo "$base";
    fi
}

prepare_typo3_path_web() {
    if [ -z ${TYPO3_PATH_WEB+x} ]; then
        local extension_dir="$(detect_extension_dir)";
        local typo3_path_web_dirty;
        if [ -d "$extension_dir/../TYPO3.CMS" ]; then
            typo3_path_web_dirty="$extension_dir/../TYPO3.CMS";
        elif [ -d "$extension_dir/../../../typo3" ]; then
            typo3_path_web_dirty="$(dirname "$extension_dir/../../../typo3")";
        else
            print_error "Could not detect TYPO3_PATH_WEB";
            exit 102;
        fi

        if hash realpath 2> /dev/null && [ -z ${BASH+x} ]; then
            TYPO3_PATH_WEB="$(realpath "$typo3_path_web_dirty")";
        elif hash readlink 2> /dev/null  && [ -z ${BASH+x} ] && [[ "$(uname -s)" != "Darwin" ]]; then
            TYPO3_PATH_WEB="$(readlink -f "$typo3_path_web_dirty")";
        else
            TYPO3_PATH_WEB="$typo3_path_web_dirty";
        fi
    fi
}

prepare_php() {
    if [ -z ${PHP_BINARY+x} ]; then
        local paths="
/opt/plesk/php/7.1/bin/php
/opt/php/php71/bin/php
/opt/plesk/php/7.0/bin/php
/opt/php/php70/bin/php
/opt/plesk/php/5.6/bin/php
/opt/php/php5.6/bin/php
/opt/plesk/php/5.5/bin/php
/opt/php/php5.5/bin/php
/usr/local/bin/php
        ";

        for path in ${paths}; do
            if [ -x "$path" ]; then
                PHP_BINARY="$path";
                return 0;
            fi
        done

        print_error "Could not detect PHP";
        exit 101;
    fi
}

load_env(){
    if [ -e "$HOME/.zprofile" ]; then
        source "$HOME/.zprofile";
    elif [ -e "$HOME/.profile" ]; then
        source "$HOME/.profile";
    fi
}

main() {
    local command="fleet:info:info";
    if [ "$#" -gt 0 ];then
        command="fleet:$1";
    fi
    detect_script_dir > /dev/null;
    load_env;
    prepare_typo3_path_web;
    prepare_php;

    ${PHP_BINARY} "$TYPO3_PATH_WEB/typo3/cli_dispatch.phpsh" "extbase" "$command";
}

main "$@";
