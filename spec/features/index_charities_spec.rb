feature "visitor visits charities" do
  before(:each) do
    visit "/charities"
  end

  scenario "As a charity, I can apply to register my charity with charity exchange" do
    expect(page).to have_link("Register a new charity")
    click_on "Register a new charity"
    complete_application("United Way")
    expect(page).to have_content("Thanks for applying")
    click_on "Back to Home"
    expect(page).to have_content("charities")
  end

  scenario "As a charity, I can cancel a registration" do
    click_on "Register a new charity"
    expect(page).to have_link("Cancel")
      click_on "Cancel"
    expect(page).to have_content("Charities")
  end

end