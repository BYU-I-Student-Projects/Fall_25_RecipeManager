# Recipe Management App 🍳

A mobile recipe management application built with Flutter for CSE 310: Applied Programming. This app allows users to create, organize, and plan their meals, manage a pantry, and generate shopping lists.

---

## ✨ Features

### Recipe Management
- **Create, View, Edit & Delete** personal recipes.
- Add fields for ingredients, instructions, cookware, cook time, calories, and background info.
- Attach **private notes** to any recipe.
- Rate recipes on a **5-star scale**.
- Categorize recipes with custom **tags** (e.g., "Breakfast", "Quick to Make").
- Toggle ingredient units between **imperial and metric**.

### Organization
- Create custom **recipe collections** (e.g., "Dad's Favorites").
- View dynamic collections based on shared tags.

### Shopping & Pantry
- Maintain a digital **pantry** of owned ingredients.
- Manually manage a **shopping list**.
- Add all ingredients from a recipe to the shopping list, automatically omitting items already in the pantry.

### User Accounts
- Create a user account and log in.
- View and customize a **user profile** with a background image.
- Set app-wide preferences, like a default unit system.

### Meal Planner
- View a meal plan in a **calendar format** (day, week, month).
- Assign recipes to specific meal slots (Breakfast, Lunch, Dinner) on any day.

---

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Backend**: Supabase (Database, Authentication, Storage)