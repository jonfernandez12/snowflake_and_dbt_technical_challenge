SELECT
  id AS patient_id,
  first_name,
  last_name,
  country,
  total_minutes
FROM {{ ref('grouped_patients') }}
WHERE total_minutes_rank = 1