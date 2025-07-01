CREATE OR REPLACE FUNCTION check_rating()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.rating < 0 OR NEW.rating > 10 THEN
        RAISE EXCEPTION 'Rating must be between 0 and 10';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_rating
BEFORE INSERT OR UPDATE ON rp.rp_rating
FOR EACH ROW
EXECUTE FUNCTION check_rating();

INSERT INTO rp.rp_rating (recipe_id, user_id, rating, review)
VALUES (1, 102, 15, 'Too salty');  -- This will raise an exception because 15 is outside the allowed range.






CREATE OR REPLACE FUNCTION update_recipe_nutrition()
RETURNS TRIGGER AS $$
BEGIN
    -- Refresh the recipe nutritional information by calling the diet_req function
    PERFORM * FROM rp.diet_req(NEW.recipe_id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER recalculate_nutrition_on_change
AFTER INSERT OR DELETE ON rp.rp_ingre
FOR EACH ROW
EXECUTE FUNCTION update_recipe_nutrition();






CREATE OR REPLACE FUNCTION prevent_deletion_of_used_ingredient()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM rp.rp_ingre WHERE ingre_id = OLD.ingre_id) THEN
        RAISE EXCEPTION 'Cannot delete ingredient because it is associated with one or more recipes';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER no_delete_used_ingredient
BEFORE DELETE ON rp.ingredient
FOR EACH ROW
EXECUTE FUNCTION prevent_deletion_of_used_ingredient();








CREATE OR REPLACE FUNCTION prevent_duplicate_ingredient_names()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM rp.ingredient WHERE ingre_name = NEW.ingre_name) THEN
        RAISE EXCEPTION 'Ingredient with name % already exists', NEW.ingre_name;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER unique_ingredient_name
BEFORE INSERT ON rp.ingredient
FOR EACH ROW
EXECUTE FUNCTION prevent_duplicate_ingredient_names();



INSERT INTO rp.ingredient (ingre_id, ingre_name, energy, fat, carbohydrates, protein)
VALUES (9803, 'Olive Oil', 884, 100, 0, 0);




CREATE OR REPLACE FUNCTION cascade_delete_recipe_ratings()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM rp.rp_rating WHERE recipe_id = OLD.recipe_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_related_ratings
AFTER DELETE ON rp.recipe
FOR EACH ROW
EXECUTE FUNCTION cascade_delete_recipe_ratings();