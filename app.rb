require "sinatra"
require "active_record"
require_relative "lib/user"
require_relative "lib/charity"
require_relative "lib/mvp"
require_relative "lib/account"
require_relative "lib/deposit"
require_relative "lib/distribution"
require_relative "lib/proposed_wager"
require_relative "lib/connection"
require "rack-flash"
require "gschool_database_connection"

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    dbase_argument = GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
    @users = User.new(dbase_argument)
    @charities = Charity.new(dbase_argument)
    @mvps = Mvp.new(dbase_argument)
    @deposits = Deposit.new(dbase_argument)
    @accounts = Account.new(dbase_argument)
    @distributions = Distribution.new(dbase_argument)
    @proposed_wagers = ProposedWager.new(dbase_argument)

  end

  get "/" do
  erb :home
  end

  #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  #NEW - PROPOSED_WAGERS
  get "/proposed_wagers/new" do
    @list_of_users = @users.all_but_current_user(session[:user_id])
    render_page_or_redirect_to_homepage(session[:user_id], "new_proposed_wager")
  end

  post "/proposed_wagers" do
    @proposed_wagers.create_in_dbase(session[:user_id], params[:title], params[:date_of_wager], params[:details], params[:amount], params[:wageree_id])
    puts "*" * 50
    wageree = @users.find_user_by_id(params[:wageree_id])
    flash[:notice] = "You're proposed wager has been sent"#" to #{wageree["email"]}"
    redirect "/users/#{session[:user_id]}"
  end




  #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  #NEW - DISTRIBUTIONS
  get "/distributions/new" do
    @charities_for_selection = @charities.find_all
    render_page_or_redirect_to_homepage(session[:user_id], "new_distribution")
  end

  #CREATE - DISTRIBUTIONS
  post "/distributions" do
    @distributions.create_in_dbase(params[:account_id], params[:amount], params[:charity_dd])
    distribution = @distributions.find_most_recent(params[:account_id])
    flash[:notice] = "Thank you for distributing $#{distribution["amount"].to_i / 100} from your account to #{distribution["charity"]}"
    redirect "/users/#{session[:user_id]}"
  end

  #INDEX - DEPOSITS
  get "/distributions" do
    render_page_or_redirect_to_homepage(session[:user_id], "index_distribution")
  end


  #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  #NEW - DEPOSITS
  get "/deposits/new" do
    render_page_or_redirect_to_homepage(session[:user_id], "new_deposit")
  end

  #CREATE - DEPOSITS
  post "/deposits" do
    @deposits.create_in_dbase(params[:account_id], params[:amount], params[:cc_number], params[:exp_date], params[:name_on_card], params[:radio_cc_type])
    deposit = @deposits.find_most_recent(params[:account_id])

    flash[:notice] = "Thank you for depositing $#{deposit["amount"].to_i / 100} into your account"

    redirect "/users/#{session[:user_id]}"
  end

  #INDEX - DEPOSITS
  get "/deposits" do
    render_page_or_redirect_to_homepage(session[:user_id], "index_deposit")
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
      deposit_total = @deposits.sum_by_account_id(account["id"])
      distribution_total = @distributions.sum_by_account_id(account["id"])
      net_amount = deposit_total - distribution_total
      proposed_wagers = @proposed_wagers.find_all(session[:user_id])
      erb :show_user, locals: {account: account, deposit_total: deposit_total, distribution_total: distribution_total, net_amount: net_amount, proposed_wagers: proposed_wagers}
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

  def render_page_or_redirect_to_homepage(session_id, name_of_erb_template)
    if session_id == nil
      flash[:notice] = "You are not authorized to visit this page"
      redirect "/"
    else
      account = @accounts.find_by_user_id(session_id)
      if session_id == account["user_id"]
        deposits_array = @deposits.find_by_account_id(account["id"])
        distributions_array = @distributions.find_by_account_id(account["id"])
        erb name_of_erb_template.to_sym, locals: {account: account, deposits_array: deposits_array, distributions_array: distributions_array}
      else
        flash[:notice] = "You are not authorized to visit this page"
        redirect "/"
      end
    end
  end





end
