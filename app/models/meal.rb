# == Schema Information
#
# Table name: meals
#
#  id          :bigint           not null, primary key
#  calories    :integer
#  carbs       :integer
#  description :text
#  fat         :integer
#  protein     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Meal < ApplicationRecord
end
