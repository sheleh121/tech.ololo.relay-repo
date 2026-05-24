#!/bin/sh
# ololo-relay package repo bootstrap.
# Использование:
#   curl -fsSL https://repo.ololo.tech/setup.sh | sh
#
# Поддерживаемые дистрибутивы:
#   - Ubuntu 24.04+
#   - Debian 12+
#   - Fedora 40+
#   - RedOS 7.x (Murom)
set -eu

REPO_URL="https://repo.ololo.tech"
KEY_URL="${REPO_URL}/pubkey.asc"

die() { echo "ERROR: $*" >&2; exit 1; }

require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        if command -v sudo >/dev/null 2>&1; then
            SUDO="sudo"
        else
            die "нужны права root (или sudo)."
        fi
    else
        SUDO=""
    fi
}

detect_os() {
    if [ ! -r /etc/os-release ]; then
        die "не нашёл /etc/os-release — неизвестная система."
    fi
    # shellcheck disable=SC1091
    . /etc/os-release

    case "${ID:-}" in
        ubuntu|debian)
            FAMILY=deb
            ;;
        fedora)
            FAMILY=rpm
            ;;
        redos)
            FAMILY=rpm
            ;;
        *)
            # Запасной путь — ID_LIKE.
            case "${ID_LIKE:-}" in
                *debian*|*ubuntu*)  FAMILY=deb ;;
                *fedora*|*rhel*|*centos*) FAMILY=rpm ;;
                *) die "неподдерживаемый дистрибутив: ID=${ID:-?} ID_LIKE=${ID_LIKE:-?}" ;;
            esac
            ;;
    esac
    echo ">>> обнаружен ${PRETTY_NAME:-$ID} (family=$FAMILY)"
}

setup_apt() {
    echo ">>> apt: установить deps"
    $SUDO apt-get update -qq
    $SUDO apt-get install -y --no-install-recommends ca-certificates curl gnupg

    echo ">>> apt: импортировать GPG-ключ репозитория"
    $SUDO install -d -m 0755 /etc/apt/keyrings
    curl -fsSL "$KEY_URL" | $SUDO gpg --dearmor -o /etc/apt/keyrings/ololo-relay.gpg
    $SUDO chmod 0644 /etc/apt/keyrings/ololo-relay.gpg

    echo ">>> apt: добавить source"
    echo "deb [signed-by=/etc/apt/keyrings/ololo-relay.gpg] ${REPO_URL}/apt stable main" \
        | $SUDO tee /etc/apt/sources.list.d/ololo-relay.list >/dev/null

    echo ">>> apt: update"
    $SUDO apt-get update

    cat <<EOF

================================================================
  Репозиторий ololo-relay подключён.

  Установить сервер (relay-узел):
      sudo apt-get install ololo-relay

  Установить десктоп-клиент (админка mesh):
      sudo apt-get install ololo-relay-admin
================================================================

EOF
}

setup_rpm() {
    if command -v dnf >/dev/null 2>&1; then
        PM=dnf
    elif command -v yum >/dev/null 2>&1; then
        PM=yum
    else
        die "не нашёл dnf/yum."
    fi

    echo ">>> $PM: импортировать GPG-ключ"
    $SUDO rpm --import "$KEY_URL"

    echo ">>> $PM: записать /etc/yum.repos.d/ololo-relay.repo"
    $SUDO tee /etc/yum.repos.d/ololo-relay.repo >/dev/null <<EOF
[ololo-relay]
name=ololo-relay
baseurl=${REPO_URL}/rpm
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=${KEY_URL}
EOF

    echo ">>> $PM: makecache"
    $SUDO $PM -q makecache --refresh || true

    cat <<EOF

================================================================
  Репозиторий ololo-relay подключён.

  Установить сервер (relay-узел):
      sudo $PM install ololo-relay

  Установить десктоп-клиент (админка mesh):
      sudo $PM install ololo-relay-admin
================================================================

EOF
}

require_root
detect_os

case "$FAMILY" in
    deb) setup_apt ;;
    rpm) setup_rpm ;;
esac
