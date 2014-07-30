feature "visitor visits homepage" do
  before(:each) do
    visit "/"
  end

  scenario "visitor peruses the homepage" do
    expect(page).to have_button("Login")
    expect(page).to have_link("Sign Up")
    expect(page).not_to have_button("Logout")
    expect(page).not_to have_button("Edit Profile")
    expect(page).to have_link("Charities")
    expect(page).not_to have_link("Account Details")
  end

  scenario "non-registered visitor tries to login or visitor logs in w/ incorrect credentials" do
    fill_in "Email", with: "Seth"
    fill_in "Password", with: "123"
    click_on "Login"
      expect(page).to have_button("Login")
      expect(page).to have_content("The credentials you entered are incorrect.  Please try again.")
      expect(page).not_to have_button("Logout")
      expect(page).to have_link("Sign Up")
      expect(page).not_to have_link("Edit Profile")
  end

  scenario "logged in user wants to see their account details" do
    fill_in_registration_form("Seth")
    click_on "Account Details"

    expect(page).to have_css("#show_users")
  end

  scenario "visitor wants to see charities via the link on the homepage" do
    click_on "Charities"
      expect(page).to have_css("#index_charities")
  end

  scenario "visitor wants to see the register page via the link on the homepage" do
    click_on "Sign Up"
      expect(page).to have_css("#new_users")
      expect(page).to have_link("Cancel")
  end
end


feature "visitor registration" do
  scenario "visitor fills in registration form completely and accurately" do
    fill_in_registration_form("Seth")
      expect(page).to have_content("Thanks for registering Seth.  You are now logged in.")
    expect(page).to have_button("Logout")
      expect(page).not_to have_button("Login")
      expect(page).not_to have_link("Sign Up")
      expect(page).to have_link("Edit Profile")
      expect(page).to have_css("#show_users")
  end

  scenario "registered visitor completes login form correctly and routes to show page for the user" do
    fill_in_registration_form("Seth")
    click_on "Logout"
    login_a_registered_user("Seth")
      expect(page).to have_content("Welcome Seth")
      expect(page).to have_button("Logout")
      expect(page).not_to have_button("Login")
      expect(page).not_to have_link("Sign Up")
      expect(page).to have_link("Edit Profile")
      expect(page).to have_link("Charities")
      expect(page).to have_css("#show_users")

  end



  scenario "visitor fills in registration form only partially" do
    skip
  end
  scenario "visitor uses an already used email during registration" do
    skip
  end
  scenario "logged in user tries to register via the register url" do
    skip
  end

end


feature "editing user profile" do
  scenario "registered user updates their user profile" do
    fill_in_registration_form("Seth")
    click_on "Logout"
    login_a_registered_user("Seth")
    click_on "Edit Profile"
    fill_in "Password", with: "sethy"
    fill_in "Profile Picture", with: "www.google.com"
    click_on "Submit"
      expect(page).to have_content("Your changes have been saved")
      expect(page).to have_css("#show_users")
    click_on "Edit Profile"
      expect(find("#profile_picture").value).to eq("www.google.com")
      expect(find("#password").value).to eq("sethy")
  end

  scenario "anyone besides the registered user can not change the individual's profile via the direct url" do
    visit "/users/5000/edit"
      expect(page).to have_content("You are not authorized to visit this page")
      expect(page).to have_css("#homepage")
  end

  scenario "registered user decides to cancel their edits" do
    fill_in_registration_form("Seth")
    click_on "Logout"
    login_a_registered_user("Seth")
    click_on "Edit Profile"
    click_on "Cancel"
      expect(page).to have_css("#show_users")
  end
end




feature "visitor visits charities" do
  before(:each) do
    visit "/charities"
  end

  scenario "As a user, I can see the index view of all charity applications" do
    visit "/charities/new"
    complete_application("Red Cross")
    visit "/charities"
      expect(page).to have_content("Red Cross")
  end

  scenario "As a charity, I can apply to register my charity with charity exchange" do
      expect(page).to have_link("Register a new charity")
    click_on "Register a new charity"
    complete_application("United Way")
      expect(page).to have_content("Thanks for applying")
    click_on "Back to Home"
      expect(page).to have_content("Charity")
  end

  scenario "As a charity, I can cancel a registration" do
    click_on "Register a new charity"
      expect(page).to have_link("Cancel")
    click_on "Cancel"
      expect(page).to have_content("Charity")
  end

end


feature "viewing mvps"  do
  scenario "visitor clicks on the mvp link" do
    visit "/"
    click_on "MVPs"
      expect(page).to have_content("Minimum Viable Products Released")
      expect(page).not_to have_link("Add New")
  end

  scenario "visitor visits mvp view and wants to return to home" do
    visit "/"
    click_on "MVPs"
    click_on "Back to Home"

     expect(page).to have_content "Charity"
  end
end

feature "User Show Page" do

  scenario "As a logged in user I can view my account details page" do
    fill_in_registration_form("Seth")
      expect(page).to have_css("#deposits")
      expect(page).to have_css("#distributions")
      expect(page).to have_css("#net_amount")
  end

  scenario "As a logged_in user I can link to the new deposits page to fund my account" do
    fill_in_registration_form("Seth")
    click_on "Fund My Account"
      expect(page).to have_css("#new_deposits")
  end

  scenario "As a logged_in user I can link to the 'create a wager' page to create a wager" do
    fill_in_registration_form("Seth")
    click_on "Create a Wager"
    expect(page).to have_css("#new_proposed_wagers")
  end




  scenario "As a logged_in user I can link to the new distributions page to distribute funds from my account" do
    fill_in_registration_form("Seth")
    click_on "Distribute Funds"
      expect(page).to have_css("#new_distributions")
  end

  scenario "non-logged in visitor attempts to visit show page" do
    visit "/users/50000"
      expect(page).to have_content("You are not authorized to visit this page")
      expect(page).to have_css("#homepage")
  end

end

feature "Add Funds to Account" do

  scenario "As a non-logged_in user, I should not be able to visit the show page directly via typing in a uRL" do
    visit "/deposits/new"
      expect(page).to have_content("You are not authorized to visit this page")
      expect(page).to have_css("#homepage")
  end


  scenario "As a user I can add funds to my account" do
    fill_in_registration_form("Seth")
    fund_my_account_with_a_credit_card(400)
      expect(page).to have_css("#show_users")
      expect(page).to have_content("Thank you for depositing $400 into your account")
      expect(page.find("#deposits")).to have_content("$400")
      expect(page.find("#net_amount")).to have_content("$400")
    fund_my_account_with_a_credit_card(500)
      expect(page).to have_content("Thank you for depositing $500 into your account")
      expect(page.find("#deposits")).to have_content("$900")
      expect(page.find("#net_amount")).to have_content("$900")

  end
end

feature "View History of Deposit" do
  scenario "As a user, I should be able to view my history of deposits" do
    fill_in_registration_form("Seth")
    fund_my_account_with_a_credit_card(400)
    fund_my_account_with_a_credit_card(500)
    click_on "Show Deposit History"
      expect(page).to have_css("#index_deposits")
      expect(page).to have_content("$400")
      expect(page).not_to have_content("$40000")
      expect(page).to have_content("$500")
    end
end

feature "View History of Deposit" do
  scenario "As a non-logged in visitor, I should NOT be able to view a history of deposits" do
    visit "/deposits"
    expect(page).to have_content("You are not authorized to visit this page")
    expect(page).to have_css("#homepage")
  end
end

feature "View History of Distribution" do
  scenario "As a user, I should be able to view my history of distributions" do
    visit "/charities/new"
    complete_application("United Way")
    visit "/charities/new"
    complete_application("Red Cross")
    fill_in_registration_form("Seth")
    fund_my_account_with_a_credit_card(400)
    fund_my_account_with_a_credit_card(500)
    distribute_funds_from_my_account(100, "United Way")
    distribute_funds_from_my_account(200, "Red Cross")
    click_on "Show Distribution History"
    expect(page).to have_css("#index_distributions")
    expect(page).to have_content("$100")
    expect(page).not_to have_content("$10000")
    expect(page).to have_content("$200")
  end
end

feature "View History of Deposit" do
  scenario "As a non-logged in visitor, I should NOT be able to view a history of deposits" do
    visit "/deposits"
    expect(page).to have_content("You are not authorized to visit this page")
    expect(page).to have_css("#homepage")
  end
end


feature "Distribute Funds from the Account" do

  scenario "As a non-logged_in user, I should not be able to visit the new distributions page directly via typing in a uRL" do
    visit "/distributions/new"
      expect(page).to have_content("You are not authorized to visit this page")
      expect(page).to have_css("#homepage")
  end


  scenario "As a user I can distribute funds from my account" do
    visit "/charities/new"
    complete_application("United Way")
    visit "/charities/new"
    complete_application("Red Cross")
    fill_in_registration_form("Seth")
    fund_my_account_with_a_credit_card(400)
    distribute_funds_from_my_account(100, "United Way")
      expect(page).to have_css("#show_users")
      expect(page).to have_content("Thank you for distributing $100 from your account to United Way")
      expect(page.find("#deposits")).to have_content("$400")
      expect(page.find("#distributions")).to have_content("$100")
      expect(page.find("#net_amount")).to have_content("$300")
    distribute_funds_from_my_account(50, 'Red Cross')
      expect(page).to have_content("Thank you for distributing $50 from your account to Red Cross")
      expect(page.find("#deposits")).to have_content("$400")
      expect(page.find("#distributions")).to have_content("$150")
      expect(page.find("#net_amount")).to have_content("$250")
  end
end


feature "Create a Proposed Wager" do
  scenario "As a non-logged in visitor, I should not be able to visit the new proposed wager view directly via the URL " do
    visit "/proposed_wagers/new"
      expect(page).to have_content("You are not authorized to visit this page")
      expect(page).to have_css("#homepage")
  end


  scenario "As a user I can create a proposed wager" do
    fill_in_registration_form("Alex")
    click_on "Logout"
    fill_in_registration_form("Seth")
    fund_my_account_with_a_credit_card(400)
    visit "/proposed_wagers/new"
    fill_in "Title", with: "Ping Pong Match between Seth and Alex"
    fill_in "Date of Wager", with: "2014-07-31"
    fill_in "Details", with: "Game to 21, standard rules apply"
    fill_in "Amount", with: 200
    select "Alex", from: "Wageree"
    click_on "Submit"
      # expect(page).to have_content("You're proposed wager has been sent to Alex")
      expect(page.find("#proposed_wagers_table")).to have_content("Ping Pong Match")
      expect(page.find("#proposed_wagers_table")).to have_content(200)
      expect(page.find("#proposed_wagers_table")).not_to have_content(20000)
  end
end



