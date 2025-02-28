class AddCaloriesToMeals < ActiveRecord::Migration[7.1]
  def change
    add_column :meals, :calories, :integer
  end
end
