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

-- Query 4: Find transit stops
-- Find general stop name, location, and arrival time
SELECT s.stop_id, s.stop_name, s.stop_lat, s.stop_lon, st.arrival_time
FROM `bigquery-public-data.san_francisco_transit_muni.stops` s
JOIN `bigquery-public-data.san_francisco_transit_muni.stop_times` st ON s.stop_id = CAST(st.stop_id AS STRING)
JOIN `bigquery-public-data.san_francisco_transit_muni.trips` t ON CAST(st.trip_id AS STRING) = t.trip_id
LIMIT 100

-- Query 5: To find routes serving specific route
-- Used for query 6
SELECT DISTINCT r.route_id, r.route_short_name, r.route_long_name
FROM `bigquery-public-data.san_francisco_transit_muni.routes` r
JOIN `bigquery-public-data.san_francisco_transit_muni.trips` t ON r.route_id = t.route_id
JOIN `bigquery-public-data.san_francisco_transit_muni.stop_times` st ON t.trip_id = CAST(st.trip_id AS STRING)
JOIN `bigquery-public-data.san_francisco_transit_muni.stops` s ON CAST(st.stop_id AS STRING) = s.stop_id
WHERE s.stop_name = '101 Dakota St' -- Replace with the route you are interested in
ORDER BY r.route_short_name
LIMIT 15;

-- Query 6: Schedule for '101 Dakota St' on route '10'
-- Schedule for a specific stop ('101 Dakota St') on a specific route ('10'): This gives you the arrival and departure times at a key station for a specific route, good for users planning to use that route.
SELECT t.route_id, s.stop_name, st.arrival_time, st.departure_time
FROM `bigquery-public-data.san_francisco_transit_muni.stop_times` st
JOIN `bigquery-public-data.san_francisco_transit_muni.stops` s ON CAST(st.stop_id AS STRING) = s.stop_id
JOIN `bigquery-public-data.san_francisco_transit_muni.trips` t ON CAST(st.trip_id AS STRING) = t.trip_id
JOIN `bigquery-public-data.san_francisco_transit_muni.routes` r ON t.route_id = r.route_id
WHERE s.stop_name = '101 Dakota St' AND r.route_short_name = '10'  -- Replace '10' and '101 Dakota St' as needed
ORDER BY st.arrival_time
LIMIT 25;