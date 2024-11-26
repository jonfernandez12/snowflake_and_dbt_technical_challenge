SELECT
    dim_patients.id,
    dim_patients.first_name,
    dim_patients.last_name,
    dim_patients.country,
    SUM(fct_exercises.minutes) AS exercises_minutes,
    SUM(fct_steps.minutes) AS steps_minutes,
    SUM(fct_exercises.minutes) + SUM(fct_steps.minutes) AS total_minutes,
    RANK() OVER (ORDER BY (SUM(fct_exercises.minutes) + SUM(fct_steps.minutes)) desc) AS total_minutes_rank
FROM  {{ ref('dim_patients') }}
  AS dim_patients
LEFT JOIN  {{ ref('fct_exercises') }}
  AS fct_exercises
  ON fct_exercises.patient_id = dim_patients.id
LEFT JOIN  {{ ref('fct_steps') }}
  AS fct_steps
  ON fct_steps.patient_id = dim_patients.id
GROUP BY
    dim_patients.id,
    dim_patients.first_name,
    dim_patients.last_name,
    dim_patients.country