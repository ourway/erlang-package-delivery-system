CREATE OR REPLACE FUNCTION timestamp_update_func()
    RETURNS trigger AS
        $$
            BEGIN
                NEW.updated_at = now();
                IF OLD.inserted_at IS NULL THEN
                    NEW.inserted_at = now();
                END IF;
                RETURN NEW;
            END;
        $$
LANGUAGE 'plpgsql';
