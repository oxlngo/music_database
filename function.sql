--1 Find all songfiles played in k-R&B genre
/*
This query retrieves all songfiles that were played and categorized as k-R&B genre. The query uses a subquery to retrieve all track IDs that are associated with the k-R&B genre in the category_of table. The DISTINCT keyword is used to remove duplicate results.
*/
SELECT DISTINCT sf.*
FROM songfile sf
WHERE sf.track_id IN (
    SELECT track_id
    FROM category_of
    WHERE genre_name = 'k-R&B'
) AND sf.track_id IN (
    SELECT track_id
    FROM playhistory
);

--2 Find the songs that have both genres named "k-hiphop" and "k-R&B"
/*
This query retrieves the songs that have both "k-hiphop" and "k-R&B" genres. The query joins the songfile table with the category_of table twice to check for both genres. The INTERSECT keyword is used to retrieve the common results between the two SELECT statements.
*/
SELECT sf.track_id, sf.song_title
FROM songfile sf
INNER JOIN category_of co ON sf.track_id = co.track_id
INNER JOIN genre g ON co.genre_name = g.genre_name
WHERE g.genre_name = 'k-hiphop'
INTERSECT
SELECT sf.track_id, sf.song_title
FROM songfile sf
INNER JOIN category_of co ON sf.track_id = co.track_id
INNER JOIN genre g ON co.genre_name = g.genre_name
WHERE g.genre_name = 'k-R&B';

--3 Retrieve the name of each genre along with the number of unique albums associated with subgenres in that genre (uses LEFT JOINs to include all genres and subgenres)
/*
The query uses a LEFT JOIN to include all genres and subgenres, and then another LEFT JOIN to include all songs and albums associated with each genre. The query groups the results by genre and filters out genres that have less than 3 unique albums.
*/
SELECT g.genre_name, COUNT(DISTINCT a.album_name) AS num_albums
FROM genre g
LEFT JOIN subgenre s ON g.genre_name = s.genre_name
LEFT JOIN category_of c ON g.genre_name = c.genre_name
LEFT JOIN songfile sf ON c.track_id = sf.track_id
LEFT JOIN album a ON sf.album_name = a.album_name
GROUP BY g.genre_name
HAVING COUNT(DISTINCT a.album_name) > 2
ORDER BY COUNT(DISTINCT a.album_name) DESC;

--4 Find the top genre that has been played the most
/*
The query joins the category_of table with the songfile and playhistory tables to retrieve the play count for each genre, and then orders the results by play count in descending order. The LIMIT keyword is used to retrieve only the top result.
*/
SELECT c.genre_name, COUNT(*) as play_count
FROM category_of c
JOIN songfile s ON s.track_id = c.track_id
JOIN playhistory ph ON ph.track_id = s.track_id
GROUP BY c.genre_name
ORDER BY play_count DESC
LIMIT 1;


--5 To find the user(username) who has listened to the most songs
/**
First groups the playhistory table by user_id and counts the number of plays for each user, then orders the result in descending order of num_plays and takes only the top result using the LIMIT clause. Finally, it joins the resulting user_id with the user_profile table to retrieve the username for that user
*/
SELECT u.username, p.num_plays
FROM (
  SELECT user_id, COUNT(*) AS num_plays
  FROM playhistory
  GROUP BY user_id
  ORDER BY num_plays DESC
  LIMIT 1
) p
JOIN user_profile u ON p.user_id = u.user_id;



--6.Find the artist who has the song that has been played the most (popular artist)
/*
joining the playhistory, songfile, and artist tables on their respective IDs
then grouping the results by the artist's name, counting the number of times each artist's songs have been played, and then ordering the results in descending order based on the play count. Finally, the LIMIT clause is used to retrieve only the first result.
*/
SELECT ar.artist_name, COUNT(*) AS play_count
FROM playhistory ph
INNER JOIN songfile sf ON ph.track_id = sf.track_id
INNER JOIN artist ar ON sf.artist_id = ar.artist_id
GROUP BY ar.artist_name
ORDER BY play_count DESC
LIMIT 1;

--7. Find the top 1 of song of March 2023:(top song of the month)
/*
joining the playhistory and songfile tables and filtering the results to only include playdates within March 2023. The query groups the results by song_title and orders them by num_plays in descending order. The LIMIT keyword is used to retrieve only the top result.
*/
SELECT sf.song_title, COUNT(*) AS num_plays
FROM playhistory ph
INNER JOIN songfile sf ON ph.track_id = sf.track_id
WHERE ph.playdate >= '2023-03-01' AND ph.playdate < '2023-04-01'
GROUP BY sf.song_title
ORDER BY num_plays DESC
LIMIT 1;

--8. Retrieve user subscription status and expiration date, as well as the number of days remaining until the subscription expires
/*
joining the playhistory and songfile tables and filtering the results to only include playdates within March 2023. The query groups the results by song_title and orders them by num_plays in descending order. The LIMIT keyword is used to retrieve only the top result.
*/
SELECT s.subscription_id, s.start_date, s.end_date, s.sub_name, 
       CASE 
           WHEN s.end_date IS NULL THEN NULL
           ELSE (s.end_date - current_date) 
       END AS days_remaining
FROM subscription s
INNER JOIN subscription_type st ON s.subscription_id = st.subscription_id
INNER JOIN user_profile u ON st.user_id = u.user_id
WHERE u.username = 'emjo';

--9. Retrieve the top artist who appears in the most number of playlists
/*
it joins four tables: put_in, songfile, artist, and playlist, to get the necessary information about the songs and the playlists they are included in.
It then groups the results by artist name and counts the number of unique playlists that each artist appears in. The results are sorted by the number of playlists in descending order, and the top artist with the most playlists is returned.
*/
SELECT ar.artist_name, COUNT(DISTINCT p.playlist_id) AS playlist_count
FROM put_in pi
INNER JOIN songfile sf ON pi.track_id = sf.track_id
INNER JOIN artist ar ON sf.artist_id = ar.artist_id
INNER JOIN playlist p ON pi.playlist_id = p.playlist_id
GROUP BY ar.artist_name
ORDER BY playlist_count DESC
LIMIT 1;

--10 The list of songs by a specific artist in all playlists
/*
The SELECT statement specifies the columns that will be included in the output: playlist_id, playlist_name, track_id, and artist_name.
The FROM clause specifies the tables that will be used in the query: playlist, put_in, songfile, and artist.
The INNER JOIN clauses join the tables together based on their relationships: playlist is joined with put_in on the playlist_id column, put_in is joined with songfile on the track_id column, and songfile is joined with artist on the artist_id column.
The WHERE clause filters the results to only include songs by the artist 'Zico'.
The ORDER BY clause orders the results by playlist ID.
*/
SELECT pl.playlist_id, pl.playlist_name, sf.track_id, a.artist_name
FROM playlist pl
INNER JOIN put_in pi ON pl.playlist_id = pi.playlist_id
INNER JOIN songfile sf ON pi.track_id = sf.track_id
INNER JOIN artist a ON sf.artist_id = a.artist_id
WHERE a.artist_name = 'Zico'
ORDER BY pl.playlist_id;


--11.Find the top 5 pairs of users who have the most shared tracks in their playlists
/*
This query uses subqueries to count the number of distinct tracks that are shared by each pair of users. It first selects all pairs of users using a cross join (FROM user_profile u1, user_profile u2), and then for each pair of users it counts the number of tracks that appear in both of their playlists. The IN operator is used to check if a track is in the other user's playlist
*/
SELECT u1.username, u2.username, 
       (SELECT COUNT(DISTINCT track_id) 
        FROM put_in pi1 
        JOIN playlist p1 ON pi1.playlist_id = p1.playlist_id 
        JOIN created_by cb1 ON p1.playlist_id = cb1.playlist_id 
        WHERE cb1.user_id = u1.user_id 
          AND track_id IN 
              (SELECT track_id 
               FROM put_in pi2 
               JOIN playlist p2 ON pi2.playlist_id = p2.playlist_id 
               JOIN created_by cb2 ON p2.playlist_id = cb2.playlist_id 
               WHERE cb2.user_id = u2.user_id)) AS num_shared_tracks
FROM user_profile u1, user_profile u2
WHERE u1.username < u2.username
ORDER BY num_shared_tracks DESC
LIMIT 5;




--12. To find the all song have never been played
/*
using a subquery with the NOT EXISTS operator, which checks if there is no record in the playhistory table that matches the current songfile track_id.
The main query selects the track_id and song_title columns from the songfile table. Then, it uses the subquery to filter out the songs that have been played before, by checking if there is no record in the playhistory table with a matching track_id.
*/
SELECT sf.track_id, sf.song_title
FROM songfile sf
WHERE NOT EXISTS (
  SELECT 1 
  FROM playhistory ph 
  WHERE sf.track_id = ph.track_id
);

--13 To find the user who has the most playlists and also count the total number of track IDs in these playlists
/*
join the user_profile table with the created_by table on the user_id column, and then joining the resulting table with a subquery that aggregates the number of track IDs in each playlist using the put_in table. The query then groups the result by user_id and calculates the count of playlists and the sum of track IDs for each user. Finally, the result is sorted in descending order by playlist count and total tracks, and limited to the first row to retrieve the user with the most playlists.
*/
SELECT u.user_id, u.username, COUNT(*) AS playlist_count, SUM(p.track_count) AS total_tracks
FROM user_profile u
INNER JOIN created_by c ON u.user_id = c.user_id
INNER JOIN (
    SELECT playlist_id, COUNT(*) AS track_count
    FROM put_in
    GROUP BY playlist_id
) p ON c.playlist_id = p.playlist_id
GROUP BY u.user_id
ORDER BY playlist_count DESC, total_tracks DESC
LIMIT 1;

--14.Find all artists who have recorded at least three album and these artist have age below 40
/*
first selecting the artist's name and age from the "artist" table. Then, it filters the results by selecting only the artists whose age is below 40 and who have recorded at least three albums. The subquery in the WHERE clause counts the number of albums recorded by each artist by joining the "album" table on the artist ID and counting the number of rows. If the count is greater than or equal to 3, then the artist is included in the result set.
*/
SELECT artist.artist_name, artist.age 
FROM artist 
WHERE artist.age < 40 
AND (SELECT COUNT(*) 
	 FROM album 
	 WHERE album.artist_id = artist.artist_id) >= 2;

--15.To find the most common device type used for playback
/*
joining the playhistory table with the playbackdevice table on the device_id column, and grouping the results by type of the device. Then it sorts the results by the number of plays for each type in descending order, and selects only the first result
*/
SELECT d.type, COUNT(*) AS num_plays
FROM playhistory ph
INNER JOIN playbackdevice d ON ph.device_id = d.device_id
GROUP BY d.type
ORDER BY num_plays DESC
LIMIT 1;



