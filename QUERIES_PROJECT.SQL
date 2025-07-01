-- 1.Find Top Rating for Every Recipe

SELECT 
    r.recipe_id, 
    r.name AS recipe_name, 
    MAX(rr.rating) AS top_rating
FROM 
    rp.recipe r
JOIN 
    rp.rp_rating rr ON r.recipe_id = rr.recipe_id
GROUP BY 
    r.recipe_id, r.name;


--2. Find Maximum Rating for Recipes

SELECT 
    r.recipe_id, 
    r.name AS recipe_name, 
    MAX(rr.rating) AS max_rating
FROM 
    rp.recipe r
JOIN 
    rp.rp_rating rr ON r.recipe_id = rr.recipe_id
GROUP BY 
    r.recipe_id, r.name;


-- 3. What Are the Top 5 Ingredients Used in the Most Recipes
SELECT 
    i.ingre_name, 
    COUNT(ri.recipe_id) AS recipe_count
FROM 
    rp.ingredient i
JOIN 
    rp.rp_ingre ri ON i.ingre_id = ri.ingre_id
GROUP BY 
    i.ingre_name
ORDER BY 
    recipe_count DESC
LIMIT 5;


-- 4. Find Recipes Available in All Seasons
SELECT 
    r.recipe_id, 
    r.name AS recipe_name
FROM 
    rp.recipe r
JOIN 
    rp.spec_rp sr ON r.recipe_id = sr.recipe_id
JOIN 
    rp.season s ON sr.season_id = s.season_id
GROUP BY 
    r.recipe_id, r.name
HAVING 
    COUNT(DISTINCT s.season_id) = (SELECT COUNT(*) FROM rp.season);



-- 5. Find Ingredient with Average Nutritional Content in Recipes
SELECT 
    i.ingre_name, 
    AVG(i.energy) AS avg_energy,
    AVG(i.fat) AS avg_fat,
    AVG(i.carbohydrates) AS avg_carbohydrates,
    AVG(i.protein) AS avg_protein
FROM 
    rp.ingredient i
JOIN 
    rp.rp_ingre ri ON i.ingre_id = ri.ingre_id
GROUP BY 
    i.ingre_name;



-- 6. Find Recipe with Most Ingredients
SELECT 
    r.recipe_id, 
    r.name AS recipe_name, 
    COUNT(ri.ingre_id) AS ingredient_count
FROM 
    rp.recipe r
JOIN 
    rp.rp_ingre ri ON r.recipe_id = ri.recipe_id
GROUP BY 
    r.recipe_id, r.name
ORDER BY 
    ingredient_count DESC
LIMIT 1;


-- 7. Find Dish Types with Recipes Available in More Seasons Than the Average Across All Dish Types
SELECT 
    dt.name AS dish_type,
    COUNT(DISTINCT sr.season_id) AS seasons_count
FROM 
    rp.dishtype dt
JOIN 
    rp.spec_rp sr ON dt.dishtype_id = sr.dishtype_id
JOIN 
    rp.recipe r ON sr.recipe_id = r.recipe_id
JOIN 
    rp.season s ON sr.season_id = s.season_id
GROUP BY 
    dt.name
HAVING 
    COUNT(DISTINCT sr.season_id) > (
        SELECT AVG(sub_season_count) 
        FROM (
            SELECT COUNT(DISTINCT sr.season_id) AS sub_season_count
            FROM rp.spec_rp sr
            GROUP BY sr.dishtype_id
        ) AS avg_seasons
    );



-- 8. Retrieve Dish Types with Total Recipe Count Above the Average for All Dish Types
SELECT 
    dt.name AS dish_type,
    COUNT(r.recipe_id) AS recipe_count
FROM 
    rp.dishtype dt
JOIN 
    rp.spec_rp sr ON dt.dishtype_id = sr.dishtype_id
JOIN 
    rp.recipe r ON sr.recipe_id = r.recipe_id
GROUP BY 
    dt.name
HAVING 
    COUNT(r.recipe_id) > (
        SELECT AVG(sub_recipe_count) 
        FROM (
            SELECT COUNT(r.recipe_id) AS sub_recipe_count
            FROM rp.dishtype dt
            JOIN rp.spec_rp sr ON dt.dishtype_id = sr.dishtype_id
            JOIN rp.recipe r ON sr.recipe_id = r.recipe_id
            GROUP BY dt.name
        ) AS avg_recipe_count
    );


-- 9. Find Recipes with Ingredients Containing High Protein Content
SELECT 
    r.recipe_id, 
    r.name AS recipe_name
FROM 
    rp.recipe r
JOIN 
    rp.rp_ingre ri ON r.recipe_id = ri.recipe_id
JOIN 
    rp.ingredient i ON ri.ingre_id = i.ingre_id
WHERE 
    i.protein > (SELECT AVG(protein) FROM rp.ingredient);



-- 10. List Users Who Have Rated the Most Recipes
SELECT 
    rr.user_id,
    COUNT(DISTINCT rr.recipe_id) AS rated_recipe_count
FROM 
    rp.rp_rating rr
GROUP BY 
    rr.user_id
ORDER BY 
    rated_recipe_count DESC
LIMIT 1;



-- 11. List Recipes and Their Ratings with User Information
SELECT 
    r.recipe_id, 
    r.name AS recipe_name, 
    rr.rating, 
    u.rp_user, 
    u.user_name
FROM 
    rp.recipe r
JOIN 
    rp.rp_rating rr ON r.recipe_id = rr.recipe_id
JOIN 
    rp.rp_user u ON rr.user_id = u.rp_user;



-- 12. Retrieve Ingredients That Contribute More Calories Than the Average Calories in All Recipes
SELECT 
    i.ingre_name
FROM 
    rp.ingredient i
JOIN 
    rp.rp_ingre ri ON i.ingre_id = ri.ingre_id
GROUP BY 
    i.ingre_name
HAVING 
    SUM(i.energy) > (SELECT AVG(total_energy) FROM 
                     (SELECT SUM(i.energy) AS total_energy
                      FROM rp.recipe r
                      JOIN rp.rp_ingre ri ON r.recipe_id = ri.recipe_id
                      JOIN rp.ingredient i ON ri.ingre_id = i.ingre_id
                      GROUP BY r.recipe_id) AS avg_energy);



-- 13. Retrieve Recipes with Above-Average Preparation Time
SELECT 
    r.recipe_id, 
    r.name AS recipe_name, 
    r.prep_time
FROM 
    rp.recipe r
WHERE 
    r.prep_time > (SELECT AVG(prep_time) FROM rp.recipe);



-- 14. Find Dish Types with Total Recipes and Average Prep Time
SELECT 
    dt.name AS dish_type,
    COUNT(r.recipe_id) AS total_recipes,
    AVG(r.prep_time) AS avg_prep_time
FROM 
    rp.dishtype dt
JOIN 
    rp.spec_rp sr ON dt.dishtype_id = sr.dishtype_id
JOIN 
    rp.recipe r ON sr.recipe_id = r.recipe_id
GROUP BY 
    dt.name
ORDER BY 
    avg_prep_time;



-- 15. Retrieve Recipes with a Specific Dish Type and Season
SELECT 
    r.recipe_id, 
    r.name AS recipe_name
FROM 
    rp.recipe r
JOIN 
    rp.spec_rp sr ON r.recipe_id = sr.recipe_id
JOIN 
    rp.dishtype dt ON sr.dishtype_id = dt.dishtype_id
JOIN 
    rp.season s ON sr.season_id = s.season_id
WHERE 
    dt.name = 'Specific Dish Type' AND s.name = 'Specific Season';



-- 16. Count of Recipes by Dietary Classification Based on Nutritional Criteria
SELECT 
    diet_type,
    COUNT(r.recipe_id) AS recipe_count
FROM (
    SELECT recipe_id, 
        CASE 
            WHEN total_energy < 500 THEN 'Low Energy'
            WHEN total_fat < 20 THEN 'Low Fat'
            WHEN total_carbohydrates < 100 THEN 'Low Carbohydrates'
            WHEN total_protein > 50 THEN 'High Protein'
            ELSE 'Balanced Diet'
        END AS diet_type
    FROM rp.recipe r
    JOIN rp.rp_ingre ri ON r.recipe_id = ri.recipe_id
    JOIN rp.ingredient i ON ri.ingre_id = i.ingre_id
) AS dietary_info
GROUP BY diet_type;



-- 17. Average Nutrition Per Time of Day
SELECT 
    tod.name AS time_of_day,
    AVG(i.energy) AS avg_energy,
    AVG(i.fat) AS avg_fat,
    AVG(i.carbohydrates) AS avg_carbohydrates,
    AVG(i.protein) AS avg_protein
FROM 
    rp.tod tod
JOIN 
    rp.spec_rp sr ON tod.tod_id = sr.tod_id
JOIN 
    rp.recipe r ON sr.recipe_id = r.recipe_id
JOIN 
    rp.rp_ingre ri ON r.recipe_id = ri.recipe_id
JOIN 
    rp.ingredient i ON ri.ingre_id = i.ingre_id
GROUP BY 
    tod.name;




-- 18. Which Recipes Have Been Rated by the Highest Number of Unique Users?
SELECT 
    r.recipe_id, 
    r.name AS recipe_name,
    COUNT(DISTINCT rr.user_id) AS unique_user_count
FROM 
    rp.recipe r
JOIN 
    rp.rp_rating rr ON r.recipe_id = rr.recipe_id
GROUP BY 
    r.recipe_id, r.name
ORDER BY 
    unique_user_count DESC
LIMIT 1;




-- 19. Recipes with Above-Average Energy Content
SELECT 
    r.recipe_id,
    r.name AS recipe_name,
    SUM(i.energy) AS total_energy
FROM rp.recipe r
JOIN rp.rp_ingre ri ON r.recipe_id = ri.recipe_id
JOIN rp.ingredient i ON ri.ingre_id = i.ingre_id
GROUP BY r.recipe_id, r.name
HAVING SUM(i.energy) > (
    SELECT AVG(total_energy)
    FROM (
        SELECT SUM(i.energy) AS total_energy
        FROM rp.recipe r
        JOIN rp.rp_ingre ri ON r.recipe_id = ri.recipe_id
        JOIN rp.ingredient i ON ri.ingre_id = i.ingre_id
        GROUP BY r.recipe_id
    ) AS recipe_energy
);



-- 20. Find Users Who Have Rated All Recipes
SELECT 
    u.user_name,
    COUNT(DISTINCT rr.recipe_id) AS rated_recipes_count
FROM 
    rp.rp_user u
JOIN 
    rp.rp_rating rr ON u.rp_user = rr.user_id
JOIN 
    rp.recipe r ON rr.recipe_id = r.recipe_id
GROUP BY 
    u.rp_user
HAVING 
    COUNT(DISTINCT rr.recipe_id) = (SELECT COUNT(*) FROM rp.recipe);





