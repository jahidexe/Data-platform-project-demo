{{ config(materialized='table') }}

WITH src AS (
  SELECT * FROM `esg-dev-jahid.bronze.insurance_claims_raw`
)
SELECT
  CAST(policy_number AS STRING) AS policy_number,
  SAFE_CAST(age AS INT64) AS age,
  PARSE_DATE('%Y-%m-%d', policy_bind_date) AS policy_bind_date,
  UPPER(fraud_reported) AS fraud_reported,
  * EXCEPT(_c39, Unnamed__0, Unnamed__1)
FROM src;
