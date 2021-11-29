CREATE TABLE IF NOT EXISTS files (
    id serial PRIMARY KEY,
    uuid uuid UNIQUE NOT NULL DEFAULT uuid_generate_v4 (),
    etag TEXT UNIQUE,
    filetype TEXT NOT NULL,
    filename TEXT NOT NULL,
    filepath TEXT UNIQUE NOT NULL,
    inserted_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    content_type TEXT NOT NULL
);

CREATE INDEX files_idx ON files (filetype);

CREATE TRIGGER 
    files_timestamps_update_trigger
        BEFORE UPDATE OR INSERT
            ON files
            FOR EACH ROW
            EXECUTE PROCEDURE timestamp_update_func();
