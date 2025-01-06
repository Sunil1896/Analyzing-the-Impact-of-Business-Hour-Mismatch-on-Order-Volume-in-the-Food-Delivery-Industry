# 📊 Business Hour Mismatch Analysis - Grubhub vs UberEats

## 📌 Overview
This repository contains **SQL queries** and **BigQuery functions** to analyze and compare **business hours** for restaurants listed on **Grubhub** and **UberEats**. The goal is to identify mismatches in operational hours and generate insights for correction.

### 🚀 Problem Statement
Restaurants often operate on **multiple delivery platforms**, but their **business hours may not be synchronized**. This project calculates a **business hour mismatch metric** to highlight discrepancies between **Grubhub** and **UberEats** listings.

---

## 📂 Dataset Description
We have two separate **BigQuery tables**:

| 🏬 Platform  | 📑 Table Name |
|-------------|--------------|
| **Grubhub** | `virtual_kitchen_grubhub_hours` |
| **UberEats** | `virtual_kitchen_ubereats_hours` |

### 📝 Extracted JSON Fields
| Column | Description |
|--------|-------------|
| `b_name` | Business name |
| `vb_name` | Virtual brand |
| `slug` | Unique restaurant identifier |
| `timestamp` | Data extraction timestamp |
| `start_time` | Business opening time |
| `end_time` | Business closing time |

---

## 🛠️ SQL Queries
### 1️⃣ Extract UberEats Business Hours
```sql
CREATE TEMP FUNCTION CUSTOM_JSON_EXTRACT(json STRING, json_path STRING) 
RETURNS STRING
LANGUAGE js AS """
  try {
    let obj = JSON.parse(json);
    let pathParts = json_path.split('.');
    let result = obj;
    for (let part of pathParts) {
      if (part === '*') {
        part = Object.keys(result)[0];  // Handle dynamic keys
      }
      if (result[part] !== undefined) {
        result = result[part];
      } else {
        return null;
      }
    }
    return typeof result === 'object' ? JSON.stringify(result) : result.toString();
  } catch (e) {
    return null;
  }
""";

SELECT
  b_name AS business_name,          
  vb_name AS virtual_brand,      
  slug AS ubereats_slug,              
  timestamp,                     
  CUSTOM_JSON_EXTRACT(TO_JSON_STRING(response), 'data.menus.*.sections.0.regularHours.0.startTime') AS ubereats_start_time,
  CUSTOM_JSON_EXTRACT(TO_JSON_STRING(response), 'data.menus.*.sections.0.regularHours.0.endTime') AS ubereats_end_time
FROM
  `your_project_id.your_dataset_name.virtual_kitchen_ubereats_hours`
LIMIT 1000;
```

### 2️⃣ Extract Grubhub Business Hours
```sql
SELECT
  b_name AS business_name,
  vb_name AS virtual_brand,
  slug AS grubhub_slug,
  timestamp,
  JSON_EXTRACT_SCALAR(response, '$.availability_by_catalog.STANDARD_DELIVERY.schedule_rules[0].from') AS grubhub_start_time,
  JSON_EXTRACT_SCALAR(response, '$.availability_by_catalog.STANDARD_DELIVERY.schedule_rules[0].to') AS grubhub_end_time
FROM 
  `your_project_id.your_dataset_name.virtual_kitchen_grubhub_hours`
LIMIT 1000;
```

### 3️⃣ Compare Business Hours Between UberEats and Grubhub
```sql
SELECT 
  gh.business_name,
  gh.virtual_brand,
  gh.grubhub_slug,
  ue.ubereats_slug,
  gh.grubhub_start_time,
  gh.grubhub_end_time,
  ue.ubereats_start_time,
  ue.ubereats_end_time,
  CASE 
    WHEN gh.grubhub_start_time = ue.ubereats_start_time 
      AND gh.grubhub_end_time = ue.ubereats_end_time THEN 'In Range'
    WHEN ABS(TIMESTAMP_DIFF(TIMESTAMP(gh.grubhub_start_time), TIMESTAMP(ue.ubereats_start_time), MINUTE)) > 5
      OR ABS(TIMESTAMP_DIFF(TIMESTAMP(gh.grubhub_end_time), TIMESTAMP(ue.ubereats_end_time), MINUTE)) > 5 THEN 'Out of Range with 5 mins difference'
    ELSE 'Out of Range'
  END AS is_out_of_range
FROM 
  `your_project_id.your_dataset_name.virtual_kitchen_grubhub_hours` gh
JOIN 
  `your_project_id.your_dataset_name.virtual_kitchen_ubereats_hours` ue
ON 
  gh.grubhub_slug = ue.ubereats_slug;
```




