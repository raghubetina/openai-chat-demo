class MealsController < ApplicationController
  def index
    matching_meals = Meal.all

    @list_of_meals = matching_meals.order({ :created_at => :desc })

    render({ :template => "meals/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_meals = Meal.where({ :id => the_id })

    @the_meal = matching_meals.at(0)

    render({ :template => "meals/show" })
  end

  def create
    the_meal = Meal.new
    the_meal.description = params.fetch("query_description")

    # Use OpenAI to get the values for fat, carbs, protein, calories

    c = OpenAI::Chat.new
    c.system("You are a nutritionist. Estimate the calories, carbs, protein, and fat in the user's meal.")
    c.schema = '{
      "name": "nutrition_info",
      "strict": true,
      "schema": {
        "type": "object",
        "properties": {
          "calories": {
            "type": "number",
            "description": "The total calories in the food item."
          },
          "fat": {
            "type": "number",
            "description": "Total fat content in grams."
          },
          "carbs": {
            "type": "number",
            "description": "Total carbohydrates in grams."
          },
          "protein": {
            "type": "number",
            "description": "Total protein content in grams."
          }
        },
        "required": [
          "calories",
          "fat",
          "carbs",
          "protein"
        ],
        "additionalProperties": false
      }
    }'

    c.user(the_meal.description)
    meal_info = c.assistant!

    the_meal.fat = meal_info.fetch("fat")
    the_meal.carbs = meal_info.fetch("carbs")
    the_meal.protein = meal_info.fetch("protein")
    the_meal.calories = meal_info.fetch("calories")

    if the_meal.valid?
      the_meal.save
      redirect_to("/meals", { :notice => "Meal created successfully." })
    else
      redirect_to("/meals", { :alert => the_meal.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_meal = Meal.where({ :id => the_id }).at(0)

    the_meal.description = params.fetch("query_description")
    the_meal.fat = params.fetch("query_fat")
    the_meal.carbs = params.fetch("query_carbs")
    the_meal.protein = params.fetch("query_protein")

    if the_meal.valid?
      the_meal.save
      redirect_to("/meals/#{the_meal.id}", { :notice => "Meal updated successfully."} )
    else
      redirect_to("/meals/#{the_meal.id}", { :alert => the_meal.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_meal = Meal.where({ :id => the_id }).at(0)

    the_meal.destroy

    redirect_to("/meals", { :notice => "Meal deleted successfully."} )
  end
end
