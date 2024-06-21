
-- 2.1 Название и продолжительность самого длительного трека.
-- a)
WITH t AS (
	SELECT
		DENSE_RANK() OVER (
		ORDER BY
			track_length DESC
		) AS r,
		track_name,
		track_length
	FROM
		tracks
)
SELECT
	*
FROM
	t
WHERE
	r = 1;

-- b)
SELECT
	track_name,
	track_length
FROM
	tracks
WHERE
	track_length = (
		SELECT
			max(track_length)
		FROM
			tracks
	)

-- 2.2 Название треков, продолжительность которых не менее 3,5 минут.
SELECT
	track_name,
	track_length
FROM
	tracks
WHERE
	track_length >= INTERVAL '3 minutes 30 seconds';


-- 2.3 Названия сборников, вышедших в период с 2018 по 2020 год включительно.
SELECT
	*
FROM
	compilation_albums ca
WHERE
	comp_year::NUMERIC BETWEEN 2018 AND 2020;


-- 2.4 Исполнители, чьё имя состоит из одного слова.
SELECT
	*
FROM
	artists
WHERE
	-- a)
		POSITION(' ' IN artist_name) = 0
	AND POSITION('-' IN artist_name) = 0
	-- b)
	AND strpos(artist_name, ' ') = 0
	AND strpos(artist_name, '-') = 0
	-- c)
	AND artist_name !~ '[ -]'
	-- в)
	AND split_part(artist_name, ' ', 1) = artist_name
	AND split_part(artist_name, '-', 1) = artist_name
	-- ...
   ;


-- 2.5 Название треков, которые содержат слово «мой» или «my».
SELECT
    track_name
FROM
    tracks
WHERE
    track_name LIKE '%мой %'
    OR track_name LIKE '%my %';

   

-- 3.1 Количество исполнителей в каждом жанре.
SELECT
	genr_name,
	count(*) AS quantity
FROM
	artists a,
	genr_2_artist,
	genres g
WHERE
	a.id = artist_id
	AND genr_id = g.id
GROUP BY
	genr_name;
   
-- 3.2 Количество треков, вошедших в альбомы 2019–2020 годов.
SELECT
	album_name,
	(
		SELECT
			count(*)
		FROM
			tracks t
		WHERE
			t.album_id = a.id
	) AS tracks_qtty
FROM
	albums a
WHERE
	album_year::NUMERIC BETWEEN 2019 AND 2020;

-- 3.3 Средняя продолжительность треков по каждому альбому.
SELECT
	album_name,
	avg(track_length) AS avg_tl
FROM
	albums a,
	tracks t
WHERE
	a.id = t.album_id
GROUP BY
	album_name

-- 3.4 Все исполнители, которые не выпустили альбомы в 2020 году.
SELECT
	*
FROM
	artists ar
WHERE
	NOT EXISTS(
		SELECT
			1
		FROM
			albums al,
			artist_2_album aa
		WHERE
			aa.artist_id = ar.id
			AND al.id = aa.album_id
			AND al.album_year = '2020'
	);

-- 3.5 Названия сборников, в которых присутствует конкретный исполнитель (выберите его сами).
WITH t AS (
	SELECT
		id
	FROM
		artists
	WHERE
		lower(artist_name) LIKE '%planet%' -- тхе наме оф дэ артист
)
SELECT
	ca.comp_name
FROM
	compilation_albums ca
WHERE
	EXISTS(
		SELECT
			1
		FROM
			compilation_tracks,
			tracks tr,
			artists a,
			artist_2_album a2a,
			t
		WHERE
			ca.id = comp_alb_id
			AND tr.id = track_id
			AND tr.album_id = a2a.album_id
			AND a.id = a2a.artist_id
			AND t.id = a.id
	);

-- 4.1 Названия альбомов, в которых присутствуют исполнители более чем одного жанра.
SELECT
	ca.comp_name
FROM
	compilation_albums ca
WHERE
	(
		SELECT
			count(DISTINCT ga.genr_id)
		FROM
			genr_2_artist ga,
			artist_2_album aa,
			compilation_tracks ct, 
			tracks t
		WHERE
			ga.artist_id = aa.artist_id
			AND aa.album_id = t.album_id
			AND ct.comp_alb_id = aa.album_id
			AND ct.track_id = t.id
	) > 1;


-- Наименования треков, которые не входят в сборники.
SELECT
	track_name
FROM
	tracks
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			compilation_tracks
		WHERE
			track_id = id
	);

-- Исполнитель или исполнители, написавшие самый короткий по продолжительности трек, — теоретически таких треков может быть несколько.
WITH t AS (
	SELECT
		t.album_id ,
		t.track_name, 
		t.track_length,
		DENSE_RANK() OVER (
		ORDER BY
			t.track_length
		) AS length_rank
	FROM
		tracks t
)
SELECT
	a.artist_name,
	t.track_name,
	t.track_length
FROM
	artists a,
	artist_2_album a2a,
	t
WHERE
	a.id = a2a.artist_id
	AND t.album_id = a2a.album_id
	AND length_rank = 1;

-- Названия альбомов, содержащих наименьшее количество треков.
WITH t AS (
	SELECT
		album_name,
		DENSE_RANK() OVER (
		ORDER BY
			count(*)
		) AS tr_qtty_cnt
	FROM
		albums a,
		tracks t
	WHERE
		a.id = t.album_id
	GROUP BY
		album_name
)
SELECT
	*
FROM
	t
WHERE
	tr_qtty_cnt = 1;
