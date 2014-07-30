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

  ### Did this to address the return the connections to the connection pool
  after do
    ActiveRecord::Base.connection.close
  end

  enable :sessions
  use Rack::Flash

  def initialize
    super
  end

  get "/" do
  erb :home
  end

  #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  #NEW - PROPOSED_WAGERS
  get "/proposed_wagers/new" do
    @list_of_users = User.where('id != ?', session[:user_id])
    render_page_or_redirect_to_homepage(session[:user_id], "new_proposed_wager")
  end

  post "/proposed_wagers" do
    account = Account.find_by(user_id: session[:user_id])
    ProposedWager.create(account_id: account.id, title: params[:title], date_of_wager: params[:date_of_wager], details: params[:details], amount: params[:amount].to_i * 100, wageree_id: params[:wageree_dd].to_i)
    wageree = User.find(params[:wageree_dd].to_i)
    flash[:notice] = "You're proposed wager has been sent"#" to #{wageree["email"]}"
    redirect "/users/#{session[:user_id]}"
  end

  #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  #NEW - DISTRIBUTIONS
  get "/distributions/new" do
    @charities_for_selection = Charity.all
    render_page_or_redirect_to_homepage(session[:user_id], "new_distribution")
  end

  #CREATE - DISTRIBUTIONS
  post "/distributions" do
    Distribution.create(account_id: params[:account_id].to_i, amount: params[:amount].to_i * 100, charity: params[:charity_dd])
    newest_distribution = Distribution.where(account_id: params[:account_id].to_i).last
    flash[:notice] = "Thank you for distributing $#{newest_distribution.amount.to_i / 100} from your account to #{newest_distribution.charity}"
    redirect "/users/#{session[:user_id]}"
  end

  #INDEX - DISTRIBUTIONS
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
    deposit = Deposit.new
    deposit.account_id = params[:account_id].to_i
    deposit.amount = params[:amount].to_i * 100
    deposit.cc_number = params[:cc_number].to_i
    deposit.exp_date =params[:exp_date]
    deposit.name_on_card = params[:name_on_card]
    deposit.cc_type = params[:radio_cc_type]
    deposit.save!
    newest_deposit = Deposit.where(account_id: params[:account_id].to_i).last
    flash[:notice] = "Thank you for depositing $#{newest_deposit.amount / 100} into your account"
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
    Charity.create(name: params[:name], tax_id: params[:tax_id], poc: params[:poc], poc_email: params[:poc_email], status: params[:status])
    flash[:notice] = "Thanks for applying"
    redirect "/charities"
  end

  #INDEX - CHARITY
  get "/charities" do
    charities = Charity.all
    erb :index_charity, locals: {charities: charities}
  end

  #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  #INDEX - MVP
  get "/mvps" do
    mvps = Mvp.all
    current_user = User.find(session[:user_id]) if session[:user_id]
    erb :index_mvp, locals: {mvps: mvps, current_user: current_user}
  end

  #NEW - MVP
  get "/mvps/new" do
    current_user = User.find(session[:user_id])
    if current_user.is_admin?
      erb :new_mvp
    else
      flash[:notice] = "You don't have permissions to add an MVP"
      redirect "/mvps"
    end
  end

  #CREATE - MVP
  post "/mvps" do
    Mvp.create(date: params[:date], description: params[:description])
    redirect "/mvps"
  end

  #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  #LOGIN
  post "/login" do
    current_user = User.find_by(email: params[:email], password: params[:password])
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
    user = User.new
    user.email = params[:email]
    user.password = params[:password]
    user.profile_picture = params[:profile_picture]
    user.save!
    current_user = User.find_by(email: params[:email])
    set_the_session(current_user)
    account = Account.new
    account.user_id = session[:user_id]
    account.save!
    flash[:notice] = "Thanks for registering #{session[:email]}. You are now logged in."
    redirect "/users/#{session[:user_id]}"
  end

  #EDIT - USER
  get "/users/:id/edit" do
    if session[:user_id] == params[:id].to_i
      current_user = User.find(session[:user_id])
      erb :edit_user, locals: {current_user: current_user}, layout: false
    else
      flash[:notice] = "You are not authorized to visit this page"
      redirect "/"
    end
    end

  #UPDATE - USER
  patch "/users/:id" do
    user = User.find(params[:id].to_i)
    user.password = params[:password]
    user.profile_picture = params[:profile_picture]
    user.save!
    flash[:notice] = "Your changes have been saved"
    redirect "/users/#{session[:user_id]}"
  end

  #SHOW - USER
  get "/users/:id" do
    if session[:user_id] == params[:id].to_i
      account = Account.find_by(user_id: session[:user_id])
      deposit_total = account.deposits.sum(:amount) / 100
      distribution_total = account.distributions.sum(:amount) / 100
      wagered_total = account.proposed_wagers.sum(:amount) / 100
      net_amount = deposit_total - distribution_total - wagered_total
      proposed_wagers = account.proposed_wagers
      erb :show_user, locals: {account: account, deposit_total: deposit_total, distribution_total: distribution_total, wagered_total: wagered_total, net_amount: net_amount, proposed_wagers: proposed_wagers}
    else
      flash[:notice] = "You are not authorized to visit this page"
      redirect "/"
    end
  end

  #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  def set_the_session(current_user)
    session[:user_id] = current_user.id
    session[:email] = current_user.email
  end

  def render_page_or_redirect_to_homepage(session_id, name_of_erb_template)
    if session_id == nil
      flash[:notice] = "You are not authorized to visit this page"
      redirect "/"
    else
      account = Account.find_by(user_id: session_id)
      if session_id == account.user_id
        deposits = account.deposits
        distributions = account.distributions
        erb name_of_erb_template.to_sym, locals: {account: account, deposits: deposits, distributions: distributions}
      else
        flash[:notice] = "You are not authorized to visit this page"
        redirect "/"
      end
    end
  end





end
