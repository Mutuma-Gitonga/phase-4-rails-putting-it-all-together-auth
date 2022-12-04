class RecipesController < ApplicationController
  wrap_parameters format: []
  before_action :authorize

  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity 

  def index 
    recipes = Recipe.all 
    render json: recipes, include: {user: {only: [:username, :image_url, :bio]}}, status: :ok 
  end

  def create 
    user = User.find_by(id: session[:user_id])

    recipe = user.recipes.create!(recipe_params)

    render json: recipe, include: {user: {only: [:username, :image_url, :bio]}}, status: :created
  end

  private 
  def authorize
    return render json: { errors: ["Unauthorized! Login first"]}, status: :unauthorized unless session.include? :user_id
  end

  def recipe_params
    params.permit(:title, :instructions, :minutes_to_complete) 
  end

  def render_unprocessable_entity(invalid)
    render json: {errors: invalid.record.errors.full_messages}, status: :unprocessable_entity
  end
end
