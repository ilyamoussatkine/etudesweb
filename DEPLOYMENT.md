# Deployment

## GitHub Environment

Create an environment named `production`.

Environment variables:

- `YC_BUCKET_NAME` - `etudes-proust-web`
- `PROUST_API_URL` - API Gateway base URL. Keep empty until API Gateway is created.

Environment secrets:

- `YC_STORAGE_ACCESS_KEY_ID` - `key_id` from `yc iam access-key create`.
- `YC_STORAGE_SECRET_ACCESS_KEY` - `secret` from `yc iam access-key create`.

Do not commit static access keys to the repository.

## Static Site

GitHub Actions deploys `proust-web/` to Yandex Object Storage using:

```text
.github/workflows/deploy.yml
```

The workflow generates `proust-web/config.js` at deploy time, so the live API URL is not stored in the repository.

Current static website URL:

```text
https://etudes-proust-web.website.yandexcloud.net
```

## Backend

Backend files:

- `proust-backend/schema.sql`
- `proust-backend/function/index.js`
- `proust-backend/function/package.json`
- `proust-backend/gateway/openapi.yaml`

Cloud Function environment variables:

- `YDB_ENDPOINT`
- `ALLOWED_ORIGIN`
- `MAX_RESULTS`
