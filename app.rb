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
  get "/users/new" do
    erb :new_user
  end

  #CREATE
  post "/users" do
    @users.create_new_user_in_dbase(params[:email], params[:password], params[:profile_picture])
    current_user = @users.find_user(params[:email], params[:password])
    set_the_session(current_user)
    flash[:notice] = "Thanks for registering #{session[:email]}. You are now logged in."
    redirect "/"
  end

  post "/login" do
    current_user = @users.find_user(params[:email], params[:password])
    if current_user != nil
      set_the_session(current_user)
      flash[:notice] = "Welcome #{session[:email]}"
    else
      flash[:notice] = "The credentials you entered are incorrect.  Please try again."
    end
    redirect "/"
  end

  post "/logout" do
    session.delete(:user_id)
    session.delete(:email)
    redirect "/"
  end

  def set_the_session(current_user)
    session[:user_id] = current_user["id"]
    session[:email] = current_user["email"]
  end

end
