# Proust Questionnaire Backend

Backend for the Etudes Proust questionnaire.

## Resources

- YDB Serverless database.
- Cloud Function with Node.js runtime.
- API Gateway with `/submissions` and `/results`.

## Environment Variables

Set these variables for the Cloud Function version:

- `YDB_ENDPOINT` - YDB connection string, for example `grpcs://ydb.serverless.yandexcloud.net:2135/ru-central1/...`
- `ALLOWED_ORIGIN` - published website origin, for example `https://<bucket>.website.yandexcloud.net`
- `MAX_RESULTS` - optional, default `200`

## Tables

Run `schema.sql` in YDB WebSQL or via CLI before calling the API.

## Function Entrypoint

Use:

```text
index.handler
```

## API Gateway

Copy `gateway/openapi.yaml` into API Gateway and replace:

- `FUNCTION_ID`
- `SERVICE_ACCOUNT_ID`

The API base URL should be placed into:

```js
window.PROUST_API_URL = "https://<gateway-id>.apigw.yandexcloud.net";
```

in `proust-web/config.js`.
