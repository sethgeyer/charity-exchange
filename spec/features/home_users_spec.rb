feature "visitor visits homepage" do
  before(:each) do
    visit "/"
  end
  scenario "visitor peruses the homepage" do
    expect(page).to have_button("Login")
    expect(page).to have_link("Sign Up")
    expect(page).not_to have_button("Logout")
    click_on "charities"
    expect(page).to have_content("Charities")
  end

  scenario "visitor wishes to register" do
    click_on "Sign Up"
    expect(page).to have_content("Register Here")
    expect(page).to have_link("Cancel")
  end

  scenario "registered visitor completes login form correctly" do
    fill_in_registration_form("Seth")
    click_on "Logout"
    login_a_registered_user("Seth")
    expect(page).to have_content("Welcome Seth")
    expect(page).to have_button("Logout")
    expect(page).not_to have_button("Login")
    expect(page).not_to have_link("Sign Up")
    expect(page).to have_link("Edit Profile")
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
end

feature "editing user profile" do
  scenario "registered user updates their user profile" do
    fill_in_registration_form("Seth")
    click_on "Logout"
    login_a_registered_user("Seth")
    click_on "Edit Profile"
    fill_in "Password", with: "sethy"
    fill_in "Profile Picture", with: "www.goggle.com"
    click_on "Submit"
    expect(page).to have_content("Your changes have been saved")
  end
  scenario "registered user decides to cancel their edits" do
    fill_in_registration_form("Seth")
    click_on "Logout"
    login_a_registered_user("Seth")
    click_on "Edit Profile"
    click_on "Cancel"
    expect(page).to have_content("charities")
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

feature "charities index" do
  scenario "As a user, I can see the index view of all charity applications" do
    visit "/charities/new"
    complete_application("Red Cross")
    visit "/charities"
    expect(page).to have_content("Red Cross")
  end
end
