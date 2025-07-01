CREATE VIEW rp.view_recipe_ingredients AS
SELECT 
    r.recipe_id, 
    r.name AS recipe_name, 
    i.ingre_name, 
    i.energy, 
    i.fat, 
    i.carbohydrates, 
    i.protein
FROM 
    rp.recipe r
JOIN 
    rp.rp_ingre ri ON r.recipe_id = ri.recipe_id
JOIN 
    rp.ingredient i ON ri.ingre_id = i.ingre_id;




SELECT 
    recipe_name
FROM 
    rp.recipe_category_details
WHERE 
    dish_type = 'Dessert' AND season = 'Summer';





CREATE VIEW rp.recipe_category_details AS
SELECT 
    r.recipe_id,
    r.name AS recipe_name,
    dt.name AS dish_type,
    tod.name AS time_of_day,
    s.name AS season
FROM 
    rp.recipe r
LEFT JOIN 
    rp.spec_rp sr ON r.recipe_id = sr.recipe_id
LEFT JOIN 
    rp.dishtype dt ON sr.dishtype_id = dt.dishtype_id
LEFT JOIN 
    rp.tod tod ON sr.tod_id = tod.tod_id
LEFT JOIN 
    rp.season s ON sr.season_id = s.season_id;







CREATE VIEW rp.recipe_ingredients AS
SELECT 
    r.recipe_id,
    r.name AS recipe_name,
    i.ingre_id,
    i.ingre_name,
    i.energy,
    i.fat,
    i.carbohydrates,
    i.protein
FROM 
    rp.recipe r
JOIN 
    rp.rp_ingre ri ON r.recipe_id = ri.recipe_id
JOIN 
    rp.ingredient i ON ri.ingre_id = i.ingre_id;




SELECT 
    user_name, 
    recipe_name, 
    rating
FROM 
    rp.user_subscriptions_ratings
WHERE 
    rating >= 8;







CREATE VIEW rp.user_subscriptions_ratings AS
SELECT 
    u.rp_user AS user_id,
    u.user_name,
    u.contact,
    u.start_date,
    u.end_date,
    s.time_span,
    s.expense,
    rr.recipe_id,
    r.name AS recipe_name,
    rr.rating,
    rr.review
FROM 
    rp.rp_user u
LEFT JOIN 
    rp.subscribe s ON u.sub_id = s.sub_id
LEFT JOIN 
    rp.rp_rating rr ON u.rp_user = rr.user_id
LEFT JOIN 
    rp.recipe r ON rr.recipe_id = r.recipe_id;

SELECT 
    recipe_name, 
    avg_rating
FROM 
    rp.recipe_ratings_summary
WHERE 
    avg_rating > 7;