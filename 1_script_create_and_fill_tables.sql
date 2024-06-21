create table genres (id serial primary key,
                     genr_name varchar(50) not null
                     );
insert into genres select * from (select 1 as id, 'Rock' as genr_name
                                  union all
                                  select 2, 'Rap'
                                  union all
                                  select 3, 'Funk'
                                  ) as sq_genres;
create table artists (id serial primary key,
                      artist_name varchar(50) not null
                      );
insert into artists select * from (select 1 as id, 'Kid Rock' as artist_name
                                   union all
                                   select 2, 'Eminem'
                                   union all
                                   select 3, 'Planet Funk'
                                   ) as artists;
create table genr_2_artist (genr_id integer not null references genres(id),
                            artist_id integer not null references artists(id),
                            unique (genr_id, artist_id)
                            );
insert into genr_2_artist select * from (select 1 as genr_id, 1 as artist_id
                                         union all
                                         select 2, 1
                                         union all
                                         select 2, 2
                                         union all
                                         select 3, 3
                                         ) as sq_genr_2_artist;
create table albums (id serial primary key, 
                     album_name varchar(128) not null,
                     album_year varchar(4) not null
                     );
create table artist_2_album (artist_id integer references artists(id),
                             album_id integer references albums(id),
                             unique (artist_id, album_id)
                             );
insert into albums select * from (select 1 as id,
                                         'YEAH!!!' as album_name,
                                         to_char(current_date, 'yyyy') as album_year
                                  union all
                                  select 2, 'NO!!!', to_char(current_date - 365, 'yyyy')
                                  union all
                                  select 3, 'DONTKNOW!!!', to_char(current_date - 730, 'yyyy')
                                  union all
                                  select 4, 'MY WAY!!!', to_char(current_date, 'yyyy')
                                  union all
                                  select 5, 'YOUR WAY!!!', to_char(current_date - 365 * 5, 'yyyy')
                                  union all
                                  select 6, 'SUB WAY!!!', to_char(current_date - 730, 'yyyy')
                                  union all
                                  select 7, 'CHASE THE SUN!!!', to_char(current_date, 'yyyy')
                                  union all
                                  select 8, 'CHASE THE MOON!!!', to_char(current_date - 365 * 7, 'yyyy')
                                  union all
                                  select 9, 'CHASE THE F*CK OUT OF HERE!!!', to_char(current_date - 730, 'yyyy')
                                  ) as sq_albums;
insert into artist_2_album select * from (select
                                            gs1 as artist_id,
                                            (3 * gs2) + gs1 as album_id
                                          from generate_series(1, 3) gs1,
                                               generate_series(0, 2) gs2
                                          ) as sq_artist_2_album;
create table tracks (id serial primary key, 
                     album_id integer references albums(id),
                     track_name varchar(128) not null,
                     track_length interval not null
                     );
do $$declare
  track_id_seq integer := 1;
  i albums.id%type;
  j integer;
begin
  for i in select id from albums
  loop
    for j in 1 .. 12
    loop
      insert into tracks values (track_id_seq,
                                 i,
                                 substring(array_to_string(ARRAY(SELECT chr((65 + round((random() * 25 + generate_series)
                                                                        :: integer % 25 )) :: integer)
                                                           FROM generate_series(1, 60)), ''), 0, 7) || '_' || j,
                                 interval '1 minute' * (random() * (10 - 1) + 1)
                                );
      track_id_seq := track_id_seq + 1;
    end loop;
  end loop;
  commit;
end$$;
create table compilation_albums (id serial primary key, 
                                 comp_name varchar(128) not null,
                                 comp_year varchar(4) not null
                                 );
insert into compilation_albums select generate_series as id,
                                      'Compilation album №' || generate_series as comp_name,
                                      to_char(current_date - 450 * generate_series, 'yyyy') as comp_year
                               from generate_series(1, 4);
create table compilation_tracks (comp_alb_id integer references compilation_albums(id), 
                                 track_id integer references tracks(id),
                                 unique (comp_alb_id, track_id)
                                 );
insert into compilation_tracks select * from (select generate_series as comp_alb_id,
                                                     id as track_id
                                              from generate_series(1, 4),
                                                   tracks
                                              where random() < 0.2
                                              ) as sq_compilation_tracks;
commit;
