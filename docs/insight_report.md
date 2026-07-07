# Business Insight Report

This document summarizes the analytical results generated from the Gold layer using the SQL queries available in `sql/analytics/business_queries.sql`.

---

## Overview

| Item | Value |
|---|---|
| Dataset | NYC Yellow Taxi Trips (January 2026) |
| Source Layer | Gold |
| Total Cleaned Trips | 2,507,953 |
| Analysis Period | January 1–31, 2026 |
| Total Business Queries | 10 |

---

## Q1. How many valid taxi trips were recorded during January 2026?

**Result**

| Total Valid Trips | Start Date | End Date | Total Days |
|---:|---|---|---:|
| 2,507,953 | 2026-01-01 | 2026-01-31 | 31 |

**Insight:** The pipeline processed just over 2.5 million valid trips for the month, averaging roughly 80,900 trips per day. This is a healthy validation rate and gives a solid base for the rest of the analysis.

---

## Q2. What were the total revenue, average daily revenue, average fare, and average tip?

**Result**

| Total Revenue | Avg Revenue/Day | Avg Fare | Avg Tip |
|---:|---:|---:|---:|
| 72,675,567.53 | 2,344,373.15 | 19.51 | 3.58 |

**Insight:** Total revenue for the month was about $72.7M, or roughly $2.34M per day. The average tip of $3.58 works out to about 18% of the average fare, which is a fairly normal tipping rate for NYC taxis.

---


## Q6. Which borough and pickup zone handled the highest number of trips?

**Result — by borough**

| Borough | Total Trips |
|---|---:|
| Manhattan | 2,181,099 |
| Queens | 256,824 |
| Brooklyn | 46,991 |
| Bronx | 18,333 |
| Unknown | 3,841 |
| (blank) | 658 |
| EWR | 116 |
| Staten Island | 91 |

**Result — top 10 pickup zones**

| Zone | Borough | Total Pickup Trips |
|---|---|---:|
| JFK Airport | Queens | 141,090 |
| Upper East Side South | Manhattan | 134,813 |
| Upper East Side North | Manhattan | 122,216 |
| Midtown Center | Manhattan | 117,617 |
| Penn Station/Madison Sq West | Manhattan | 94,077 |
| Midtown East | Manhattan | 90,668 |
| Lincoln Square East | Manhattan | 86,747 |
| Times Sq/Theatre District | Manhattan | 82,995 |
| LaGuardia Airport | Queens | 80,590 |
| Upper West Side South | Manhattan | 70,633 |

**Insight:** Manhattan accounts for about 87% of all trips, which isn't surprising given its density and tourist traffic. What stands out is that JFK Airport alone generates more pickups than any single Manhattan zone, showing how much of the demand is airport-driven rather than purely local.

---

## Q7. Which pickup zones generated the highest revenue?

**Result**

| Zone | Borough | Total Revenue | Avg Fare | Avg Tip |
|---|---|---:|---:|---:|
| JFK Airport | Queens | 11,180,859.54 | 61.51 | 9.00 |
| LaGuardia Airport | Queens | 5,589,586.13 | 44.24 | 9.40 |
| Midtown Center | Manhattan | 2,959,015.46 | 15.77 | 3.38 |
| Upper East Side South | Manhattan | 2,762,789.50 | 12.51 | 2.79 |
| Upper East Side North | Manhattan | 2,558,471.93 | 13.07 | 2.88 |
| Penn Station/Madison Sq West | Manhattan | 2,350,543.08 | 16.03 | 3.32 |
| Times Sq/Theatre District | Manhattan | 2,322,495.20 | 18.05 | 3.63 |
| Midtown East | Manhattan | 2,223,245.60 | 15.27 | 3.32 |
| Lincoln Square East | Manhattan | 1,910,700.08 | 13.69 | 3.03 |
| Midtown North | Manhattan | 1,710,641.15 | 15.28 | 3.30 |

**Insight:** Even though JFK has fewer trips than several Manhattan zones, it produces almost 4x the revenue of the next zone because each trip averages $61.51 versus $12–18 for Manhattan zones. Airport trips are clearly the most valuable per ride, both in fare and tip amount.

---

## Q10. What are the most common data quality issues?

**Result**

| Error Type | Column | Issue Count | % of Total | Rank |
|---|---|---:|---:|---:|
| invalid_trip_distance | trip_distance | 125,738 | 46.98% | 1 |
| invalid_datetime | tpep_pickup_datetime | 45,070 | 16.84% | 2 |
| invalid_fare_amount | fare_amount | 41,545 | 15.52% | 3 |
| invalid_total_amount | total_amount | 40,417 | 15.10% | 4 |
| invalid_passenger_count | passenger_count | 14,787 | 5.53% | 5 |
| invalid_tip_amount | tip_amount | 67 | 0.03% | 6 |
| out_of_range_date | tpep_pickup_datetime | 7 | 0.00% | 7 |

**Insight:** Nearly half of all data quality issues come from invalid trip distances, which is by far the biggest cleanup priority. Datetime, fare, and total amount errors are a second tier, each contributing 15–17%. Passenger count issues are minor, and tip/date range errors are negligible.

---

## Q11. Are there any unusual daily or hourly trip patterns?

**Result — daily pattern (extremes)**

| Pickup Date | Total Trips | Avg Trips (overall) | Deviation | % Deviation | Status |
|---|---:|---:|---:|---:|---|
| 2026-01-15 | 102,710 | 80,901.71 | +21,808.29 | +26.96% | Normal |
| 2026-01-20 | 92,433 | 80,901.71 | +11,531.29 | +14.25% | Normal |
| 2026-01-01 | 62,788 | 80,901.71 | −18,113.71 | −22.39% | Normal |
| 2026-01-26 | 38,574 | 80,901.71 | −42,327.71 | −52.32% | Very Low |
| 2026-01-25 | 17,551 | 80,901.71 | −63,350.71 | −78.31% | Very Low |


**Result — hourly pattern**

| Hour | Period | Total Trips | Avg Trips (overall) | Status |
|---:|---|---:|---:|---|
| 18 | Evening | 182,031 | 104,498.04 | Very High |
| 17 | Evening | 181,300 | 104,498.04 | Very High |
| 16 | Afternoon | 172,339 | 104,498.04 | Very High |
| 15 | Afternoon | 169,510 | 104,498.04 | Very High |
| 14 | Afternoon | 158,334 | 104,498.04 | Very High |
| 6 | Morning | 32,840 | 104,498.04 | Very Low |
| 2 | Late Night | 25,675 | 104,498.04 | Very Low |
| 3 | Late Night | 17,482 | 104,498.04 | Very Low |
| 5 | Late Night | 16,194 | 104,498.04 | Very Low |
| 4 | Late Night | 12,337 | 104,498.04 | Very Low |

**Insight:** The clearest pattern is the two-day slump on January 25–26, where trip volume dropped 52–78% below average — this is worth investigating, since it likely reflects a real-world event (holiday, storm, service disruption) rather than random variation. On the hourly side, demand peaks predictably between 2 PM and 7 PM (the afternoon/evening rush), while the 2–5 AM window is consistently the quietest part of the day.

---

## Q13. Which pickup zones generated the highest revenue? (Top 10 ranked)

**Result**

| Rank | Zone | Borough | Total Pickup Trips | Total Revenue | Avg Fare | Avg Tip |
|---:|---|---|---:|---:|---:|---:|
| 1 | JFK Airport | Queens | 141,090 | 11,180,859.54 | 61.51 | 9.00 |
| 2 | LaGuardia Airport | Queens | 80,590 | 5,589,586.13 | 44.24 | 9.40 |
| 3 | Midtown Center | Manhattan | 117,617 | 2,959,015.46 | 15.77 | 3.38 |
| 4 | Upper East Side South | Manhattan | 134,813 | 2,762,789.50 | 12.51 | 2.79 |
| 5 | Upper East Side North | Manhattan | 122,216 | 2,558,471.93 | 13.07 | 2.88 |
| 6 | Penn Station/Madison Sq West | Manhattan | 94,077 | 2,350,543.08 | 16.03 | 3.32 |
| 7 | Times Sq/Theatre District | Manhattan | 82,995 | 2,322,495.20 | 18.05 | 3.63 |
| 8 | Midtown East | Manhattan | 90,668 | 2,223,245.60 | 15.27 | 3.32 |
| 9 | Lincoln Square East | Manhattan | 86,747 | 1,910,700.08 | 13.69 | 3.03 |
| 10 | Midtown North | Manhattan | 69,791 | 1,710,641.15 | 15.28 | 3.30 |

**Insight:** This ranked view confirms the same picture as Q7 — the two airport zones sit far above everything else. This query is essentially a duplicate of Q7 with added rank numbers; it may be worth merging the two in the SQL file to avoid redundant reporting.

---

## Q14. Which zones have high demand but low average tips?

**Result**

| Borough | Zone | Total Pickup Trips | Total Revenue |
|---|---|---:|---:|
| Queens | JFK Airport | 141,090 | 11,180,859.54 |
| Queens | LaGuardia Airport | 80,590 | 5,589,586.13 |
| Manhattan | Midtown Center | 117,617 | 2,959,015.46 |
| Manhattan | Upper East Side South | 134,813 | 2,762,789.50 |
| Manhattan | Upper East Side North | 122,216 | 2,558,471.93 |
| Manhattan | Penn Station/Madison Sq West | 94,077 | 2,350,543.08 |
| Manhattan | Times Sq/Theatre District | 82,995 | 2,322,495.20 |
| Manhattan | Midtown East | 90,668 | 2,223,245.60 |
| Manhattan | Lincoln Square East | 86,747 | 1,910,700.08 |
| Manhattan | Midtown North | 69,791 | 1,710,641.15 |

**Insight:** This result set is actually the same top-revenue list as Q7/Q13, and it doesn't include a tip or tip-rate column, so it doesn't actually answer the question it's meant to answer. To genuinely find "high demand, low tip" zones, the query needs to compute something like average tip per trip or tip-as-percentage of fare, then filter for zones with above-average trip volume but below-average tip rate. Worth revisiting the SQL for this one before publishing.

---

## Q22. How did daily revenue change compared with the previous day?

**Result (notable days)**

| Pickup Date | Weekend | Revenue Today | Revenue Yesterday | Change | % Change | Trend |
|---|:---:|---:|---:|---:|---:|---|
| 2026-01-01 | No | 1,919,346.33 | — | — | — | No prior data |
| 2026-01-20 | No | 2,680,198.57 | 2,095,584.51 | +584,614.06 | +27.90% | Up |
| 2026-01-25 | Yes | 441,649.29 | 2,219,051.87 | −1,777,402.58 | −80.10% | Down |
| 2026-01-26 | No | 1,190,420.09 | 441,649.29 | +748,770.80 | +169.54% | Up |
| 2026-01-27 | No | 2,472,082.14 | 1,190,420.09 | +1,281,662.05 | +107.66% | Up |


**Insight:** Revenue was fairly stable day-to-day (typically ±10%) except for a sharp collapse on January 25, which lines up exactly with the low trip-count anomaly found in Q11. The bounce-back on the 26th and 27th suggests this was a temporary disruption rather than a lasting drop in demand — worth confirming with an external event log for that date.

---

## Q23. What are the top three pickup zones in each borough?

**Result**

| Borough | Zone | Total Pickup Trips | Total Revenue | Avg Tip | Rank |
|---|---|---:|---:|---:|---:|
| Bronx | Co-Op City | 937 | 44,392.03 | 0.02 | 1 |
| Bronx | Williamsbridge/Olinville | 801 | 37,261.59 | 0.09 | 2 |
| Bronx | East Concourse/Concourse Village | 1,057 | 36,582.63 | 0.06 | 3 |
| Brooklyn | East New York | 2,867 | 104,648.47 | 0.08 | 1 |
| Brooklyn | Crown Heights North | 2,415 | 75,728.25 | 0.11 | 2 |
| Brooklyn | Canarsie | 1,692 | 64,443.14 | 0.04 | 3 |
| EWR | Newark Airport | 116 | 12,864.43 | 10.77 | 1 |
| Manhattan | Midtown Center | 117,617 | 2,959,015.46 | 3.38 | 1 |
| Manhattan | Upper East Side South | 134,813 | 2,762,789.50 | 2.79 | 2 |
| Manhattan | Upper East Side North | 122,216 | 2,558,471.93 | 2.88 | 3 |
| Queens | JFK Airport | 141,090 | 11,180,859.54 | 9.00 | 1 |
| Queens | LaGuardia Airport | 80,590 | 5,589,586.13 | 9.40 | 2 |
| Queens | East Elmhurst | 6,472 | 433,161.50 | 8.54 | 3 |
| Staten Island | Bloomfield/Emerson Hill | 11 | 780.71 | 1.68 | 1 |
| Staten Island | Arrochar/Fort Wadsworth | 23 | 589.34 | 0.00 | 2 |
| Staten Island | Westerleigh | 7 | 407.09 | 0.00 | 3 |
| Unknown | (unclassified) | 3,841 | 115,309.67 | 3.94 | 1 |
| (blank) | Outside of NYC | 658 | 57,967.63 | 7.03 | 1 |

**Insight:** The gap between boroughs is stark — Manhattan's top zone alone (117,617 trips) does more volume than all of Staten Island's taxi activity combined many times over. Interestingly, tips scale with trip type, not just borough: Newark Airport (EWR) has by far the highest average tip ($10.77) despite tiny volume, while outer-borough neighborhood zones like the Bronx entries show near-zero tipping ($0.02–$0.09), suggesting those trips are mostly short, local, cash-leaning rides rather than airport or long-distance trips.