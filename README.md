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
./scripts/create-dbs # если собираетесь развернуть базы из бэкапа, этого делать не надо
```

Копируем файл env.example.yaml, даём ему имя env.yaml, обязательно задаём переменные
```
APPS_ROOT: /home/<user>/work/ensi/apps
PACKAGES_PATH: /home/<user>/work/ensi/packages
```

Клонируем сервисы Ensi в папку apps в соответствии с вот этой структурой:
```bash
apps
├── admin-gui
│   ├── admin-gui-backend
│   └── admin-gui-frontend
├── catalog
│   ├── feed
│   ├── offers
│   └── pim
├── cms
│   └── cms
├── communication
│   ├── communication
│   └── internal-messenger
├── customers
│   ├── crm
│   ├── customer-auth
│   └── customers
├── logistic
│   ├── geo
│   └── logistic
├── marketing
│   └── marketing
├── orders
│   ├── baskets
│   ├── oms
│   └── packing
├── reviews
│   └── reviews
└── units
    ├── admin-auth
    ├── bu
    └── seller-auth
```
Конечные папки в этом дереве, такие как feed или oms, должны быть корнями репозиториев соответсвующих сервисов.  
Вы можете разложить сервисы Ensi и подругому, однако тогда вам будет необходимо задать переменные в файле env.yaml.

Дополнительно вы можете клонировать пакеты в папку `packages` рядом с папкой воркспейса. Для пакетов не задана особая структура расположения, однако они должны находиться внутри дирректории `packages`.

Вы не обязаны клонировать все сервисы сразу, однако некоторые сервисы могут зависеть друг от друга и запуск их в неподходящем режиме может завершиться ошибкой.

## Миграция с ELC bash edition

Если у вас уже установлена старая версия ELC (написанная на bash), то вам, вероятно, захочется сохранить уже клонированные сервисы и содержимое баз данных.
В этом случае установка воркспейса немного усложняется.

Чтобы перенести содержимое БД, запустим старую БД и сделаем бэкап.
Для этого в вокспейсе в папке scripts есть скрипт, который нужно будет вызвать:
```bash
ensi global start postgres

cd scripts
./get-dbs-from-old-elc

ensi global stop postgres
```
В текущей дирректории будет создана папка backup, проверьте что в ней есть файлы.

Запускаем новую БД, и выполняем другой скрипт, который восстановит базы из бэкапа:
```bash
elc start database

cd  scripts
./restore-databases
```

Далее последовательно копируем репозитории сервисов из старой папки ELC в папку apps нового воркспейса.
Опять же, используем mv чтобы не повредить права:
```bash
sudo mv ensi-old/apps/crm ensi/apps/customers/crm
sudo mv ensi-old/apps/oms ensi/apps/orders/oms
...
```

Если вы создавали скрипты в `ensi-old/data/home`, то можете перенести их в `ensi/home`.
Если вы записывали файлы в ensi-storage и хотите их сохранить - скопируйте и их.
Все кастомизации старых конфигов придётся интегрировать в новый воркспейс вручную.

## Подготовка сервисов к запуску

В каждом сервисе необходимо выполнить
```bash
elc set-hooks .git_hooks
elc composer install
elc npm install
cp .env.example .env
elc php artisan key:generate
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
