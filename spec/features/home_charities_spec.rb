feature "visitor visits homepage" do
  before(:each) do
    visit "/"
  end

  scenario "As a charity, I can apply to register my charity with charity exchange" do
    expect(page).to have_link("Register a new charity")
    click_on "Register a new charity"
    complete_application("United Way")
    expect(page).to have_content("Thanks for applying")
  end

end