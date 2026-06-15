# Быстрый запуск общей стены ответов в Yandex Cloud

Цель: подключить опубликованный сайт к общей базе ответов за 45-60 минут.

## 0. Что уже готово

- Сайт: `https://etudes-proust-web.website.yandexcloud.net`
- Архив функции для загрузки: `proust-backend/function/proust-function.zip`
- SQL-схема: `proust-backend/schema.sql`
- OpenAPI для API Gateway: `proust-backend/gateway/openapi.yaml`

## 1. Создать YDB Serverless

В Yandex Cloud:

1. `Создать ресурс` -> `Managed Service for YDB`.
2. Тип базы: `Serverless`.
3. Имя: `proust-answers`.
4. Регион: `ru-central1`.
5. Создать.

После создания на странице базы найти и сохранить:

- `Endpoint`, обычно начинается с `grpcs://...`
- `Database`, путь базы, обычно начинается с `/ru-central1/...`

Для Cloud Function нужен полный `YDB_ENDPOINT` в таком виде:

```text
grpcs://ydb.serverless.yandexcloud.net:2135/ru-central1/...
```

Если в интерфейсе endpoint и database path показаны отдельно, полный endpoint = `Endpoint` + `Database path`.

## 2. Создать таблицы

В YDB открыть `Навигация` / `SQL` / `YQL` / `Query editor`.

Выполнить содержимое файла:

```text
proust-backend/schema.sql
```

Должны появиться две таблицы:

- `submissions`
- `answers`

## 3. Создать сервисный аккаунт для backend

Можно использовать существующий `github-deploy` для скорости, но лучше отдельный:

1. `Identity and Access Management` -> `Сервисные аккаунты`.
2. Создать `proust-api`.
3. Назначить роли на каталог:
   - `ydb.editor`
   - `serverless.functions.invoker`

Скопировать `ID` сервисного аккаунта. Он нужен для API Gateway.

## 4. Создать Cloud Function

1. `Создать ресурс` -> `Cloud Functions`.
2. Имя: `proust-api`.
3. Создать функцию.
4. Создать версию.
5. Runtime: `Node.js 22`, если доступен. Если нет, `Node.js 20`.
6. Способ загрузки: `ZIP-архив`.
7. Загрузить файл:

```text
proust-backend/function/proust-function.zip
```

8. Точка входа:

```text
index.handler
```

9. Сервисный аккаунт: `proust-api`.
10. Переменные окружения:

```text
YDB_ENDPOINT=<полный grpcs endpoint базы>
ALLOWED_ORIGIN=https://etudes-proust-web.website.yandexcloud.net
MAX_RESULTS=300
```

11. Создать версию.

Скопировать `ID функции`.

## 5. Создать API Gateway

1. `Создать ресурс` -> `API Gateway`.
2. Имя: `proust-api-gateway`.
3. В спецификацию вставить содержимое:

```text
proust-backend/gateway/openapi.yaml
```

4. В тексте спецификации заменить:
   - `FUNCTION_ID` на ID Cloud Function.
   - `SERVICE_ACCOUNT_ID` на ID сервисного аккаунта `proust-api`.
5. Создать gateway.

Скопировать служебный домен gateway:

```text
https://<gateway-id>.apigw.yandexcloud.net
```

## 6. Проверить API

В браузере открыть:

```text
https://<gateway-id>.apigw.yandexcloud.net/results
```

Ожидаемый ответ:

```json
{"submissions":[]}
```

Если так, API живой.

## 7. Подключить API к сайту

В GitHub:

1. Репозиторий `ilyamoussatkine/etudesweb`.
2. `Settings` -> `Environments` -> `production`.
3. В `Environment variables` добавить:

```text
PROUST_API_URL=https://<gateway-id>.apigw.yandexcloud.net
```

4. Зайти в `Actions`.
5. Запустить workflow `Deploy Proust web to Yandex Object Storage` вручную через `Run workflow`.

## 8. Проверить, что ответы сохраняются

1. Открыть сайт:

```text
https://etudes-proust-web.website.yandexcloud.net/?v=api
```

2. Пройти короткую анкету.
3. Ввести псевдоним.
4. Нажать `Отправить и смотреть`.
5. Открыть:

```text
https://<gateway-id>.apigw.yandexcloud.net/results
```

В JSON должен появиться отправленный ответ.

## Быстрое понимание

- `localStorage` = ответы только на одном телефоне.
- `PROUST_API_URL` = сайт знает, куда отправлять ответы.
- `YDB` = место, где ответы остаются для всех.
- `API Gateway` = публичная HTTPS-ссылка для сайта.
- `Cloud Function` = код, который принимает и отдает ответы.
