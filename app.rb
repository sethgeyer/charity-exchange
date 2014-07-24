require "sinatra"
require "active_record"
require_relative "lib/users"
require_relative "lib/charities"
require_relative "lib/mvps"

require "rack-flash"
require "gschool_database_connection"

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @users = Users.new(GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"]))
    @charities = Charities.new(GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"]))
    @mvps = Mvps.new(GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"]))

  end

  get "/" do
  erb :home
  end

  #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  #NEW - CHARITY
  get "/charities/new" do
    erb :new_charity
  end

  #CREATE - CHARITY
  post "/charities" do
    @charities.add_to_dbase(params[:name], params[:tax_id], params[:poc], params[:poc_email], params[:status])
    flash[:notice] = "Thanks for applying"
    redirect "/charities"
  end

  #INDEX - CHARITY
  get "/charities" do
    charities = @charities.find_all
    erb :index_charity, locals: {charities: charities}
  end



  #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  get "/mvps" do
    mvps = @mvps.find_all
    current_user = @users.find_user_by_id(session[:user_id])
    erb :index_mvp, locals: {mvps: mvps, current_user: current_user}
  end

  get "/mvps/new" do
    current_user = @users.find_user_by_id(session[:user_id])
    if current_user["is_admin"] == true

      erb :new_mvp
    else
      flash[:notice] = "You don't have permissions to add an MVP"
      redirect "/mvps"
    end
  end

  post "/mvps" do
    @mvps.add_to_dbase(params[:date], params[:description])
    redirect "/mvps"
  end


  #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  #LOGIN
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

  #LOGOUT
  post "/logout" do
    session.delete(:user_id)
    session.delete(:email)
    redirect "/"
  end

  #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  #NEW - USER
  get "/users/new" do
    erb :new_user
  end

  #CREATE - USER
  post "/users" do
    @users.create_new_user_in_dbase(params[:email], params[:password], params[:profile_picture])
    current_user = @users.find_user(params[:email], params[:password])
    set_the_session(current_user)
    flash[:notice] = "Thanks for registering #{session[:email]}. You are now logged in."
    redirect "/"
  end

  #EDIT - USER
  get "/users/edit" do
    current_user = @users.find_user_by_id(session[:user_id])
    erb :edit_user, locals: {current_user: current_user}
  end

  #UPDATE - USER
  patch "/users/:id" do
    @users.update_user_info(params[:id].to_i, params[:password], params[:profile_picture])
    flash[:notice] = "Your changes have been saved"
    redirect "/"
  end

  #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


  def set_the_session(current_user)
    session[:user_id] = current_user["id"]
    session[:email] = current_user["email"]
  end

end
