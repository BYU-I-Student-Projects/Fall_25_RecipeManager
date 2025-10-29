-- 1. Temporarily disable RLS for the 'recipes' table
--    This allows the script to insert data without restrictions.
ALTER TABLE public.recipes DISABLE ROW LEVEL SECURITY;

-- 2. Insert dummy recipes
--    (Add as many as you want)
INSERT INTO public.recipes
  (name, pre-time-min, cook-time-min, instructions, cal_per_serv, cuisine, ingredients, servings, diet_restric)
VALUES
  (
    'Classic Scrambled Eggs',
    10,
    5,
    '1. Crack eggs into a bowl. 2. Whisk with milk, salt, and pepper. 3. Melt butter in a non-stick skillet over medium-low heat. 4. Pour in egg mixture and cook, stirring gently, until set.',
    250,
    'American',
    'Eggs, Milk, Butter, Salt, Pepper',
    '2 servings',
    'Gluten-Free, Vegetarian, Keto'
  ),
  
-- 3. (Optional) Insert dummy ingredients
-- ALTER TABLE public.ingredients DISABLE ROW LEVEL SECURITY;
-- INSERT INTO public.ingredients (name, category)
-- VALUES
--   ('Egg', 'Dairy'),
--   ('Milk', 'Dairy'),
--   ('Bread', 'Bakery'),
--   ('Cheddar Cheese', 'Dairy');
-- ALTER TABLE public.ingredients ENABLE ROW LEVEL SECURITY;


-- 4. Re-enable RLS for the 'recipes' table
--    This is crucial to ensure your security policies are active.
ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;