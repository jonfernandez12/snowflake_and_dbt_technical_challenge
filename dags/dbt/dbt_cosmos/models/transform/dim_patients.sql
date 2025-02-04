SELECT
  patient_id AS id,
  first_name,
  last_name,
  country
FROM {{ ref('stg_patients') }}