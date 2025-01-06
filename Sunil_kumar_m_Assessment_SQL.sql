describe grubhub;
select * from grubhub;

alter table grubhub change timestamp timestamp timestamp;
alter table grubhub change Start_time Start_time time;
alter table grubhub change end_time end_time time;

Describe ubereats;
select * from grubhub;

alter table ubereats change timestamp timestamp timestamp;
alter table ubereats change Start_time Start_time time;
alter table ubereats change end_time end_time time;

 SELECT 
        slug AS ue_slug, 
        b_name AS ue_b_name, 
        vb_name AS ue_vb_name, 
        timestamp AS ue_timestamp,
        start_time AS ue_start_time, 
        end_time AS ue_end_time
FROM ubereats;

SELECT 
        slug AS gh_slug, 
        b_name AS gh_b_name, 
        vb_name AS gh_vb_name, 
        timestamp AS gh_timestamp,
        start_time AS gh_start_time, 
        end_time AS gh_end_time
FROM grubhub;



WITH UberEats_Hours AS (
    SELECT 
        slug AS ue_slug, 
        b_name AS ue_b_name, 
        vb_name AS ue_vb_name, 
        timestamp AS ue_timestamp,
        start_time AS ue_start_time, 
        end_time AS ue_end_time
    FROM sunil.ubereats
),
Grubhub_Hours AS (
    SELECT 
        slug AS gh_slug, 
        b_name AS gh_b_name, 
        vb_name AS gh_vb_name, 
        timestamp AS gh_timestamp,
        start_time AS gh_start_time, 
        end_time AS gh_end_time
    FROM sunil.grubhub
)
SELECT 
    gh.gh_slug AS grubhub_slug,
    gh.gh_b_name AS grubhub_name,
    gh.gh_vb_name AS grubhub_vb_name,
    gh.gh_start_time AS grubhub_start_time,
    gh.gh_end_time AS grubhub_end_time,
    ue.ue_slug AS ubereats_slug,
    ue.ue_b_name AS ubereats_name,
    ue.ue_vb_name AS ubereats_vb_name,
    ue.ue_start_time AS ubereats_start_time,
    ue.ue_end_time AS ubereats_end_time,
    CASE 
        WHEN gh.gh_start_time = ue.ue_start_time 
         AND gh.gh_end_time = ue.ue_end_time THEN 'In Range'
        WHEN ABS(TIMESTAMPDIFF(MINUTE, gh.gh_start_time, ue.ue_start_time)) <= 5 
         AND ABS(TIMESTAMPDIFF(MINUTE, gh.gh_end_time, ue.ue_end_time)) <= 5 THEN 'Out of Range with 5 mins difference'
        ELSE 'Out of Range'
    END AS is_out_range
FROM Grubhub_Hours gh
JOIN UberEats_Hours ue
ON gh.gh_slug = ue.ue_slug;




