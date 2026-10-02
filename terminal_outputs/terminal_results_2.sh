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
PS C:\Users\USER\Desktop\Client works\Percona Writer's Program\semantic-job-search\docker> docker exec -it job_search psql -U postgres -d job_search
psql: error: connection to server on socket "/run/postgresql/.s.PGSQL.5432" failed: FATAL:  role "postgres" does not exist

What's next:
    Try Docker Debug for seamless, persistent debugging tools in any container or image → docker debug job_search
    Learn more at https://docs.docker.com/go/debug-cli/
PS C:\Users\USER\Desktop\Client works\Percona Writer's Program\semantic-job-search\docker> docker exec -it job_search psql -U admin -d job_search
psql (18.6 - Percona Server for PostgreSQL 18.6.1)
Type "help" for help.

job_search=# \dt
        List of tables
 Schema | Name | Type  | Owner
--------+------+-------+-------
 public | jobs | table | admin
(1 row)

job_search=# \dx
                                      List of installed extensions
  Name   | Version | Default version |   Schema   |                     Description
---------+---------+-----------------+------------+------------------------------------------------------
 plpgsql | 1.0     | 1.0             | pg_catalog | PL/pgSQL procedural language
 vector  | 0.8.6   | 0.8.6           | public     | vector data type and ivfflat and hnsw access methods
(2 rows)

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

job_search=# ALTER TABLE jobs DROP COLUMN embedding;
ALTER TABLE
job_search=# ALTER TABLE jobs ADD COLUMN embedding vector(1024);
ALTER TABLE
job_search=# /d jobs
job_search-# \d jobs
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
 search_vector | tsvector                 |           |          | generated always as (to_tsvector('english'::regconfig, (((COALESCE(title, ''::text) || ' '::text) |
| COALESCE(description, ''::text)) || ' '::text) || COALESCE(immutable_array_to_string(skills, ' '::text), ''::text))) stored
 embedding     | vector(1024)             |           |          |
Indexes:
    "jobs_pkey" PRIMARY KEY, btree (id)
    "jobs_search_vector_idx" gin (search_vector)
    "jobs_url_key" UNIQUE CONSTRAINT, btree (url)

job_search-# \d jobs
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
 search_vector | tsvector                 |           |          | generated always as (to_tsvector('english'::regconfig, (((COALESCE(title, ''::text) || ' '::text) |
| COALESCE(description, ''::text)) || ' '::text) || COALESCE(immutable_array_to_string(skills, ' '::text), ''::text))) stored
 embedding     | vector(1024)             |           |          |
Indexes:
    "jobs_pkey" PRIMARY KEY, btree (id)
    "jobs_search_vector_idx" gin (search_vector)
    "jobs_url_key" UNIQUE CONSTRAINT, btree (url)

job_search-# \help
Available help:
  ABORT                            CLOSE                            CREATE VIEW                      DROP USER MAPPING
  ALTER AGGREGATE                  CLUSTER                          DEALLOCATE                       DROP VIEW
  ALTER COLLATION                  COMMENT                          DECLARE                          END
  ALTER CONVERSION                 COMMIT                           DELETE                           EXECUTE
  ALTER DATABASE                   COMMIT PREPARED                  DISCARD                          EXPLAIN
  ALTER DEFAULT PRIVILEGES         COPY                             DO                               FETCH
  ALTER DOMAIN                     CREATE ACCESS METHOD             DROP ACCESS METHOD               GRANT
  ALTER EVENT TRIGGER              CREATE AGGREGATE                 DROP AGGREGATE                   IMPORT FOREIGN SCHEMA
  ALTER EXTENSION                  CREATE CAST                      DROP CAST                        INSERT
  ALTER FOREIGN DATA WRAPPER       CREATE COLLATION                 DROP COLLATION                   LISTEN
  ALTER FOREIGN TABLE              CREATE CONVERSION                DROP CONVERSION                  LOAD
  ALTER FUNCTION                   CREATE DATABASE                  DROP DATABASE                    LOCK
  ALTER GROUP                      CREATE DOMAIN                    DROP DOMAIN                      MERGE
  ALTER INDEX                      CREATE EVENT TRIGGER             DROP EVENT TRIGGER               MOVE
  ALTER LANGUAGE                   CREATE EXTENSION                 DROP EXTENSION                   NOTIFY
  ALTER LARGE OBJECT               CREATE FOREIGN DATA WRAPPER      DROP FOREIGN DATA WRAPPER        PREPARE
  ALTER MATERIALIZED VIEW          CREATE FOREIGN TABLE             DROP FOREIGN TABLE               PREPARE TRANSACTION
  ALTER OPERATOR                   CREATE FUNCTION                  DROP FUNCTION                    REASSIGN OWNED
  ALTER OPERATOR CLASS             CREATE GROUP                     DROP GROUP                       REFRESH MATERIALIZED VIEW
  ALTER OPERATOR FAMILY            CREATE INDEX                     DROP INDEX                       REINDEX
  ALTER POLICY                     CREATE LANGUAGE                  DROP LANGUAGE                    RELEASE SAVEPOINT
  ALTER PROCEDURE                  CREATE MATERIALIZED VIEW         DROP MATERIALIZED VIEW           RESET
  ALTER PUBLICATION                CREATE OPERATOR                  DROP OPERATOR                    REVOKE
  ALTER ROLE                       CREATE OPERATOR CLASS            DROP OPERATOR CLASS              ROLLBACK
  ALTER ROUTINE                    CREATE OPERATOR FAMILY           DROP OPERATOR FAMILY             ROLLBACK PREPARED
  ALTER RULE                       CREATE POLICY                    DROP OWNED                       ROLLBACK TO SAVEPOINT
  ALTER SCHEMA                     CREATE PROCEDURE                 DROP POLICY                      SAVEPOINT
  ALTER SEQUENCE                   CREATE PUBLICATION               DROP PROCEDURE                   SECURITY LABEL
  ALTER SERVER                     CREATE ROLE                      DROP PUBLICATION                 SELECT
  ALTER STATISTICS                 CREATE RULE                      DROP ROLE                        SELECT INTO
  ALTER SUBSCRIPTION               CREATE SCHEMA                    DROP ROUTINE                     SET
  ALTER SYSTEM                     CREATE SEQUENCE                  DROP RULE                        SET CONSTRAINTS
  ALTER TABLE                      CREATE SERVER                    DROP SCHEMA                      SET ROLE
  ALTER TABLESPACE                 CREATE STATISTICS                DROP SEQUENCE                    SET SESSION AUTHORIZATION
  ALTER TEXT SEARCH CONFIGURATION  CREATE SUBSCRIPTION              DROP SERVER                      SET TRANSACTION
  ALTER TEXT SEARCH DICTIONARY     CREATE TABLE                     DROP STATISTICS                  SHOW
  ALTER TEXT SEARCH PARSER         CREATE TABLE AS                  DROP SUBSCRIPTION                START TRANSACTION
  ALTER TEXT SEARCH TEMPLATE       CREATE TABLESPACE                DROP TABLE                       TABLE
  ALTER TRIGGER                    CREATE TEXT SEARCH CONFIGURATION DROP TABLESPACE                  TRUNCATE
  ALTER TYPE                       CREATE TEXT SEARCH DICTIONARY    DROP TEXT SEARCH CONFIGURATION   UNLISTEN
  ALTER USER                       CREATE TEXT SEARCH PARSER        DROP TEXT SEARCH DICTIONARY      UPDATE
  ALTER USER MAPPING               CREATE TEXT SEARCH TEMPLATE      DROP TEXT SEARCH PARSER          VACUUM
  ALTER VIEW                       CREATE TRANSFORM                 DROP TEXT SEARCH TEMPLATE        VALUES
  ANALYZE                          CREATE TRIGGER                   DROP TRANSFORM                   WITH
  BEGIN                            CREATE TYPE                      DROP TRIGGER
  CALL                             CREATE USER                      DROP TYPE
  CHECKPOINT                       CREATE USER MAPPING              DROP USER
job_search-#
job_search-#
job_search-#
job_search-#
job_search-#
job_search-# SELECT id, title, company FROM jobs;
ERROR:  syntax error at or near "/"
LINE 1: /d jobs
        ^
job_search=# SELECT id, title, company, location, created_at FROM jobs LIMIT 10;
 id |         title          | company  | location |          created_at
----+------------------------+----------+----------+-------------------------------
  1 | Job Posting - percona  | PERCONA  | Remote   | 2026-09-27 06:06:53.960358+00
  2 | Job Posting - supabase | SUPABASE | Remote   | 2026-09-27 06:08:09.754686+00
(2 rows)

job_search=# SELECT description FROM jobs LIMIT 10
job_search-# \x
Expanded display is on.
job_search-# SELECT * FROM jobs LIMIT 5;
ERROR:  syntax error at or near "SELECT"
LINE 2: SELECT * FROM jobs LIMIT 5;
        ^
job_search=# SELECT * FROM jobs LIMIT 5;
-[ RECORD 1 ]-+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
id            | 1
title         | Job Posting - percona
company       | PERCONA
description   | Page not found Page not found The job board you were viewing is no longer active.
location      | Remote
url           | https://boards.greenhouse.io/percona/jobs/101
skills        | {PostgreSQL,Database,SQL,Linux,Replication,"Performance Tuning"}
created_at    | 2026-09-27 06:06:53.960358+00
search_vector | 'activ':19 'board':12 'databas':21 'found':6,9 'job':1,11 'linux':23 'longer':18 'page':4,7 'percona':3 'perform':25 'post':2 'postgresql':20 'replic':24 'sql':22 'tune':26 'view':15
embedding     |
-[ RECORD 2 ]-+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
id            | 2
title         | Job Posting - supabase
company       | SUPABASE
description   | Error Cannot GET /supabase/jobs/102
location      | Remote
url           | https://jobs.lever.co/supabase/jobs/102
skills        | {PostgreSQL,Database,SQL,Linux,Replication,"Performance Tuning"}
created_at    | 2026-09-27 06:08:09.754686+00
search_vector | '/supabase/jobs/102':7 'cannot':5 'databas':9 'error':4 'get':6 'job':1 'linux':11 'perform':13 'post':2 'postgresql':8 'replic':12 'sql':10 'supabas':3 'tune':14
embedding     |

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
 search_vector | tsvector                 |           |          | generated always as (to_tsvector('english'::regconfig, (((COALESCE(title, ''::text) || ' '::text) |
| COALESCE(description, ''::text)) || ' '::text) || COALESCE(immutable_array_to_string(skills, ' '::text), ''::text))) stored
 embedding     | vector(1024)             |           |          |
Indexes:
    "jobs_pkey" PRIMARY KEY, btree (id)
    "jobs_search_vector_idx" gin (search_vector)
    "jobs_url_key" UNIQUE CONSTRAINT, btree (url)

job_search=# SELECT id, title, company, location, created_at FROM jobs LIMIT 10;
-[ RECORD 1 ]-----------------------------
id         | 1
title      | Job Posting - percona
company    | PERCONA
location   | Remote
created_at | 2026-09-27 06:06:53.960358+00
-[ RECORD 2 ]-----------------------------
id         | 2
title      | Job Posting - supabase
company    | SUPABASE
location   | Remote
created_at | 2026-09-27 06:08:09.754686+00

job_search=# SELECT * FROM jobs LIMIT 5;
-[ RECORD 1 ]-+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
id            | 1
title         | Job Posting - percona
company       | PERCONA
description   | Page not found Page not found The job board you were viewing is no longer active.
location      | Remote
url           | https://boards.greenhouse.io/percona/jobs/101
skills        | {PostgreSQL,Database,SQL,Linux,Replication,"Performance Tuning"}
created_at    | 2026-09-27 06:06:53.960358+00
search_vector | 'activ':19 'board':12 'databas':21 'found':6,9 'job':1,11 'linux':23 'longer':18 'page':4,7 'percona':3 'perform':25 'post':2 'postgresql':20 'replic':24 'sql':22 'tune':26 'view':15
embedding     |
-[ RECORD 2 ]-+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
id            | 2
title         | Job Posting - supabase
company       | SUPABASE
description   | Error Cannot GET /supabase/jobs/102
location      | Remote
url           | https://jobs.lever.co/supabase/jobs/102
skills        | {PostgreSQL,Database,SQL,Linux,Replication,"Performance Tuning"}
created_at    | 2026-09-27 06:08:09.754686+00
search_vector | '/supabase/jobs/102':7 'cannot':5 'databas':9 'error':4 'get':6 'job':1 'linux':11 'perform':13 'post':2 'postgresql':8 'replic':12 'sql':10 'supabas':3 'tune':14
embedding     |

job_search=# SELECT * FROM jobs LIMIT 5;
-[ RECORD 1 ]-+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
id            | 1
title         | Job Posting - percona
company       | PERCONA
description   | Page not found Page not found The job board you were viewing is no longer active.
location      | Remote
url           | https://boards.greenhouse.io/percona/jobs/101
skills        | {PostgreSQL,Database,SQL,Linux,Replication,"Performance Tuning"}
created_at    | 2026-09-27 06:06:53.960358+00
search_vector | 'activ':19 'board':12 'databas':21 'found':6,9 'job':1,11 'linux':23 'longer':18 'page':4,7 'percona':3 'perform':25 'post':2 'postgresql':20 'replic':24 'sql':22 'tune':26 'view':15
embedding     |
-[ RECORD 2 ]-+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
id            | 2
title         | Job Posting - supabase
company       | SUPABASE
description   | Error Cannot GET /supabase/jobs/102
location      | Remote
url           | https://jobs.lever.co/supabase/jobs/102
skills        | {PostgreSQL,Database,SQL,Linux,Replication,"Performance Tuning"}
created_at    | 2026-09-27 06:08:09.754686+00
search_vector | '/supabase/jobs/102':7 'cannot':5 'databas':9 'error':4 'get':6 'job':1 'linux':11 'perform':13 'post':2 'postgresql':8 'replic':12 'sql':10 'supabas':3 'tune':14
embedding     |

job_search=# \q

What's next:
    Try Docker Debug for seamless, persistent debugging tools in any container or image → docker debug job_search
    Learn more at https://docs.docker.com/go/debug-cli/
PS C:\Users\USER\Desktop\Client works\Percona Writer's Program\semantic-job-search\docker> docker exec -it job_search psql -U admin -d job_search
psql (18.6 - Percona Server for PostgreSQL 18.6.1)
Type "help" for help.

job_search=# SELECT * FROM jobs LIMIT 5;
 id |         title          | company  |                                    description                                    | location |                      url
                 |                              skills                              |          created_at           |
                                    search_vector                                                                                      | embedding
----+------------------------+----------+-----------------------------------------------------------------------------------+----------+------------------------------
-----------------+------------------------------------------------------------------+-------------------------------+-------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------+-----------
  1 | Job Posting - percona  | PERCONA  | Page not found Page not found The job board you were viewing is no longer active. | Remote   | https://boards.greenhouse.io/
percona/jobs/101 | {PostgreSQL,Database,SQL,Linux,Replication,"Performance Tuning"} | 2026-09-27 06:06:53.960358+00 | 'activ':19 'board':12 'databas':21 'found':6,9 '
job':1,11 'linux':23 'longer':18 'page':4,7 'percona':3 'perform':25 'post':2 'postgresql':20 'replic':24 'sql':22 'tune':26 'view':15 |
  2 | Job Posting - supabase | SUPABASE | Error Cannot GET /supabase/jobs/102                                               | Remote   | https://jobs.lever.co/supabas
e/jobs/102       | {PostgreSQL,Database,SQL,Linux,Replication,"Performance Tuning"} | 2026-09-27 06:08:09.754686+00 | '/supabase/jobs/102':7 'cannot':5 'databas':9 'e
rror':4 'get':6 'job':1 'linux':11 'perform':13 'post':2 'postgresql':8 'replic':12 'sql':10 'supabas':3 'tune':14                     |
(2 rows)

job_search=# \x
Expanded display is on.
job_search=# SELECT * FROM jobs LIMIT 5;
-[ RECORD 1 ]-+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
id            | 1
title         | Job Posting - percona
company       | PERCONA
description   | Page not found Page not found The job board you were viewing is no longer active.
location      | Remote
url           | https://boards.greenhouse.io/percona/jobs/101
skills        | {PostgreSQL,Database,SQL,Linux,Replication,"Performance Tuning"}
created_at    | 2026-09-27 06:06:53.960358+00
search_vector | 'activ':19 'board':12 'databas':21 'found':6,9 'job':1,11 'linux':23 'longer':18 'page':4,7 'percona':3 'perform':25 'post':2 'postgresql':20 'replic':24 'sql':22 'tune':26 'view':15
embedding     |
-[ RECORD 2 ]-+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
id            | 2
title         | Job Posting - supabase
company       | SUPABASE
description   | Error Cannot GET /supabase/jobs/102
location      | Remote
url           | https://jobs.lever.co/supabase/jobs/102
skills        | {PostgreSQL,Database,SQL,Linux,Replication,"Performance Tuning"}
created_at    | 2026-09-27 06:08:09.754686+00
search_vector | '/supabase/jobs/102':7 'cannot':5 'databas':9 'error':4 'get':6 'job':1 'linux':11 'perform':13 'post':2 'postgresql':8 'replic':12 'sql':10 'supabas':3 'tune':14
embedding     |

job_search=# DELETE FROM jobs;
DELETE 2
job_search=# SELECT * FROM jobs LIMIT 5;
(0 rows)

job_search=# SELECT COUNT(*) FROM jobs;
-[ RECORD 1 ]
count | 10

job_search=# SELECT * FROM jobs LIMIT 5;
-[ RECORD 1 ]-+-------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------
id            | 3
title         | Job Application for Senior Backend Engineer (Full-Stack Capable) at Orkes
company       | ORKES
description   | [Back to jobs](https://job-boards.greenhouse.io/orkes) # Senior Backend Engineer (Full-Stack Capable) In Office - Santa Clara, CA Apply **\*Position i
s** **IN OFFICE** **at our Santa Clara, CA (San Francisco Bay Area) office** **About Us** Orkes is the operating system for AI agents and workflows, providing the bat
tle-tested infrastructure required to move AI from simple conversation to real
location      | Remote
url           | https://boards.greenhouse.io/orkes/jobs/5378021008
skills        | {PostgreSQL,Database,SQL,Linux,Replication,"Performance Tuning"}
created_at    | 2026-09-27 14:19:51.087177+00
search_vector | '/orkes)':18 'agent':55 'ai':54,67 'appli':31 'applic':2 'area':44 'back':13 'backend':5,20 'battl':61 'battle-test':60 'bay':43 'ca':30,40 'capabl':1
0,25 'clara':29,39 'convers':70 'databas':74 'engin':6,21 'francisco':42 'full':8,23 'full-stack':7,22 'infrastructur':63 'job':1,15 'job-boards.greenhouse.io':17 'jo
b-boards.greenhouse.io/orkes)':16 'linux':76 'move':66 'offic':27,35,45 'oper':51 'ork':12,48 'perform':78 'posit':32 'postgresql':73 'provid':58 'real':72 'replic':7
7 'requir':64 'san':41 'santa':28,38 'senior':4,19 'simpl':69 'sql':75 'stack':9,24 'system':52 'test':62 'tune':79 'us':47 'workflow':57
embedding     | [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.09167,0,0,0,0,0,0,0,0,0,0,0,0,0,0.18334,0,0,0,0.18334,0,0,0,0,0,0,-0.18334,0.09167,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.18334,0,0,-0.09167,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.18334,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0
.09167,0,0,0,0,0,0,0,0,0,-0.09167,0,0,0,0,0,0,0.09167,0,0,-0.09167,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.09167,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
,0,0,-0.18334,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.09167,0,0,0,0,-0.09167,0,0,0,0,0,0,0,0,0,0,0,0,0.09167,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.18334,0,0,0,-0.09167,0.18334,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.09167,0,0,0.27501,0,0,-0.18334,0,0,0,-
0.09167,0,0,0,0,0.09167,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.18334,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.09167,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
,0,0,0,0,0.27501,0,0,0,0,0,0,0,0.09167,0,0,0,0,-0.09167,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.09167,0,0.18334,-0.09167
,0,0,0,0,0,-0.09167,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.09167,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.18334,0.09167,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
,0,0,0,0,-0.18334,0,0,0,0,0,0,0,0,0,0,0,-0.27501,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.18334,0,0,0,0,0,0,0,0,-0.18334,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.09167,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.09167,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.09167,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
,0.09167,0,0,0,0,0,0,0,0,0,0.09167,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.09167,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.09167,-0.09167,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.091
67,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
-[ RECORD 2 ]-+-------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------
id            | 4
Cancel request sent
job_search=# \d+ jobs
                                                                                                                                                                   Tab
le "public.jobs"
    Column     |           Type           | Collation | Nullable |
         Default                                                                                                              | Storage  | Compression | Stats target
| Description
---------------+--------------------------+-----------+----------+----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------+----------+-------------+--------------
+-------------
 id            | bigint                   |           | not null | nextval('jobs_id_seq'::regclass)
                                                                                                                              | plain    |             |
|
 title         | text                     |           | not null |
                                                                                                                              | extended |             |
|
 company       | text                     |           | not null |
                                                                                                                              | extended |             |
|
 description   | text                     |           | not null |
                                                                                                                              | extended |             |
|
 location      | text                     |           |          |
                                                                                                                              | extended |             |
|
 url           | text                     |           | not null |
                                                                                                                              | extended |             |
|
 skills        | text[]                   |           |          |
                                                                                                                              | extended |             |
|
 created_at    | timestamp with time zone |           |          | now()
                                                                                                                              | plain    |             |
|
 search_vector | tsvector                 |           |          | generated always as (to_tsvector('english'::regconfig, (((COALESCE(title, ''::text) || ' '::text) |
| COALESCE(description, ''::text)) || ' '::text) || COALESCE(immutable_array_to_string(skills, ' '::text), ''::text))) stored | extended |             |
|
 embedding     | vector(1024)             |           |          |
                                                                                                                              | external |             |
|
Indexes:
    "jobs_pkey" PRIMARY KEY, btree (id)
    "jobs_search_vector_idx" gin (search_vector)
    "jobs_url_key" UNIQUE CONSTRAINT, btree (url)
Not-null constraints:
    "jobs_id_not_null" NOT NULL "id"
    "jobs_title_not_null" NOT NULL "title"
    "jobs_company_not_null" NOT NULL "company"
    "jobs_description_not_null" NOT NULL "description"
    "jobs_url_not_null" NOT NULL "url"
Access method: heap

job_search=# SELECT id, left(embedding::text, 80) FROM jobs LIMIT 3;
-[ RECORD 1 ]--------------------------------------------------------------------------
id   | 3
left | [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.09167,0,0,0,0,0,0,0,0,0,0
-[ RECORD 2 ]--------------------------------------------------------------------------
id   | 4
left | [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
-[ RECORD 3 ]--------------------------------------------------------------------------
id   | 5
left | [0,0,0,0,0.123091,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.123091,0,0,0,0,0,0.123091,

job_search=# DELETE FROM jobs;
DELETE 10
job_search=# SELECT * FROM jobs LIMIT 5;
(0 rows)

job_search=# SELECT id, left(embedding::text, 80) FROM jobs LIMIT 3;
-[ RECORD 1 ]--------------------------------------------------------------------------
id   | 13
left | [-0.04292301,-0.03524205,-0.04382665,-0.06867682,0.09397881,-0.02360766,-0.00139
-[ RECORD 2 ]--------------------------------------------------------------------------
id   | 14
left | [-0.02984542,-0.07419738,-0.04066587,-0.09274673,0.04994055,-0.02259215,0.014684
-[ RECORD 3 ]--------------------------------------------------------------------------
id   | 15
left | [-0.02666932,-0.04757807,-0.03840383,-0.08406171,0.1024102,-0.013388,0.00610728,

job_search=# SELECT id, title, company, location, created_at FROM jobs LIMIT 10;
-[ RECORD 1 ]-----------------------------------------------------------------------------------------------------
id         | 13
title      | Senior Backend Engineer | my team | Jobs by Workable
company    | VIEW
location   | Remote
created_at | 2026-09-27 19:44:35.295225+00
-[ RECORD 2 ]-----------------------------------------------------------------------------------------------------
id         | 14
title      | Backend Engineer  @ Loora
company    | LOORA
location   | Remote
created_at | 2026-09-27 19:44:35.486335+00
-[ RECORD 3 ]-----------------------------------------------------------------------------------------------------
id         | 15
title      | ABOUT YOU SE & Co. KG Senior Backend Engineer - Search & Discovery (all genders) | SmartRecruiters
company    | SMARTRECRUITERS
location   | Remote
created_at | 2026-09-27 19:44:35.508299+00
-[ RECORD 4 ]-----------------------------------------------------------------------------------------------------
id         | 16
title      | Senior Software Engineer- Backend, Python | Beyond | Jobs by Workable
company    | VIEW
location   | Remote
created_at | 2026-09-27 19:44:35.524875+00
-[ RECORD 5 ]-----------------------------------------------------------------------------------------------------
id         | 17
title      | This job is not available anymore | Jobs by Workable
company    | VIEW
location   | Remote
created_at | 2026-09-27 19:44:35.543485+00
-[ RECORD 6 ]-----------------------------------------------------------------------------------------------------
id         | 18
title      | Nexthink Senior/Staff Backend Engineer  | SmartRecruiters
company    | SMARTRECRUITERS
location   | Remote
created_at | 2026-09-27 19:44:35.560788+00
-[ RECORD 7 ]-----------------------------------------------------------------------------------------------------
id         | 19
title      | Bertelsmann-Jobs Senior Backend Engineer (C#/.Net) (m/f/d) | SmartRecruiters
company    | SMARTRECRUITERS
location   | Remote
created_at | 2026-09-27 19:44:35.580176+00
-[ RECORD 8 ]-----------------------------------------------------------------------------------------------------
id         | 20
title      | Senior Node.js Developer - (NestJS) - Remote - 3 Months - Octopus by RTG | robusta | Jobs by Workable
company    | VIEW
location   | Remote
created_at | 2026-09-27 19:44:35.595515+00
-[ RECORD 9 ]-----------------------------------------------------------------------------------------------------
id         | 21
title      | Xsolla - Middle/ Senior Backend Engineer (Golang&PHP)
company    | XSOLLA
location   | Remote
created_at | 2026-09-27 19:44:35.612512+00
-[ RECORD 10 ]----------------------------------------------------------------------------------------------------
id         | 22
title      | Senior Backend Engineer (Incogni)  @ Surfshark
company    | SURFSHARK
location   | Remote
created_at | 2026-09-27 19:44:35.629528+00

job_search=# SELECT * FROM jobs LIMIT 2;
-[ RECORD 1 ]-+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
id            | 13
title         | Senior Backend Engineer | my team | Jobs by Workable
company       | VIEW
description   | my team logo # **Senior Backend Engineer** ## at [my team](https://jobs.workable.com/company/fQx3op17RQpfCyThMhF7Wa/jobs-at-my-team) **On-site**Tel Aviv-Yafo, Tel Aviv District, IsraelMyTeamP Posted over 1 year ago Share job Apply now ### **Description** We are seeking a highly motivated and talented Senior Backend Engineer to join our growing engineering team. In this role, you will play
location      | Remote
url           | https://jobs.workable.com/view/4CJbvHa6zfo9vQ4SaiDAf7/senior-backend-engineer-in-tel-aviv-yafo-at-my-team
skills        | {PostgreSQL,Database,SQL,Linux,Replication,"Performance Tuning"}
created_at    | 2026-09-27 19:44:35.295225+00
search_vector | '/company/fqx3op17rqpfcythmhf7wa/jobs-at-my-team)':20 '1':34 'ago':36 'appli':39 'aviv':26,29 'aviv-yafo':25 'backend':2,13,51 'databas':66 'descript':41 'district':30 'engin':3,14,52,57 'grow':56 'high':46 'israelmyteamp':31 'job':6,38 'jobs.workable.com':19 'jobs.workable.com/company/fqx3op17rqpfcythmhf7wa/jobs-at-my-team)':18 'join':54 'linux':68 'logo':11 'motiv':47 'on-sit':21 'perform':70 'play':64 'post':32 'postgresql':65 'replic':69 'role':61 'seek':44 'senior':1,12,50 'share':37 'site':23 'sql':67 'talent':49 'team':5,10,17,58 'tel':24,28 'tune':71 'workabl':8 'yafo':27 'year':35
embedding     | [-0.04292301,-0.03524205,-0.04382665,-0.06867682,0.09397881,-0.02360766,-0.00139782,-0.02756109,0.03930844,0.05873676,-0.07319503,0.06958047,-0.01090019,-0.02496312,-0.10798527,0.02100969,0.00293684,-0.0298202,-0.01683034,-0.01022245,0.03004611,-0.07771324,-0.00432054,-0.02677041,0.01897649,-0.0042923,0.09262335,-0.02338175,0.07726143,0.0144018,0.05467036,-0.05218535,0.05218535,0.03591979,0.02236515,-0.02067082,-0.00519594,0.01169087,0.01671738,0.04314892,-0.00310627,-0.01180383,-0.04834487,-0.01863762,0.02891656,0.07726143,0.03976027,0.01931536,0.02789996,0.05263717,-0.01005302,-0.05037807,-0.03207931,0.01705625,0.02191333,-0.04088982,-0.02620563,-0.02338175,-0.01603965,-0.02055787,0.03479023,-0.01637852,0.00035122,0.03320886,0.00903642,0.03298295,0.0318534,0.00369929,-0.05512219,0.03117566,0.02699632,0.02067082,-0.04292301,0.04156755,-0.02044491,-0.02281697,-0.0426971,-0.02281697,0.01219917,0.02089673,-0.01067428,0.01298986,-0.03456432,0.02496312,0.00739857,-0.01626556,0.02586676,-0.0128769,0.00218851,-0.01908945,-0.02846474,0.03704934,-0.0426971,-0.05037807,-0.00847165,0.00660789,-0.0447303,0.00477236,-0.02157446,-0.01146496,-0.0298202,-0.04585985,-0.01683034,0.00474412,-0.02089673,0.04495621,-0.03998617,0.0144018,0.01208622,0.00739857,-0.00988359,0.00063184,0.00570424,0.03501614,0.00187788,-0.0149101,-0.03320886,0.03908253,-0.01626556,-0.00485708,-0.0181858,-0.04021209,-0.00089305,-0.01406293,-0.00578896,-0.00903642,-0.01863762,-0.0042923,0.01762103,-0.02507608,0.03117566,-0.04970033,0.01739512,0.02914247,-0.00601487,0.01095666,0.04111573,0.01547488,0.01660443,0.0212356,-0.00897995,0.02168742,-0.01276395,0.04201937,-0.01886353,-0.0894606,0.08494239,-0.0008754,-0.01999309,0.00172963,-0.03591979,0.03140157,-0.040438,-0.01191678,0.03501614,0.01157792,0.04676349,0.01886353,0.02801291,0.02586676,-0.02202628,-0.06235133,0.06415861,-0.04179346,0.01039189,0.0159267,0.05873676,0.01016598,0.03456432,0.01852467,-0.02146151,-0.00796335,-0.01248156,0.04518212,-0.00528066,0.02033195,0.02326879,-0.05128171,-0.03614569,-0.01841171,-0.02100969,0.01067428,0.06641772,0.00835869,0.02168742,-0.00920586,0.02360766,0.03772707,0.01637852,-0.03027202,0.01219917,0.01536192,0.03953436,0.0080763,0.00146842,0.01344168,-0.00261209,0.04970033,-0.07590596,0.02236515,0.00612783,-0.02236515,0.03750116,-0.04585985,0.00977063,-0.01807285,0.0144018,0.01304634,-0.040438,-0.00785039,-0.02812587,0.00903642,0.03863071,-0.03094975,-0.00491356,-0.05828493,-0.02597972,-0.02078377,-0.02315584,0.05512219,0.02439835,0.00086834,0.05873676,0.03004611,0.00533714,-0.00206143,0.00903642,-0.00505475,-0.00255561,0.00649493,-0.00132722,0.00988359,-0.02394652,-0.00714442,-0.01406293,-0.03479023,0.04495621,-0.03275704,0.005676,0.0072009,-0.01739512,0.00409463,0.00448997,0.02439835,-0.00768096,-0.02112264,-0.0106178,-0.01558783,-0.01310281,-0.03298295,0.0138935,-0.02372061,-0.00163079,0.03659752,0.03795298,-0.00550657,0.0024003,-0.00154608,-0.00432054,0.02405948,-0.00095306,0.00652317,-0.02304288,0.04156755,0.02315584,0.00578896,0.02202628,0.06325497,-0.01423237,0.01513601,0.00183552,0.01095666,-0.02586676,0.00739857,0.05489628,-0.03885662,0.02846474,-0.01716921,0.04179346,0.05670356,-0.04992624,-0.02620563,-0.00269681,-0.02699632,0.01615261,0.00103778,0.01863762,0.01558783,0.05421855,0.03930844,0.01225565,0.0159267,0.01863762,0.05467036,-0.0490226,0.0039252,0.01457123,0.05444445,-0.01513601,0.01875058,-0.06189951,-0.01298986,0.02428539,-0.03772707,0.04405257,-0.01683034,-0.05082988,0.00649493,0.01033541,0.00999654,0.03863071,0.01829876,-0.03682343,0.00864108,0.00448997,-0.02835178,-0.01671738,-0.00474412,-0.01146496,-0.03885662,0.00638197,0.04721532,-0.02247811,0.03750116,-0.02789996,-0.01942831,-0.0080763,0.02405948,-0.0447303,-0.0212356,0.03885662,-0.0096012,-0.01762103,0.04744123,0.04224528,0.02688336,0.00328982,0.01434532,0.00206143,0.0106178,-0.0298202,0.01581374,0.03207931,0.07319503,0.03027202,-0.01841171,0.08268328,0.05354081,-0.02033195,-0.00129899,0.0053089,-0.02710927,0.02338175,-0.04653758,-0.00354397,0.03953436,0.01897649,0.00251326,0.05241126,-0.03049793,0.06732136,-0.06280315,-0.06054404,0.02168742,-0.02405948,0.00150372,-0.04247119,-0.01293338,0.00937529,-0.01327225,-0.02530199,-0.02869065,-0.01852467,0.02530199,-0.02292993,-0.01795989,0.00235794,0.04134164,-0.01942831,0.00914938,0.01807285,0.04224528,-0.00796335,-0.02496312,0.02609267,-0.03908253,0.06144768,0.02575381,0.03569388,-0.04585985,0.07680961,0.03004611,0.01383702,-0.03207931,-0.0128769,-0.01400646,-0.11476258,0.01931536,0.0298202,0.02044491,0.02767405,-0.01852467,-0.05692947,0.00818926,-0.01841171,0.00119309,0.03591979,0.02564085,0.04360075,0.04111573,0.0318534,0.03750116,-0.02462425,0.01118257,-0.00275329,-0.02846474,0.04450439,-0.03253113,0.00835869,-0.04179346,-0.02665745,0.01660443,0.00497003,-0.04676349,0.00638197,0.02112264,0.00375576,-0.03298295,-0.00228734,0.0116344,-0.00313451,-0.03772707,-0.01417589,0.03072384,-0.02789996,-0.01694329,0.0138935,-0.005676,0.02597972,0.00295096,0.00389696,-0.04811896,-0.01146496,-0.00779392,0.00835869,-0.04585985,-0.00779392,-0.00096012,-0.00082599,0.02756109,-0.00063537,-0.02959429,-0.02405948,0.05489628,0.02733518,-0.01372407,-0.00886699,0.09126788,0.002838,0.03727525,0.0341125,0.02959429,-0.03727525,0.00109425,-0.00914938,0.02168742,-0.00303567,-0.03750116,-0.03320886,0.03501614,0.00271093,-0.05399263,-0.01739512,0.0085846,-0.04021209,-0.00869756,0.02225219,0.001419,-0.01570079,-0.01118257,0.10798527,0.00785039,0.00141194,0.03072384,0.0255279,-0.00194848,-0.01411941,0.00638197,0.00336042,0.00561953,-0.00739857,-0.01033541,-0.00892347,-0.00914938,0.06144768,0.01683034,0.02699632,0.06415861,0.00525242,0.03659752,0.0298202,-0.01361111,-0.04292301,-0.0234947,0.03772707,-0.01152144,-0.02180037,-0.00437702,0.03072384,-0.01236861,0.04653758,0.040438,-0.02869065,0.05308899,-0.01863762,-0.01807285,-0.03140157,-0.0318534,0.01022245,-0.01129553,0.0212356,-0.01016598,-0.01795989,0.0058172,-0.01739512,0.03546796,0.03524205,0.01140849,-0.00869756,0.03117566,0.01202974,-0.06641772,-0.03320886,0.03750116,0.01214269,-0.04156755,-0.02100969,0.02428539,-0.0576072,-0.02372061,-0.0384048,0.0212356,-0.0090929,0.02033195,0.03591979,-0.03885662,-0.03546796,0.01349816,0.04947442,0.01157792,-0.00852813,0.01265099,0.02631859,0.02801291,-0.00235794,0.00432054,-0.05376672,0.01942831,-0.00641021,0.01372407,0.05692947,0.01033541,0.0447303,0.00875404,0.04314892,0.00892347,0.01626556,-0.03117566,0.01344168,0.03569388,-0.04518212,-0.04066391,-0.03704934,0.03140157,-0.00123545,-0.03727525,-0.03162748,-0.01671738,-0.01841171,-0.00881051,-0.05489628,0.00897995,-0.02225219,0.02959429,0.00224499,0.01728216,0.01400646,-0.01536192,-0.01056132,0.03366068,-0.06370679,0.02473721,-0.03253113,-0.02405948,-0.00157431,0.00926233,-0.03027202,0.00914938,-0.03366068,0.00177905,-0.02180037,-0.01349816,-0.12289537,0.03253113,-0.01637852,0.01908945,0.03094975,-0.00330394,-0.00714442,0.00920586,-0.00058596,0.01298986,0.0853942,-0.03320886,-0.04066391,-0.04540803,0.00460293,0.04179346,0.00892347,0.00994007,-0.0090929,0.00056125,-0.02168742,-0.01276395,-0.05579992,-0.01073075,-0.01931536,0.01479714,0.00629726,0.02134855,-0.00406639,-0.01671738,0.03953436,-0.03049793,-0.00722914,-0.01406293,0.00109425,0.03953436,-0.01942831,0.00103072,-0.0080763,0.00106602,0.03524205,0.03524205,0.02372061,0.02033195,-0.02597972,0.02428539,0.02496312,-0.00190612,0.02496312,-0.01332873,-0.00403815,-0.00451821,0.0245113,-0.0234947,-0.01248156,-0.04382665,-0.05828493,-0.020219,-0.00965768,-0.00542185,-0.00593015,-0.0894606,-0.03795298,-0.0288036,-0.00886699,-0.01434532,0.04314892,-0.03591979,-0.03750116,0.03546796,0.01293338,0.05783311,-0.00677732,0.03953436,-0.02530199,-0.01976718,0.00320511,0.01293338,0.02688336,-0.02168742,0.00169433,-0.01988013,-0.04292301,0.01965422,0.02202628,-0.00162373,0.03343477,-0.01400646,-0.04766714,-0.01479714,0.03117566,0.00078363,-0.04179346,0.027787,-0.03140157,-0.01090019,-0.01976718,-0.03094975,-0.0149101,-0.0469894,-0.05015215,0.01863762,-0.020219,0.03727525,0.01208622,-0.04563394,-0.03795298,-0.00289448,0.00550657,-0.00020473,0.01875058,-0.027787,0.01886353,0.00697499,0.00367105,0.03704934,-0.03908253,-0.01411941,-0.03501614,0.05579992,-0.00513947,0.02270401,-0.05783311,-0.00216027,0.0384048,0.00564777,-0.0234947,0.05557401,0.00457469,-0.01208622,0.01355464,0.01852467,-0.00200496,0.0255279,0.02620563,-0.03817889,0.01129553,-0.03479023,0.0192024,-0.001892,0.02044491,-0.03659752,0.03117566,0.02564085,-0.03682343,-0.02891656,0.0144018,-0.03253113,-0.0032757,-0.06415861,-0.02518903,-0.02812587,-0.04066391,-0.02564085,-0.06461043,0.01457123,-0.00994007,-0.06009222,-0.07003228,-0.06370679,-0.02586676,-0.05828493,-0.01321577,-0.00920586,-0.00649493,-0.02586676,0.02055787,0.04744123,0.02609267,-0.01875058,0.0469894,0.02699632,0.03704934,0.03117566,-0.00612783,-0.00432054,0.03863071,0.03614569,0.07500232,-0.01807285,-0.06461043,0.01536192,-0.0553481,-0.00072715,0.0159267,-0.01468419,-0.02936838,0.03094975,0.00739857,0.01135201,0.01479714,-0.03275704,0.01728216,0.03230521,-0.02586676,-0.01965422,-0.02247811,-0.00124957,-0.03682343,-0.00999654,-0.05692947,-0.00511123,-0.02846474,0.05421855,-0.0510558,0.00931881,0.03591979,-0.03433841,-0.01637852,0.04450439,0.0426971,0.03659752,-0.00463117,0.00494179,-0.01479714,-0.01547488,-0.0090929,0.00303567,-0.0447303,0.01728216,-0.02281697,0.0318534,0.04066391,0.01479714,-0.00238618,-0.03298295,0.03772707,0.03817889,-0.02089673,0.02507608,-0.04427848,-0.04247119,-0.03320886,-0.02010604,-0.00672084,-0.04382665,0.02665745,-0.03908253,-0.00926233,0.02055787,0.00691851,-0.07500232,0.00340278,-0.02677041,-0.01897649,-0.00982711,0.00728562,-0.05286308,-0.00331806,-0.02722223,0.02259106,0.01649147,0.01705625,0.02338175,-0.02033195,-0.01705625,-0.05512219,0.06009222,-0.0384048,-0.01829876,0.01039189,0.01547488,0.02473721,0.04134164,-0.02530199,0.03072384,0.01513601,0.04111573,-0.06461043,0.02688336,-0.02405948,0.01954127,0.01603965,0.01101314,-0.03591979,-0.00649493,-0.01875058,0.03388659,-0.01242508,-0.02326879,0.02428539,-0.01773398,-0.04066391,-0.06054404,-0.00273917,0.04156755,0.01976718,-0.00089305,-0.01242508,-0.00536538,-0.02507608,0.02202628,0.03772707,0.02959429,0.03072384,-0.02157446,0.00326158,-0.0245113,0.00159549,-0.02315584,0.02767405,0.03817889,0.02225219,-0.01259452,0.0596404,-0.00886699,-0.05421855,-0.00739857,0.03094975,-0.0265445,-0.01050484,0.0106178,-0.00666436,-0.0063255,0.0007095,-0.01027893,-0.02191333,0.00672084,-0.01841171,0.0010519,0.05150762,0.02247811,-0.01558783,0.068225,0.02044491,0.01875058,0.07229139,-0.00091776,0.04721532,0.04857078,-0.040438,0.01027893,-0.00448997,0.00460293,0.00197672,-0.06867682,0.00598663,-0.04066391,0.02304288,-0.05489628,0.0192024,-0.02891656,-0.00533714,-0.04540803,0.02699632,-0.04992624,0.00801983,-0.00508299,0.00615606,-0.02326879,-0.01073075,-0.00762448,-0.01135201,-0.05625174,0.00728562,-0.01603965,0.01197326,-0.02586676,-0.01716921,-0.04450439,-0.03479023,-0.03140157,-0.02699632,0.03366068,0.00432054,-0.0080763,-0.00485708,-0.05918858,0.01931536,-0.01739512,0.00612783,-0.01999309,-0.04156755,0.06370679,-0.03998617,0.01807285,0.03591979,-0.00595839,-0.03546796,-0.0116344,-0.02643154,-0.0265445,0.08810513,-0.03569388,-0.00482884,0.00892347,0.01344168,0.01349816,-0.04450439,-0.01146496,-0.01056132,0.00536538,-0.01406293,-0.04857078,0.00550657,0.03162748,-0.00663612,-0.04201937,0.05738129,-0.02733518,-0.01129553,-0.02620563,-0.02134855,0.00734209,0.04992624,0.00343102,0.02202628,0.05579992,0.0212356,-0.00254149,-0.00114367,0.01044837,0.04857078,-0.00499827,-0.03140157,0.01716921,0.0288036,0.01852467,-0.02473721,-0.0533149,0.02326879,0.01457123]
-[ RECORD 2 ]-+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
id            | 14
title         | Backend Engineer  @ Loora
company       | LOORA
description   | - [![Loora](https://app.ashbyhq.com/api/images/org-theme-logo/c180ed82-05e3-4c18-a7d0-df79e9a5de04/887925bb-5bd1-4208-b1d9-e47d5f9a68f9/1a88189e-e9e3-42d5-99a5-d8b8c8e6a992.png)](https://www.loora.com/) [Back to Loora’s Job Listings](https://loora.com/careers) # Backend Engineer ## Location Tel Aviv ## Employment Type Full time ## Location Type Hybrid ## Department R&D Loora is on a miss
location      | Remote
url           | https://jobs.ashbyhq.com/loora/ccda6f29-665e-451d-a87b-4ce602e55791
skills        | {PostgreSQL,Database,SQL,Linux,Replication,"Performance Tuning"}
created_at    | 2026-09-27 19:44:35.486335+00
search_vector | '/api/images/org-theme-logo/c180ed82-05e3-4c18-a7d0-df79e9a5de04/887925bb-5bd1-4208-b1d9-e47d5f9a68f9/1a88189e-e9e3-42d5-99a5-d8b8c8e6a992.png)](https://www.loora.com/)':7 '/careers)':16 'app.ashbyhq.com':6 'app.ashbyhq.com/api/images/org-theme-logo/c180ed82-05e3-4c18-a7d0-df79e9a5de04/887925bb-5bd1-4208-b1d9-e47d5f9a68f9/1a88189e-e9e3-42d5-99a5-d8b8c8e6a992.png)](https://www.loora.com/)':5 'aviv':21 'back':8 'backend':1,17 'd':31 'databas':38 'depart':29 'employ':22 'engin':2,18 'full':24 'hybrid':28 'job':12 'linux':40 'list':13 'locat':19,26 'loora':3,4,10,32 'loora.com':15 'loora.com/careers)':14 'miss':36 'perform':42 'postgresql':37 'r':30 'replic':41 'sql':39 'tel':20 'time':25 'tune':43 'type':23,27
embedding     | [-0.02984542,-0.07419738,-0.04066587,-0.09274673,0.04994055,-0.02259215,0.0146849,-0.04019025,0.01700357,0.03804994,0.0088585,0.02080856,-0.01516052,-0.02699168,-0.08561236,-0.00267539,0.03091558,-0.03376932,0.02175981,-0.01206897,0.05398335,-0.08561236,0.0004942,0.00541023,0.02294887,0.03495838,0.06183115,-0.02865636,0.11652794,0.01605232,0.02782402,-0.05707491,0.07324614,0.02282996,0.02853746,-0.02639715,0.00419144,0.00862069,0.04684899,0.03709869,0.02651605,-0.0087396,-0.05112961,-0.01640904,0.02437574,0.03067776,0.03709869,0.01581451,0.0002824,0.0351962,-0.03115339,-0.04399524,-0.01260404,0.00992866,0.03567182,-0.05588585,-0.05612366,-0.0136742,-0.00529132,-0.01973841,0.06373365,0.00529132,-0.02461356,-0.01230678,0.02378121,0.02282996,0.03210464,-0.00135999,-0.05374554,-0.00511296,0.00121136,0.04185493,-0.04565993,0.03448276,-0.02282996,-0.00368609,-0.0098692,-0.04756242,0.0313912,0.00659929,-0.04066587,0.00927467,-0.03234245,-0.00280916,0.00665874,-0.02984542,0.01688466,0.0043698,0.00558859,-0.00410226,-0.02984542,0.04090369,-0.05184304,-0.04423306,0.01028537,0.02818074,-0.0489893,0.017717,-0.01456599,0.01171225,-0.0255648,-0.02758621,0.00945303,0.00680737,-0.01736028,0.02473246,-0.03733651,0.03008323,0.02211653,0.00184304,0.01082045,-0.00897741,0.01486326,0.01052319,0.0012931,-0.01129608,-0.03234245,0.04090369,-0.00057224,0.01736028,-0.02211653,-0.07562426,0.02235434,-0.03567182,-0.00555886,-0.02592152,-0.03876338,-0.01664685,-0.00454816,-0.06064209,-0.01070155,-0.01046373,0.03757432,0.04090369,-0.0136742,-0.01331748,0.0234245,0.0273484,0.03162901,0.00329964,-0.00915577,0.01403092,-0.01147444,0.04280618,-0.0234245,-0.09322236,0.05778835,-0.00998811,-0.0411415,0.00980975,-0.04090369,0.05017836,-0.06230678,-0.00158294,0.05160523,0.02675387,0.02508918,0.04066587,0.03067776,0.01420928,-0.02282996,-0.04019025,0.02901308,-0.04233056,-0.01254459,0.02009512,0.05184304,0.01052319,0.00300238,0.02259215,-0.01688466,-0.00862069,-0.03757432,0.03686088,0.01361474,0.01302021,-0.0014343,-0.02187872,-0.02271106,-0.01064209,-0.01058264,-0.00300238,0.05612366,0.02485137,0.02211653,-0.01230678,0.006956,0.00980975,0.03424495,-0.0587396,-0.01349584,-0.00206599,0.02390012,0.0351962,0.01795482,-0.01093936,-0.03067776,0.05065398,-0.04565993,-0.00170927,-0.01296076,-0.0273484,0.02615933,-0.02829964,0.02520809,0.00746136,0.01236623,-0.0087396,-0.02615933,0.02925089,-0.01260404,-0.00472652,0.03686088,-0.02461356,-0.02818074,-0.0646849,-0.039239,0.00321046,-0.01111772,0.02901308,0.01617122,-0.01361474,0.04851367,0.01938169,-0.00064284,-0.00095868,0.00517241,-0.01070155,-0.01296076,-0.02461356,0.01123662,0.02532699,-0.02413793,0.00772889,-0.02841855,-0.03376932,0.05160523,-0.00998811,0.00609394,-0.01093936,-0.00338882,0.01016647,0.02247325,-0.02247325,-0.00998811,-0.02330559,-0.00249703,-0.02294887,-0.01950059,-0.02485137,0.0087396,-0.02449465,0.03043995,0.03543401,0.04304399,0.00957194,0.00255648,-0.02532699,0.0074019,0.04756242,0.01581451,0.0127824,-0.03995244,0.01700357,0.02057075,-0.00434007,0.00927467,0.04423306,0.00496433,0.00588585,0.01997622,0.00624257,-0.03686088,-0.00508323,0.06325803,-0.03091558,0.0646849,-0.00508323,0.04780024,0.03020214,-0.078478,-0.04161712,0.02425684,-0.02080856,0.02199762,0.01153389,0.00413199,0.00814507,0.04780024,0.01456599,0.0048157,0.04470868,0.01854935,0.04946492,-0.02818074,0.04447087,0.02568371,0.03828775,-0.01432818,0.0274673,-0.06040428,-0.007283,0.0313912,-0.05136742,0.02627824,-0.02972652,-0.03305589,-0.0196195,0.00549941,0.0062723,0.0411415,-0.00022202,-0.03424495,0.00175386,0.01605232,-0.02223543,-0.01676575,0.00194709,-0.0255648,-0.04661118,-0.00331451,0.01617122,-0.03305589,0.00692628,-0.02758621,-0.02223543,-0.00957194,0.02104637,-0.03495838,-0.01082045,0.03448276,0.00359691,-0.02568371,0.04922711,0.04375743,0.0313912,-0.00073202,-0.01159334,0.01373365,0.0108799,-0.03709869,0.00969084,0.01700357,0.06325803,0.01058264,-0.00321046,0.07277051,0.05089179,-0.0254459,-0.02520809,-0.00561831,0.00552913,0.01504162,-0.05755053,-0.02615933,0.05231867,0.03567182,0.01593341,0.0196195,-0.02461356,0.05707491,-0.0332937,-0.06325803,0.01105826,-0.03709869,0.01082045,-0.02829964,0.01403092,0.00591558,-0.02306778,-0.00505351,-0.0411415,-0.03543401,0.00957194,-0.01260404,-0.02068966,-0.00897741,0.03258026,-0.01783591,0.02401903,0.00758026,0.04946492,-0.00222949,-0.00118163,0.02853746,-0.05017836,0.05231867,0.00176873,0.04209275,-0.05136742,0.04233056,0.02175981,0.00193222,0.01355529,-0.01147444,0.00428062,-0.10416171,0.03186683,0.03020214,0.00980975,0.02615933,0.00790725,-0.06753864,-0.01593341,-0.01426873,-0.01444709,0.03614744,0.02865636,0.01831153,0.03353151,0.02568371,0.02972652,-0.03852557,-0.00939358,-0.02092747,0.00603448,0.01878716,-0.02306778,0.00374554,-0.04185493,-0.02818074,0.01397146,0.03424495,-0.0273484,0.0313912,0.03448276,0.03008323,-0.01040428,0.00850178,-0.00036229,-0.01831153,-0.02782402,0.003478,0.0216409,-0.04565993,-0.01938169,0.04161712,-0.0087396,0.07039239,-0.01129608,-0.01236623,-0.06373365,-0.01486326,-0.01135553,0.04185493,-0.0489893,-0.03995244,0.006956,-0.01361474,-0.00992866,-0.017717,-0.03971463,-0.01724138,0.02782402,0.05065398,-0.0313912,-0.02829964,0.09560048,0.00301724,0.03353151,-0.00295779,0.00862069,-0.01783591,-0.00511296,-0.02104637,0.02235434,0.00067999,-0.04137931,-0.02782402,0.06896552,0.00802616,-0.03900119,-0.00998811,0.02627824,-0.021522,0.00011333,0.03567182,0.01010702,-0.05398335,-0.01902497,0.08608799,0.01629013,0.01236623,0.02425684,0.03448276,0.02663496,-0.02532699,0.00778835,-0.01747919,0.02627824,0.00686683,-0.01385256,-0.01093936,-0.01313912,0.02722949,0.0451843,0.03590963,0.0549346,0.01700357,0.07134364,0.03032105,0.00016814,-0.0489893,-0.00419144,0.01712247,-0.01581451,-0.02068966,-0.00790725,0.0146849,0.00511296,0.03162901,0.0255648,-0.05255648,0.05255648,0.01902497,-0.01420928,-0.01819263,-0.01652794,-0.00897741,0.0015978,0.01040428,-0.01581451,-0.04090369,0.01510107,-0.0293698,0.02687277,0.03186683,-0.01183115,-0.00219976,0.0332937,0.01052319,-0.03067776,-0.02033294,0.02128419,0.00707491,-0.03971463,-0.00549941,0.01652794,-0.0351962,-0.01521998,-0.02913199,-0.00478597,-0.02580262,0.00389417,0.02627824,-0.03210464,-0.03162901,0.0078478,0.04851367,0.0053805,-0.00249703,-0.01272295,0.03115339,-0.00105529,0.0175981,-0.01319857,-0.03448276,-0.01212842,-0.00838288,0.007283,0.03448276,-0.00359691,0.03781213,-0.02865636,0.03804994,0.01712247,0.02794293,-0.00808561,0.02140309,0.0127824,-0.05017836,-0.06183115,0.00322533,0.02984542,-0.00164239,-0.03020214,-0.0470868,-0.01854935,-0.00211058,0.01010702,-0.06944114,-0.01070155,-0.02972652,0.03067776,-0.01165279,0.02604043,0.01902497,-0.03008323,-0.02865636,0.02651605,-0.02984542,0.01230678,-0.02639715,-0.01854935,0.0049346,0.05231867,-0.01997622,0.01260404,-0.0411415,0.00295779,-0.02580262,-0.03008323,-0.10273484,0.01313912,-0.00371581,-0.00021459,0.02057075,-0.00689655,-0.00285375,0.03971463,0.02259215,0.00543995,0.08894174,-0.02187872,-0.03709869,-0.03115339,-0.00543995,0.03614744,-0.03281808,-0.00222949,-0.02901308,-0.01230678,-0.02271106,0.0021849,-0.02782402,0.01914388,0.01854935,-0.00499405,0.00337396,0.0254459,0.00285375,-0.02140309,0.05564804,-0.05541022,-0.00044776,-0.02306778,-0.01973841,0.01973841,-0.02806183,-0.00668847,-0.01165279,0.00933413,0.02330559,0.03281808,-0.00239298,0.03067776,-0.02972652,0.04256837,0.02473246,-0.00980975,0.02033294,-0.00361177,-0.01997622,0.00340369,-0.00245244,-0.01747919,-0.02199762,-0.06896552,-0.04019025,-0.0156956,-3.739e-05,0.01783591,-0.00439952,-0.08846612,-0.03614744,-0.01712247,0.02080856,0.01105826,0.02925089,0.00401308,-0.03305589,-0.01504162,0.00891795,0.06611177,0.01866825,0.04375743,-0.00998811,-0.01736028,0.00135256,0.03472057,0.02782402,-0.01712247,-0.01123662,-0.00731272,-0.03353151,0.01676575,0.0137931,-0.01456599,0.01914388,0.00258621,-0.02699168,-0.03543401,0.02306778,0.00814507,-0.06420927,0.00120392,-0.05398335,-0.00134512,-0.02675387,-0.01747919,-0.02259215,-0.03757432,-0.04375743,0.02639715,0.00044776,0.0216409,0.00245244,-0.0351962,-0.02615933,-4.552e-05,-0.01985731,-0.03804994,0.02116528,-0.02580262,0.0332937,0.0068371,0.01581451,0.01890606,-0.07039239,-0.0126635,0.00760999,0.07609988,0.01521998,0.02782402,-0.06325803,0.00069486,0.03543401,0.00814507,-0.03424495,0.03662307,0.03091558,-0.02473246,0.01432818,0.04494649,-0.01290131,0.01581451,0.00648038,-0.06135553,-0.00734245,-0.03376932,0.01902497,-0.00576694,0.01337693,-0.03662307,0.02104637,0.01385256,-0.00677765,-0.02818074,-0.00187277,-0.05469679,-0.00163496,-0.05374554,-0.02651605,-0.01498216,-0.05112961,-0.00879905,-0.04684899,0.00194709,-0.03900119,-0.0646849,-0.04756242,-0.07705113,-0.03258026,-0.07514863,0.0059453,-0.00862069,-0.01866825,-0.05231867,0.00133769,0.05707491,0.04161712,-0.0087396,0.06420927,0.04066587,0.05612366,0.03686088,-0.00526159,0.00957194,0.03495838,0.03876338,0.08323424,-0.04090369,-0.07419738,0.00957194,-0.07229488,-0.00478597,0.01985731,-0.01212842,-0.01997622,-0.00326992,-0.00410226,0.01450654,-0.00484542,-0.03162901,0.03234245,0.02104637,-0.01082045,0.00526159,-0.03043995,-0.0136742,-0.03067776,0.00165725,-0.04684899,0.00168698,-0.03757432,0.04328181,-0.04447087,0.00139715,0.03590963,-0.00404281,-0.02663496,0.02913199,0.01783591,0.04256837,-0.00517241,0.01016647,-0.03757432,-0.02984542,-0.00552913,0.00710464,-0.04803805,-0.02235434,-0.01498216,0.00199168,0.04090369,0.00487515,0.00969084,-0.03376932,0.00731272,0.04066587,-0.01973841,0.02913199,-0.0235434,-0.06516052,-0.02497027,-0.01605232,-0.02104637,-0.06563615,0.01617122,-0.05659929,0.00407253,0.0313912,0.02282996,-0.07514863,-0.0014343,-0.00125595,-0.03495838,-0.01307967,0.01236623,-0.06230678,-0.01058264,-0.02473246,0.01950059,0.01914388,0.0136742,0.00734245,-0.01004756,0.00698573,-0.0549346,0.03234245,-0.01052319,-0.02722949,0.00561831,0.01438763,0.04494649,-0.00039759,-0.02247325,0.05778835,-0.01058264,0.03590963,-0.0665874,0.02140309,0.01105826,0.0005648,-0.00707491,0.0146849,-0.0136742,0.01724138,-0.03115339,0.04042806,-0.00927467,-0.05160523,0.03032105,-0.03448276,-0.05231867,-0.0530321,-0.00737218,0.00407253,0.0351962,0.02068966,-0.0234245,-0.01510107,-0.03495838,0.03210464,0.04803805,0.04756242,0.02116528,-0.01319857,-0.00790725,-0.00573722,-0.01545779,-0.0627824,0.06753864,0.01010702,0.02235434,-0.00490488,0.06563615,-0.0126635,-0.06563615,0.01159334,0.01450654,-0.0293698,-0.00133026,0.00648038,-0.00564804,0.00939358,-0.00927467,-0.02722949,-0.04090369,0.01403092,-0.017717,0.00422117,0.05778835,-0.00686683,-0.03947681,0.03804994,0.00651011,0.00209572,0.07277051,0.00270511,0.04304399,0.05541022,-0.00358205,0.00677765,0.00386445,0.00760999,-0.00102556,-0.04684899,-0.00814507,-0.04375743,0.02925089,-0.0587396,-0.00322533,-0.02033294,-0.00850178,-0.01397146,0.02461356,-0.06230678,-0.01135553,-0.02282996,0.0049346,-0.05326992,-0.01325803,-0.00609394,-0.05184304,-0.05017836,-0.00147146,0.00365636,0.02092747,-0.02960761,-0.00621284,-0.04661118,-0.03876338,-0.02782402,0.0088585,0.02223543,0.01831153,0.00165725,-0.00419144,-0.05231867,-0.01331748,-0.03234245,-0.00645065,-0.02639715,-0.02841855,0.0568371,-0.04661118,0.00200654,0.03210464,-0.00285375,-0.04565993,0.01676575,-0.01414982,-0.06611177,0.09512485,-0.04066587,-0.02782402,-0.00731272,0.03008323,-0.01070155,-0.0351962,-0.02508918,-0.00257134,-1.846e-05,-0.00289834,-0.03448276,-0.02259215,-0.01700357,-0.010761,-0.02473246,0.04827586,-0.03614744,0.00026382,-0.02901308,-0.03400714,0.01420928,0.03662307,-0.01938169,0.02021403,0.03448276,0.0313912,0.01985731,0.00419144,-0.00945303,0.0254459,0.01260404,-0.02366231,-0.0009401,0.02675387,-0.0062723,-0.01129608,-0.03424495,0.01082045,0.02627824]

job_search=# \x
Expanded display is off.
job_search=# \x
Expanded display is on.
job_search=# DELETE FROM jobs;
DELETE 10
job_search=# SELECT * FROM jobs LIMIT 5;
(0 rows)

job_search=# SELECT id, title, company, location, created_at FROM jobs LIMIT 10;
-[ RECORD 1 ]---------------------------------------------------------
id         | 23
title      | Database Administrator 1
company    | SLAC National Accelerator Laboratory
location   | Hybrid work in Menlo Park, CA 94025
created_at | 2026-09-27 21:04:23.416639+00
-[ RECORD 2 ]---------------------------------------------------------
id         | 24
title      | 2027 Entry Level Software Engineer
company    | BAE Systems Inc.
location   | San Diego, CA
created_at | 2026-09-27 21:04:23.51233+00
-[ RECORD 3 ]---------------------------------------------------------
id         | 25
title      | Software Developer
company    | Ensymbios, Inc.
location   | Garden Grove, CA 92844
created_at | 2026-09-27 21:04:23.529074+00
-[ RECORD 4 ]---------------------------------------------------------
id         | 26
title      | Senior Database Reliability Engineer (DBRE) (remote work)
company    | CloudLinux
location   | Remote — Yerevan, Armenia (remote worldwide)
created_at | 2026-09-27 21:04:23.547738+00
-[ RECORD 5 ]---------------------------------------------------------
id         | 27
title      | PostgreSQL Database Developer
company    | CGS Federal (Contact Government Services)
location   | Los Angeles, CA
created_at | 2026-09-27 21:04:23.567543+00

job_search=# SELECT description FROM jobs LIMIT 10;
-[ RECORD 1 ]-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
description | Demonstrated experience with the installation and operation of a relational database system and database applications.
-[ RECORD 2 ]-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
description | You don’t see it, but it’s there. Our employees work on the world’s most advanced electronics – from saving emissions in the City of Lights to powering the Mars…
-[ RECORD 3 ]-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
description | Write SQL to retrieve data stored in data warehouses in different environments. The role is based in Garden Grove, California, but requires relocation or travel to unanticipated locations.
-[ RECORD 4 ]-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
description | CloudLinux/TuxCare is a remote-first infrastructure and security company with more than 300 engineers. Its Infrastructure Department operates platforms behind CloudLinux OS, Imunify, KernelCare, TuxCare ELS, and engineering systems. The company is hiring a full-time Senior Database Reliability Engineer for a hands-on production-ownership role in the Infrastructure DBA cell. The engineer will keep critical database services reliable, automate DBA workflows, support engineering teams, and reduce single-person dependency across PostgreSQL, ClickHouse, MongoDB, and Redis. PostgreSQL is the main requirement; ClickHouse is a strong plus but not a day-one blocker. Responsibilities include PostgreSQL HA design and operations, Patroni, PgBouncer, replication, failover, upgrades, vacuum/bloat control, query tuning, locks, indexes, backups, PITR and restore validation; disaster recovery, tested restores, recovery paths, RTO/RPO targets, runbooks and maintenance plans; ClickHouse, MongoDB and Redis support; and automation with Ansible, Terraform/OpenTofu, GitLab CI/CD and scripts. The role also builds DBaaS-style self-service capabilities and improves observability and incident response with Grafana, metrics, logs, SLOs, alert rules and Opsgenie routing. Requirements include deep PostgreSQL experience in business-critical production environments, PostgreSQL internals and operations, MongoDB replica sets and Percona Backup for MongoDB, strong Linux and infrastructure fundamentals, Ansible and scripting, and practical use of Claude and Codex with personal verification of generated SQL, commands, scripts and operational conclusions. The position is fully remote with flexible working hours and offers professional development, vacation, medical insurance, education and other benefits.
-[ RECORD 5 ]-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
description | Support a rapidly growing Data Analytics and Business Intelligence platform by migrating the current Oracle database to a new Microsoft Azure PostgreSQL database and proactively managing database environments. Responsibilities include creating and maintaining technical documentation, translating high-level objectives into technical requirements, ensuring database availability and performance, tuning database performance, monitoring systems for secure services and minimal downtime, and performing rollouts, patching, and upgrades. Work within a structured Agile development approach. Qualifications include a bachelor's degree, US citizenship, and seven years of experience administering PostgreSQL databases in Linux environments. Experience is also required in PostgreSQL setup, monitoring, maintenance, backup and disaster recovery, and migrating Oracle schemas, packages, views, and triggers to PostgreSQL with Ora2Pg. Preferred experience includes data warehouses, AWS RDS for PostgreSQL, Oracle databases, Ora2Pg, and cloud environments such as Azure or AWS.

job_search=# SELECT id, title, company, location, created_at FROM jobs LIMIT 10;
-[ RECORD 1 ]---------------------------------------------------------
id         | 23
title      | Database Administrator 1
company    | SLAC National Accelerator Laboratory
location   | Hybrid work in Menlo Park, CA 94025
created_at | 2026-09-27 21:04:23.416639+00
-[ RECORD 2 ]---------------------------------------------------------
id         | 24
title      | 2027 Entry Level Software Engineer
company    | BAE Systems Inc.
location   | San Diego, CA
created_at | 2026-09-27 21:04:23.51233+00
-[ RECORD 3 ]---------------------------------------------------------
id         | 25
title      | Software Developer
company    | Ensymbios, Inc.
location   | Garden Grove, CA 92844
created_at | 2026-09-27 21:04:23.529074+00
-[ RECORD 4 ]---------------------------------------------------------
id         | 26
title      | Senior Database Reliability Engineer (DBRE) (remote work)
company    | CloudLinux
location   | Remote — Yerevan, Armenia (remote worldwide)
created_at | 2026-09-27 21:04:23.547738+00
-[ RECORD 5 ]---------------------------------------------------------
id         | 27
title      | PostgreSQL Database Developer
company    | CGS Federal (Contact Government Services)
location   | Los Angeles, CA
created_at | 2026-09-27 21:04:23.567543+00

job_search=# \q

What's next:
    Try Docker Debug for seamless, persistent debugging tools in any container or image → docker debug job_search
    Learn more at https://docs.docker.com/go/debug-cli/
PS C:\Users\USER\Desktop\Client works\Percona Writer's Program\semantic-job-search\docker> cd ../
PS C:\Users\USER\Desktop\Client works\Percona Writer's Program\semantic-job-search> code .
PS C:\Users\USER\Desktop\Client works\Percona Writer's Program\semantic-job-search> code .
PS C:\Users\USER\Desktop\Client works\Percona Writer's Program\semantic-job-search>