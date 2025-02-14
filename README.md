# Ensi ELC workspace

Конфигурация воркспейса [ELC](https://github.com/ensi-platform/elc) для разработки сервисов Ensi.

## Установка

Клонируем воркспейс в удобное для вас место, однако если вы работаете под Windows, то клонировать воркспейс необходимо внутрь WSL.
```bash
git clone git@github.com:ensi-platform/elc-workspace.git ~/work/ensi/workspace
```
Создаём сеть для проекта
```
docker network create ensi
```
Регистрируем воркспейс (важно указать полный путь, а не относительный)
```
elc workspace add ensi ~/work/ensi/workspace
```
Выполняем скрипт инициализации
```bash
cd ~/work/ensi/workspace
./scripts/init
./scripts/create-dbs
```

Копируем файл env.example.yaml, даём ему имя env.yaml, обязательно задаём переменные
```
APPS_ROOT: /home/<user>/work/ensi/apps
PACKAGES_PATH: /home/<user>/work/ensi/packages
```

Далее необходимо клонировать код сервисов и библиотек.
Сделать это можно так же через elc.

Можно выборочно клонировать нужные вам сервисы по имени
```
elc clone catalog-pim orders-oms
```
либо клонировать сразу все репозитории по тэгу
```
elc clone --tag=app   # клоинровать только сервисы
elc clone --tag=lib   # клонировать только пакеты
elc clone --tag=code  # клонировать все репозитории с кодом: и сервисы и пакеты
```

Клонировать пакеты необходимо только если вы собираетесь их редактировать.
По умолчанию, пакеты устанавливаются вместе с остальными зависимостями сервиса через composer.

## Подготовка сервисов к запуску

При клонировании сервиса командой `elc clone` автоматически выполняется скрипт, который устанавливает зависимости сервиса,
поэтому дополнительно ничего делать не нужно.

Если же вы клонировали сервисы другим способом или с опцией `--no-hook`, то перед запуском сервиса следует выполнить следующие команды:

```bash
elc set-hooks .git_hooks

elc compose run --rm -u$(id -u):$(id -g) --entrypoint="" app npm install
elc compose run --rm -u$(id -u):$(id -g) --entrypoint="" app composer install

cp .env.example .env
elc compose run --rm -u$(id -u):$(id -g) --entrypoint="" app php artisan key:generate

elc restart
```
Бэк-сервисы работают на laravel octane, и в режиме разработки запускаются через chokidar - программу, которая следит за изменением кода и перезапускает сервер.
Пока не будут установлены зависимости, сервис не сможет отвечать на запросы и будет выдавать 502 ошибку.

## Разработка composer пакетов

Для работы над пакетами используется плагин [franzliedke/studio](https://github.com/franzliedke/studio).
Его нужно установить композером воркспейса, т.е. в любом сервисе выполняем
```bash
elc composer global require franzl/studio
```

Этот инструмент позволяет делать симлинки на пакеты, чтобы можно было одновременно править код и сервиса и пакета.
Разрабатываемые пакеты (например клиенты к другим сервисам) должны лежать в папке `packages` - она монтируется во все бэк-севрисы ensi.

Регистрируем пакет
```bash
elc bash
studio load /home/<user>/work/ensi/packages/my-package
```

Обратите внимание на то что путь до пакета - это путь на хост машине. Папка с пакетами монтируется в контейнер по тому же пути
по которому она лежит на хосте.

Если пакет не был ранее подключён в текущий сервис, то его надо прописать в composer.json руками, а не через `composer require`
```json
{
  "require": {
    "project/my-package": "dev-master"
  }
}
```

Далее, для того чтобы создался симлинк, нужно обновить пакет
```bash
elc composer update project/my-package
```

Чтобы убрать симлинк, вы можете либо убрать регистрацию пакета
```bash
elc bash
studio unload /home/<user>/work/ensi/packages/my-package
```
либо переименовать файл `studio.json` в `studio.json.txt`.
В обоих случаях нужно снова обновить пакет.

> Вы можете поместить файл studio.json в папку packages, а в сервисы поместить симлинк на этот файл. Так все сервисы будут шарить между собой настройки симлинков пакетов.

**Важно**: когда вы делаете симлинк на пакет, в composer.lock записывается локальный путь до пакета на вашей машине. Нужно следить за тем чтобы эти изменения не попадали в коммиты.

При добавлении нового пакета в систему вам нужно зарегистрировать его в файле workspace.yaml в секции modules
```yaml
modules:
  template--sdk-php:
    path: ${PACKAGES_PATH}/${TEMPLATE_SDK_PHP_PACKAGE_PATH:-template--sdk-php}
    hosted_in: cms-cms
    exec_path: ${PACKAGES_PATH}/${TEMPLATE_SDK_PHP_PACKAGE_PATH:-template--sdk-php}
```
Поля `path` и `exec_path` должны иметь одинаковое значение т.к. пакеты монтируются в контейнер по тому же пути что и на хосте.
Поле `hosted_in` должно указывать на сервис в контейнере которого вы хотите выполнять команды для этого пакета.

## Запуск сервиса [admin-gui-frontend](https://gitlab.com/greensight/ensi/admin-gui/admin-gui-frontend)
Для того чтобы запустить Frontend админки, вам нужно перейти в папку сервиса и запустить команду

```
elc start
```
У вас произойдет сборка и запуск сервиса Frontend Админки. 

По умолчанию адрес сервиса: http://admin-gui-frontend.ensi.127.0.0.1.nip.io

## Скрипты

```bash
./scripts/save-schemas
```
Генерирует для каждого сервиса полную openapi схему в формате yaml и сохраняет в папку `workspace/schemas`. Полезно для дальнейшего импорта в Postman.

## Сервисы 

### Запуск/остановка сервисов инфраструктуры
```
elc start <name_service>
elc stop <name_service>
``` 

| Имя сервиса  | Адрес | Описание |
| ------------- | ------------- | ------------- |
| database  | database.ensi.127.0.0.1.nip.io:5432  | Postgres 13  |
| elastic  | http://elastic.ensi.127.0.0.1.nip.io:9200  | Elasticsearch 7.9.2  |
| kibana  | http://kibana.ensi.127.0.0.1.nip.io  | Kibana 7.9.2  |
| es | http://es.ensi.127.0.0.1.nip.io  | Nginx 1.19  |
| kafka  | kafka.ensi.127.0.0.1.nip.io:9092  | Kafka  |
| kafka-ui  | http://kafka-ui.ensi.127.0.0.1.nip.io  | Kafka-UI  |
| maildev  | http://maildev.ensi.127.0.0.1.nip.io  | Maildev 2.0.5  |
| redis  | redis.ensi.127.0.0.1.nip.io:6379  | Redis 6  |
| redis-ui  | http://redis-ui.ensi.127.0.0.1.nip.io  | Redis-UI  |


## Переключение между версиями php

Чтобы переключить сервис на другую версию php, вам нужно зайти в файл workspace.yaml в диррективе templates: вы можете посмотреть все версии php/node которые вы можете использовать. 

```
templates:
  nodejs:
    path: ${WORKSPACE_PATH}/templates/nodejs
    variables:
      APP_IMAGE: nodejs:latest
      NGINX_IMAGE: dockerhub.greensight.ru/services/nginx:1.19-alpine
  fpm-8.1:
    path: ${WORKSPACE_PATH}/templates/fpm-8.1
    variables:
      BASE_IMAGE: dockerhub.greensight.ru/ensi-tech/php-base-image:8.1-master-2022may13
      APP_IMAGE: fpm-8.1:latest
      NGINX_IMAGE: dockerhub.greensight.ru/services/nginx:1.19-alpine  #original docker image - nginx:1.19-alpine
  swoole-8.1:
    path: ${WORKSPACE_PATH}/templates/swoole-8.1
    after_clone_hook: ${TPL_PATH}/hooks/after-clone.sh
    variables:
      BASE_IMAGE: dockerhub.greensight.ru/ensi-tech/php-base-image:8.1-master-2023mar4-1-swoole
      APP_IMAGE: swoole-8.1:latest
      NGINX_IMAGE: dockerhub.greensight.ru/services/nginx:1.19-alpine  #original docker image - nginx:1.19-alpine
  fpm-8.2:
    path: ${WORKSPACE_PATH}/templates/fpm-8.2
    variables:
      BASE_IMAGE: dockerhub.greensight.ru/ensi-tech/php-base-image:8.2-task-109866-2023july21-1
      APP_IMAGE: fpm-8.2:latest
      NGINX_IMAGE: dockerhub.greensight.ru/services/nginx:1.19-alpine  #original docker image - nginx:1.19-alpine
  swoole-8.2:
    path: ${WORKSPACE_PATH}/templates/swoole-8.2
    after_clone_hook: ${TPL_PATH}/hooks/after-clone.sh
    variables:
      BASE_IMAGE: dockerhub.greensight.ru/ensi-tech/php-base-image:8.2-task-109866-2023july21-1-swoole
      APP_IMAGE: swoole-8.2:latest
      NGINX_IMAGE: dockerhub.greensight.ru/services/nginx:1.19-alpine  #original docker image - nginx:1.19-alpine

```

Изменив значение extends со swoole-8.1 на swoole-8.2 то данный сервис будет использовать php 8.2 

```
  cms-cms:
    extends: swoole-8.2
    path: ${APPS_ROOT}/${SVC_CMS_CMS_PATH:-cms/cms}
    repository: git@gitlab.com:greensight/ensi/cms/cms.git
    tags:
      - code
      - app
      - backend
    dependencies:
      database: [default, hook]
      proxy:    [default]
    variables:
      DB_NAME: cms_cms
```

## Upgrade postgres from 13 to 17 version

Just run script `migrate-db-from-13-to-17.sh` from workspace folder
```
./scripts/migrate-db-from-13-to-15.sh
```
it can prompt a sudo password, because it works with postgres data dir.

Script makes two backups:
- `backup.sql` in current folder
- `data-13-backup` in database service folder

Keep this files until you prove that database works correct.
