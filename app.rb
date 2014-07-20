require "sinatra"
require "active_record"
require_relative "lib/users"

require "rack-flash"
require "gschool_database_connection"

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @users = Users.new(GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"]))
  end

  get "/" do
  erb :home
  end

  #NEW
  get "/new_user" do
    erb :new_user
  end

  #CREATE
  post "/users" do
    email = params[:email]
    password = params[:password]
    profile_picture = params[:profile_picture]
    @users.create_new_user_in_dbase(email, password, profile_picture)
    current_user = @users.find_by_email(email)
    session[:user_id] = current_user["id"]
    session[:email] = current_user["email"]
    flash[:notice] = "Thanks for registering #{session[:email]}. You are now logged in."
    redirect "/"
  end


end
