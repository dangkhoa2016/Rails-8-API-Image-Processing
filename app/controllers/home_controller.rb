class HomeController < ApplicationController
  def index
    render json: { message: "Welcome to Rails v8 API Image Processing with JWT Authentication" }
  end
end
