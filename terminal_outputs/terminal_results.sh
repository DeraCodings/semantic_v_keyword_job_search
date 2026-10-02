PS C:\Users\USER\Desktop\Client works\Percona Writer's Program\semantic-job-search\docker> docker compose --env-file docker-composer.env up -d
time="2026-09-26T15:59:59+01:00" level=warning msg="C:\\Users\\USER\\Desktop\\Client works\\Percona Writer's Program\\semantic-job-search\\docker\\docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion"
service "postgres" refers to undefined volume postgres_data: invalid compose project
PS C:\Users\USER\Desktop\Client works\Percona Writer's Program\semantic-job-search\docker> docker compose --env-file docker-composer.env up -d
unable to get image 'postgres:18': error during connect: Get "http://%2F%2F.%2Fpipe%2FdockerDesktopLinuxEngine/v1.47/images/postgres:18/json": open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified.
PS C:\Users\USER\Desktop\Client works\Percona Writer's Program\semantic-job-search\docker> docker compose --env-file docker-composer.env up -d
unable to get image 'postgres:latest': error during connect: Get "http://%2F%2F.%2Fpipe%2FdockerDesktopLinuxEngine/v1.47/images/postgres:latest/json": open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified.
PS C:\Users\USER\Desktop\Client works\Percona Writer's Program\semantic-job-search\docker> docker compose --env-file docker-composer.env up -d
[+] up 19/19
 ✔ Image percona/percona-distribution-postgresql:18.6 Pulled                                                                                                    425.3s
 ✔ Network docker_default                             Created                                                                                                     0.3s
 ✔ Volume docker_postgres_data                        Created                                                                                                     0.1s
 ✔ Container job_search                               Started                                                                                                    19.1s
PS C:\Users\USER\Desktop\Client works\Percona Writer's Program\semantic-job-search\docker> docker exec -it job_search psql -U postgres
psql: error: connection to server on socket "/run/postgresql/.s.PGSQL.5432" failed: FATAL:  role "postgres" does not exist

What's next:
    Try Docker Debug for seamless, persistent debugging tools in any container or image → docker debug job_search
    Learn more at https://docs.docker.com/go/debug-cli/
PS C:\Users\USER\Desktop\Client works\Percona Writer's Program\semantic-job-search\docker> docker exec -it job_search psql -U admin
psql: error: connection to server on socket "/run/postgresql/.s.PGSQL.5432" failed: FATAL:  database "admin" does not exist

What's next:
    Try Docker Debug for seamless, persistent debugging tools in any container or image → docker debug job_search
    Learn more at https://docs.docker.com/go/debug-cli/
PS C:\Users\USER\Desktop\Client works\Percona Writer's Program\semantic-job-search\docker> docker exec -it job_search psql -U postgres -d job_search
psql: error: connection to server on socket "/run/postgresql/.s.PGSQL.5432" failed: FATAL:  role "postgres" does not exist

What's next:
    Try Docker Debug for seamless, persistent debugging tools in any container or image → docker debug job_search
    Learn more at https://docs.docker.com/go/debug-cli/
PS C:\Users\USER\Desktop\Client works\Percona Writer's Program\semantic-job-search\docker> docker exec -it job_search psql -U admin -d job_search
psql (18.6 - Percona Server for PostgreSQL 18.6.1)
Type "help" for help.

job_search=# CREATE EXTENSION vector
job_search-# \dt
Did not find any tables.
job_search-# CREATE TABLE jobs (id BIGSERIAL PRIMARY KEY, title TEXT NOT NULL, company TEXT NOT NULL, description TEXT NOT NULL, location TEXT, url TEXT NOT NULL UNIQUE, skills TEXT[], created_at TIMESTAMPTZ DEFAULT NOW(), embedding vector(384));
ERROR:  syntax error at or near "CREATE"
LINE 2: CREATE TABLE jobs (id BIGSERIAL PRIMARY KEY, title TEXT NOT ...
        ^
job_search=# CREATE TABLE jobs (id BIGSERIAL PRIMARY KEY, title TEXT NOT NULL, company TEXT NOT NULL, description TEXT NOT NULL, location TEXT, url TEXT NOT NULL UNIQUE, skills TEXT[], created_at TIMESTAMPTZ DEFAULT NOW(), embedding vector(384));
ERROR:  type "vector" does not exist
LINE 1: ..., created_at TIMESTAMPTZ DEFAULT NOW(), embedding vector(384...
                                                             ^
job_search=# \dx
                          List of installed extensions
  Name   | Version | Default version |   Schema   |         Description
---------+---------+-----------------+------------+------------------------------
 plpgsql | 1.0     | 1.0             | pg_catalog | PL/pgSQL procedural language
(1 row)

job_search=# \q

What's next:
    Try Docker Debug for seamless, persistent debugging tools in any container or image → docker debug job_search
    Learn more at https://docs.docker.com/go/debug-cli/
PS C:\Users\USER\Desktop\Client works\Percona Writer's Program\semantic-job-search\docker> docker exec -it job_search psql -U admin -d job_search
psql (18.6 - Percona Server for PostgreSQL 18.6.1)
Type "help" for help.

job_search=# CREATE EXTENSION vector;
CREATE EXTENSION
job_search=# \dx
                                      List of installed extensions
  Name   | Version | Default version |   Schema   |                     Description
---------+---------+-----------------+------------+------------------------------------------------------
 plpgsql | 1.0     | 1.0             | pg_catalog | PL/pgSQL procedural language
 vector  | 0.8.6   | 0.8.6           | public     | vector data type and ivfflat and hnsw access methods
(2 rows)

job_search=# CREATE TABLE jobs (id BIGSERIAL PRIMARY KEY, title TEXT NOT NULL, company TEXT NOT NULL, description TEXT NOT NULL, location TEXT, url TEXT NOT NULL UNIQUE, skills TEXT[], created_at TIMESTAMPTZ DEFAULT NOW(), embedding vector(384));
CREATE TABLE
job_search=# \dx
                                      List of installed extensions
  Name   | Version | Default version |   Schema   |                     Description
---------+---------+-----------------+------------+------------------------------------------------------
 plpgsql | 1.0     | 1.0             | pg_catalog | PL/pgSQL procedural language
 vector  | 0.8.6   | 0.8.6           | public     | vector data type and ivfflat and hnsw access methods
(2 rows)

job_search=# \dt
        List of tables
 Schema | Name | Type  | Owner
--------+------+-------+-------
 public | jobs | table | admin
(1 row)

job_search=# ALTER TABLE jobs ADD COLUMN search_vector tsvector GENERATED ALWAYS AS (to_tsvector('english', coalesce(title, '') || ' ' || coalesce(description, '') || ' ' || coalesce(array_to_string(skills, ' '), ''))) STORED;
ERROR:  generation expression is not immutable
job_search=# CREATE OR REPLACE FUNCTION immutable_array_to_string(arr text[], sep text) RETURNS text LANGUAGE sql IMMUTABLE AS $$ SELECT array_to_string(arr, sep); $$;
CREATE FUNCTION
job_search=# ALTER TABLE jobs ADD COLUMN search_vector tsvector GENERATED ALWAYS AS (to_tsvector('english', coalesce(title, '') || ' ' || coalesce(description, '') || ' ' || coalesce(immutable_array_to_string(skills, ' '), ''))) STORED;
ALTER TABLE
job_search=# CREATE INDEX jobs_search_vector_idx ON jobs USING GIN (search_vector);
CREATE INDEX
job_search=# \di jobs_search_vector_idx
                     List of indexes
 Schema |          Name          | Type  | Owner | Table
--------+------------------------+-------+-------+-------
 public | jobs_search_vector_idx | index | admin | jobs
(1 row)

job_search=# \d jobs
                                                                                                                                        Table "public.jobs"
    Column     |           Type           | Collation | Nullable |
         Default
---------------+--------------------------+-----------+----------+----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
 id            | bigint                   |           | not null | nextval('jobs_id_seq'::regclass)
 title         | text                     |           | not null |
 company       | text                     |           | not null |
 description   | text                     |           | not null |
 location      | text                     |           |          |
 url           | text                     |           | not null |
 skills        | text[]                   |           |          |
 created_at    | timestamp with time zone |           |          | now()
 embedding     | vector(384)              |           |          |
 search_vector | tsvector                 |           |          | generated always as (to_tsvector('english'::regconfig, (((COALESCE(title, ''::text) || ' '::text) |
| COALESCE(description, ''::text)) || ' '::text) || COALESCE(immutable_array_to_string(skills, ' '::text), ''::text))) stored
Indexes:
    "jobs_pkey" PRIMARY KEY, btree (id)
    "jobs_search_vector_idx" gin (search_vector)
    "jobs_url_key" UNIQUE CONSTRAINT, btree (url)

job_search=# \q

What's next:
    Try Docker Debug for seamless, persistent debugging tools in any container or image → docker debug job_search
    Learn more at https://docs.docker.com/go/debug-cli/
PS C:\Users\USER\Desktop\Client works\Percona Writer's Program\semantic-job-search\docker>