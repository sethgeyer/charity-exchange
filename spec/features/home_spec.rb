feature "visitor visits homepage" do
  before(:each) do
    visit "/"
  end
  scenario "visitor peruses the homepage" do
    expect(page).to have_content("Charity Exchange")
    expect(page).to have_button("Login")
    expect(page).to have_link("Sign Up")

  end

  feature "visitor registration" do
    before(:each) do
      click_on "Sign Up"
    end

    scenario "visitor wishes to register" do
      expect(page).to have_content("Register Here")
    end

    scenario "visitor fills in registration form completely and accurately" do
      fill_in_registration_form("Seth")
      expect(page).to have_content("Thanks for registering Seth.  You are now logged in.")
    end

  end
end