BEGIN;
------------------------------------------------
----  Generated expression
/*
CREATE TABLE IF NOT EXISTS t_test (
	id SERIAL PRIMARY KEY,
	a INT,
	b INT,
	c INT GENERATED ALWAYS AS (a*b) STORED 
);

INSERT INTO t_test (a, b) VALUES (10, 20);



---- You can get rid of the expression:
ALTER TABLE t_test ALTER COLUMN c DROP EXPRESSION;

-- deduplication of b-tree indexes:
create table if not exists tab (
id serial primary key,
a int,
b int
);
insert into tab select id, 1 from generate_series(1, 5000000) as id;

CREATE INDEX idx_a ON tab (a);
CREATE INDEX idx_b ON tab (b);
*/

select * from tab;





COMMIT;
