-- remove if there is a function to remove tables and sequences
DROP FUNCTION IF EXISTS remove_all();

-- create a function that removes tables and sequences
CREATE or replace FUNCTION remove_all() RETURNS void AS $$
DECLARE
    rec RECORD;
    cmd text;
BEGIN
    cmd := '';

    FOR rec IN SELECT
            'DROP SEQUENCE ' || quote_ident(n.nspname) || '.'
                || quote_ident(c.relname) || ' CASCADE;' AS name
        FROM
            pg_catalog.pg_class AS c
        LEFT JOIN
            pg_catalog.pg_namespace AS n
        ON
            n.oid = c.relnamespace
        WHERE
            relkind = 'S' AND
            n.nspname NOT IN ('pg_catalog', 'pg_toast') AND
            pg_catalog.pg_table_is_visible(c.oid)
    LOOP
        cmd := cmd || rec.name;
    END LOOP;

    FOR rec IN SELECT
            'DROP TABLE ' || quote_ident(n.nspname) || '.'
                || quote_ident(c.relname) || ' CASCADE;' AS name
        FROM
            pg_catalog.pg_class AS c
        LEFT JOIN
            pg_catalog.pg_namespace AS n
        ON
            n.oid = c.relnamespace WHERE relkind = 'r' AND
            n.nspname NOT IN ('pg_catalog', 'pg_toast') AND
            pg_catalog.pg_table_is_visible(c.oid)
    LOOP
        cmd := cmd || rec.name;
    END LOOP;

    EXECUTE cmd;
    RETURN;
END;
$$ LANGUAGE plpgsql;
-- call a function that removes tables and sequences
select remove_all();

CREATE TABLE brand (
    brand_id SERIAL NOT NULL,
    founder_id INTEGER NOT NULL,
    brand_name VARCHAR(40) NOT NULL,
    year_of_foundation DATE NOT NULL
);
ALTER TABLE brand ADD CONSTRAINT pk_brand PRIMARY KEY (brand_id);

CREATE TABLE clothing (
    clothing_id SERIAL NOT NULL,
    brand_id INTEGER,
    style_id INTEGER NOT NULL,
    type_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    weather_id INTEGER,
    clothing_name VARCHAR(40) NOT NULL,
    foto BYTEA NOT NULL,
    color VARCHAR(20),
    season VARCHAR(20)
);
ALTER TABLE clothing ADD CONSTRAINT pk_clothing PRIMARY KEY (clothing_id);

CREATE TABLE event (
    event_id SERIAL NOT NULL,
    outfit_id INTEGER,
    event_name VARCHAR(30) NOT NULL
);
ALTER TABLE event ADD CONSTRAINT pk_event PRIMARY KEY (event_id);

CREATE TABLE founder (
    founder_id SERIAL NOT NULL,
    name VARCHAR(30) NOT NULL,
    surname VARCHAR(40) NOT NULL,
    age INTEGER
);
ALTER TABLE founder ADD CONSTRAINT pk_founder PRIMARY KEY (founder_id);

CREATE TABLE outfit (
    outfit_id SERIAL NOT NULL,
    weather_id INTEGER,
    outfit_name VARCHAR(30) NOT NULL,
    favourite BOOLEAN NOT NULL,
    season VARCHAR(20)
);
ALTER TABLE outfit ADD CONSTRAINT pk_outfit PRIMARY KEY (outfit_id);

CREATE TABLE style (
    style_id SERIAL NOT NULL,
    style_name VARCHAR(20) NOT NULL,
    description VARCHAR(256)
);
ALTER TABLE style ADD CONSTRAINT pk_style PRIMARY KEY (style_id);

CREATE TABLE type (
    type_id SERIAL NOT NULL,
    type_name VARCHAR(20) NOT NULL
);
ALTER TABLE type ADD CONSTRAINT pk_type PRIMARY KEY (type_id);

CREATE TABLE userr (
    user_id SERIAL NOT NULL,
    username VARCHAR(30) NOT NULL,
    password VARCHAR(40) NOT NULL
);
ALTER TABLE userr ADD CONSTRAINT pk_userr PRIMARY KEY (user_id);
ALTER TABLE userr ADD CONSTRAINT uc_userr_username UNIQUE (username);

CREATE TABLE weather (
    weather_id SERIAL NOT NULL,
    weather_name VARCHAR(20) NOT NULL
);
ALTER TABLE weather ADD CONSTRAINT pk_weather PRIMARY KEY (weather_id);

CREATE TABLE clothing_outfit (
    clothing_id INTEGER NOT NULL,
    outfit_id INTEGER NOT NULL
);
ALTER TABLE clothing_outfit ADD CONSTRAINT pk_clothing_outfit PRIMARY KEY (clothing_id, outfit_id);

ALTER TABLE brand ADD CONSTRAINT fk_brand_founder FOREIGN KEY (founder_id) REFERENCES founder (founder_id) ON DELETE CASCADE;

ALTER TABLE clothing ADD CONSTRAINT fk_clothing_brand FOREIGN KEY (brand_id) REFERENCES brand (brand_id) ON DELETE CASCADE;
ALTER TABLE clothing ADD CONSTRAINT fk_clothing_style FOREIGN KEY (style_id) REFERENCES style (style_id) ON DELETE CASCADE;
ALTER TABLE clothing ADD CONSTRAINT fk_clothing_type FOREIGN KEY (type_id) REFERENCES type (type_id) ON DELETE CASCADE;
ALTER TABLE clothing ADD CONSTRAINT fk_clothing_userr FOREIGN KEY (user_id) REFERENCES userr (user_id) ON DELETE CASCADE;
ALTER TABLE clothing ADD CONSTRAINT fk_clothing_weather FOREIGN KEY (weather_id) REFERENCES weather (weather_id) ON DELETE CASCADE;

ALTER TABLE event ADD CONSTRAINT fk_event_outfit FOREIGN KEY (outfit_id) REFERENCES outfit (outfit_id) ON DELETE CASCADE;

ALTER TABLE outfit ADD CONSTRAINT fk_outfit_weather FOREIGN KEY (weather_id) REFERENCES weather (weather_id) ON DELETE CASCADE;

ALTER TABLE clothing_outfit ADD CONSTRAINT fk_clothing_outfit_clothing FOREIGN KEY (clothing_id) REFERENCES clothing (clothing_id) ON DELETE CASCADE;
ALTER TABLE clothing_outfit ADD CONSTRAINT fk_clothing_outfit_outfit FOREIGN KEY (outfit_id) REFERENCES outfit (outfit_id) ON DELETE CASCADE;

