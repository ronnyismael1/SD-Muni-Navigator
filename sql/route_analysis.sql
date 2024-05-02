-- Query 1: List routes
-- List of all routes: This will give you a general overview of the transit routes available in the dataset, useful for any further analysis of application needs.
SELECT route_id, route_short_name, route_long_name, route_type
FROM `bigquery-public-data.san_francisco_transit_muni.routes`
LIMIT 100;

-- Query 2: Create a table of connected stop pairs
-- Find all pairs of connected stops along with route information
SELECT
  t.route_id,
  t.trip_id,
  st1.stop_id AS start_stop_id,
  s1.stop_name AS start_stop_name,
  st1.stop_sequence AS start_sequence,
  st2.stop_id AS end_stop_id,
  s2.stop_name AS end_stop_name,
  st2.stop_sequence AS end_sequence
FROM `bigquery-public-data.san_francisco_transit_muni.trips` t
JOIN `bigquery-public-data.san_francisco_transit_muni.stop_times` st1 ON t.trip_id = CAST(st1.trip_id AS STRING)
JOIN `bigquery-public-data.san_francisco_transit_muni.stops` s1 ON CAST(st1.stop_id AS STRING) = s1.stop_id
JOIN `bigquery-public-data.san_francisco_transit_muni.stop_times` st2 ON t.trip_id = CAST(st2.trip_id AS STRING)
JOIN `bigquery-public-data.san_francisco_transit_muni.stops` s2 ON CAST(st2.stop_id AS STRING) = s2.stop_id
WHERE st1.stop_sequence < st2.stop_sequence
ORDER BY t.route_id, t.trip_id, st1.stop_sequence, st2.stop_sequence
LIMIT 10;



-- Query 3: Trips between 'Clay St & Drumm St' and 'Sacramento St & Davis St'
-- Trips between two specified stops: This  query calculates possible trips that connect two stops, showing the earliest arrival and latest departure times, which helps in planning a trip from one point to another within the city efficiently.
SELECT t.route_id, t.trip_headsign, MIN(st.arrival_time) AS start_time, MAX(st2.departure_time) AS end_time
FROM `bigquery-public-data.san_francisco_transit_muni.trips` t
JOIN `bigquery-public-data.san_francisco_transit_muni.stop_times` st ON t.trip_id = CAST(st.trip_id AS STRING)
JOIN `bigquery-public-data.san_francisco_transit_muni.stop_times` st2 ON t.trip_id = CAST(st2.trip_id AS STRING)
WHERE CAST(st.stop_id AS STRING) IN (SELECT stop_id FROM `bigquery-public-data.san_francisco_transit_muni.stops` WHERE stop_name = 'Clay St & Drumm St')
  AND CAST(st2.stop_id AS STRING) IN (SELECT stop_id FROM `bigquery-public-data.san_francisco_transit_muni.stops` WHERE stop_name = 'Sacramento St & Davis St')
  AND st.stop_sequence < st2.stop_sequence
GROUP BY t.route_id, t.trip_headsign
ORDER BY start_time
LIMIT 30;