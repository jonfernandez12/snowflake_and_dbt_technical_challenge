SELECT
  id,
  external_id AS patient_id,
  steps,
  steps * 0.002 AS minutes,
  submission_time::TIMESTAMP_TZ AS submitted_at,
  updated_at::TIMESTAMP_TZ AS updated_at
FROM {{ ref('stg_steps') }}