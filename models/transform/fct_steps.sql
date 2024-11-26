SELECT
    id,
    external_id AS patient_id,
    steps,
    TRY_TO_TIMESTAMP_TZ(submission_time, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') AS submitted_at,
    TRY_TO_TIMESTAMP_TZ(updated_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') AS updated_at
FROM {{ ref('stg_steps') }}