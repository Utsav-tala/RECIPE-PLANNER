create schema rp;
create table rp.cate(
	cate_id decimal(9,0) primary key,
	name varchar(20) not null
);
create table rp.dishtype(
	dishtype_id decimal(9,0) primary key,
	name varchar(20) not null,
	cate_id1 decimal(9,0) references rp.cate(cate_id) on delete restrict on update cascade
);
create table rp.tod(
	tod_id decimal(9,0) primary key,
	name varchar(20) not null,
	cate_id2 decimal(9,0) references rp.cate(cate_id)on delete restrict on update cascade
);
create table rp.season(
	season_id decimal(9,0) primary key,
	name varchar(20) not null,
	cate_id3 decimal(9,0) references rp.cate(cate_id)on delete restrict on update cascade
);
create table rp.recipe(
	recipe_id decimal(9,0) primary key,
	name varchar(20) not null,
	instruction varchar(200) not null,
	prep_time integer not null
);

ALTER TABLE rp.recipe
ALTER COLUMN instruction TYPE TEXT;

ALTER TABLE rp.recipe
ALTER COLUMN name TYPE varchar(200);
create table rp.spec_rp(
	recipe_id decimal(9,0) references rp.recipe(recipe_id) on delete cascade on update cascade,
	dishtype_id decimal(9,0) references rp.dishtype(dishtype_id) on delete set null on update cascade,
	tod_id decimal(9,0) references rp.tod(tod_id) on delete set null on update cascade,
	season_id decimal(9,0) references rp.season(season_id) on delete set null on update cascade
);

create table rp.ingredient(
	ingre_id decimal(4,0) primary key,
	ingre_name varchar(20) not null ,
	energy numeric(5,0) not null,
	fat numeric(3,0) not null,
	carbohydrates numeric(5,0) not null,
	protein numeric(5,0) not null
);



create table rp.rp_ingre(
	recipe_id decimal(9,0) references rp.recipe(recipe_id)on delete set null on update cascade,
	ingre_id decimal(4,0) references rp.ingredient(ingre_id)on delete set null on update cascade
);

CREATE OR REPLACE FUNCTION rp.diet_req(recipe_id_param decimal(9,0))
RETURNS TABLE (
    total_energy numeric(5,0),
    total_fat numeric(3,0),
    total_carbohydrates numeric(5,0),
    total_protein numeric(5,0)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        SUM(ingredient.energy) AS total_energy,
        SUM(ingredient.fat) AS total_fat,
        SUM(ingredient.carbohydrates) AS total_carbohydrates,
        SUM(ingredient.protein) AS total_protein
    FROM rp.ingredient
    JOIN rp.rp_ingre ON rp.rp_ingre.ingre_id = rp.ingredient.ingre_id
    WHERE rp.rp_ingre.recipe_id = recipe_id_param;
END;
$$ LANGUAGE plpgsql;
create table rp.subscribe(
	sub_id decimal(2,0) not null primary key,
	time_span numeric(2) not null unique,
	expense numeric(3) not null unique
);
create table rp.rp_user(
	rp_user decimal(9,0) primary key,
	user_name varchar(20) not null,
	contact numeric(10) not null,
	user_pw varchar(8) not null,
	sub_id decimal(2,0) references rp.subscribe(sub_id)on update cascade,
	start_date date,
	end_date date
);
create table rp.rp_rating(
	recipe_id decimal(9,0) references rp.recipe(recipe_id)on delete cascade on update cascade,
	user_id decimal(9,0) references rp.rp_user(rp_user)on update cascade,
	rating smallint check (rating>=0 and rating<=10), 
	review varchar(50)
);
ALTER TABLE rp.subscribe
ALTER COLUMN time_span TYPE NUMERIC(3);
