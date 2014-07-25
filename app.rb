require "sinatra"
require "active_record"
require_relative "lib/users"
require_relative "lib/charities"
require_relative "lib/mvps"
require_relative "lib/accounts"
require_relative "lib/deposits"

require "rack-flash"
require "gschool_database_connection"

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    dbase_argument = GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
    @users = Users.new(dbase_argument)
    @charities = Charities.new(dbase_argument)
    @mvps = Mvps.new(dbase_argument)
    @deposits = Deposits.new(dbase_argument)
    @accounts = Accounts.new(dbase_argument)
  end

  get "/" do
  erb :home
  end

  #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  #NEW - DEPOSITS
  get "/deposits/new/:id" do
    if @accounts.find_by_id(params[:id]) != nil
      account = @accounts.find_by_id(params[:id])
      if session[:user_id] == account["user_id"]
        erb :new_deposit, locals: {account: account}
      else
        flash[:notice] = "You are not authorized to visit this page"
        redirect "/"
      end
    else
      flash[:notice] = "You are not authorized to visit this page"
      redirect "/"
    end
  end

  #CREATE - DEPOSITS
  post "/deposits" do
    @deposits.create_in_dbase(params[:account_id], params[:amount], params[:cc_number], params[:exp_date], params[:name_on_card], params[:radio_cc_type])
    deposit = @deposits.find_most_recent(params[:account_id])

    flash[:notice] = "Thank you for depositing $#{deposit["amount"]} into your account"

    redirect "/users/#{session[:user_id]}"
  end

  #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
    if current_user["is_admin"] == "t"

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
      redirect "/users/#{session[:user_id]}"
    else
      flash[:notice] = "The credentials you entered are incorrect.  Please try again."
      redirect "/"
    end
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
    erb :new_user, layout: false
  end

  #CREATE - USER
  post "/users" do
    @users.create_new_user_in_dbase(params[:email], params[:password], params[:profile_picture])
    current_user = @users.find_user(params[:email], params[:password])
    set_the_session(current_user)
    @accounts.create_in_dbase(session[:user_id])
    flash[:notice] = "Thanks for registering #{session[:email]}. You are now logged in."
    redirect "/users/#{session[:user_id]}"
  end

  #EDIT - USER
  get "/users/:id/edit" do
    if session[:user_id] == params[:id]
      current_user = @users.find_user_by_id(session[:user_id])
      erb :edit_user, locals: {current_user: current_user}, layout: false
    else
      flash[:notice] = "You are not authorized to visit this page"
      redirect "/"
    end
    end

  #UPDATE - USER
  patch "/users/:id" do
    @users.update_user_info(params[:id].to_i, params[:password], params[:profile_picture])
    flash[:notice] = "Your changes have been saved"
    redirect "/users/#{session[:user_id]}"
  end

  #SHOW - USER
  get "/users/:id" do
    if session[:user_id] == params[:id]
      account = @accounts.find_by_user_id(session[:user_id])
      erb :show_user, locals: {account: account}
    else
      flash[:notice] = "You are not authorized to visit this page"
      redirect "/"
    end
  end

  #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


  def set_the_session(current_user)
    session[:user_id] = current_user["id"]
    session[:email] = current_user["email"]
  end

end
