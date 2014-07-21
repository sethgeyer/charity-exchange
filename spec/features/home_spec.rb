feature "visitor visits homepage" do
  before(:each) do
    visit "/"
  end
  scenario "visitor peruses the homepage" do
    expect(page).to have_button("Login")
    expect(page).to have_link("Sign Up")
    expect(page).not_to have_button("Logout")
  end

  scenario "visitor wishes to register" do
    click_on "Sign Up"
    expect(page).to have_content("Register Here")
  end

  scenario "registered visitor completes login form correctly" do
    fill_in_registration_form("Seth")
    click_on "Logout"
    fill_in "Email", with: "Seth"
    fill_in "Password", with: "seth"
    click_on "Login"
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
    visit "/"
    click_on "Edit Profile"
    fill_in "Password", with: "sethy"
    fill_in "Profile Picture", with: "www.goggle.com"
    click_on "Submit"
    expect(page).to have_content("Your changes have been saved")
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
