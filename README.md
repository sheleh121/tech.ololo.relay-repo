# tech.ololo.relay-repo

Публичный пакетный репозиторий ololo. Хостится на GitHub Pages,
доступен по [repo.ololo.tech](https://repo.ololo.tech/).

Здесь лежат собранные и подписанные пакеты, метаданные APT/DNF и
публичный GPG-ключ — всё, что нужно клиенту, чтобы поставить ololo-relay
через `apt`/`dnf`. Содержимое регенерируется автоматически при выпуске
новой версии.

## Структура

```
.
├── apt/                  # APT-репозиторий (Debian/Ubuntu)
│   ├── conf/             # reprepro config
│   ├── dists/stable/     # метаданные
│   └── pool/             # .deb-файлы
├── rpm/                  # DNF/YUM-репозиторий (Fedora, RedOS)
│   ├── Packages/         # .rpm-файлы
│   └── repodata/         # createrepo_c metadata
├── pubkey.asc            # публичный GPG-ключ
├── setup.sh              # bootstrap-скрипт
├── index.html            # landing
└── CNAME                 # repo.ololo.tech
```

## Как пользоваться

См. [setup.sh](setup.sh) или [страницу продукта](https://ololo.tech/products/relay/).

Если хочется руками:

**Debian/Ubuntu:**
```bash
curl -fsSL https://repo.ololo.tech/pubkey.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/ololo-relay.gpg
echo "deb [signed-by=/etc/apt/keyrings/ololo-relay.gpg] https://repo.ololo.tech/apt stable main" \
    | sudo tee /etc/apt/sources.list.d/ololo-relay.list
sudo apt update && sudo apt install ololo-relay
```

**Fedora / RedOS:**
```bash
sudo rpm --import https://repo.ololo.tech/pubkey.asc
sudo tee /etc/yum.repos.d/ololo-relay.repo <<EOF
[ololo-relay]
name=ololo-relay
baseurl=https://repo.ololo.tech/rpm
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://repo.ololo.tech/pubkey.asc
EOF
sudo dnf install ololo-relay
```

## GPG-ключ

Все артефакты подписаны:

- Fingerprint: `7996 8800 C963 EE63 2443 8ADA 2E81 F9E2 E462 1CF2`
- Key ID: `2E81F9E2E4621CF2`
- Действителен до: 2028-05-22

Сверить отпечаток:

```bash
curl -fsSL https://repo.ololo.tech/pubkey.asc | gpg --show-keys
```

## Безопасность

Уязвимости и инциденты — на адрес `security@ololo.tech`.
