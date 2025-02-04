SELECT
  id,
  external_id AS patient_id,
  minutes,
  completed_at::TIMESTAMP_TZ AS completed_at,
  updated_at::TIMESTAMP_TZ AS updated_at
FROM {{ ref('stg_exercises') }}