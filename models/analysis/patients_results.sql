WITH top_minutes_patient AS (
SELECT
  MAX_BY(patients_grouped.id, patients_grouped.total_minutes) AS id
FROM {{ ref('patients_grouped') }}
  AS patients_grouped
)

SELECT
  top_minutes_patient.id,
  dim_patients.first_name,
  dim_patients.last_name,
  dim_patients.country
FROM top_minutes_patient
LEFT JOIN {{ ref('dim_patients') }}
  AS dim_patients
  ON dim_patients.id =   top_minutes_patient.id

