# feature "admin rights" do
#   scenario "As an Admin, I can see the index view of all charity applications" do
#     visit "/charities/new"
#     complete_application("Red Cross")
#     visit "/charities"
#
#     expect(page).to have_content("Red Cross")
#   end
# end


# scenario "visitor adds an mvp" do
#   visit "/"
#   click_on "mvps"
#   click_on "Add New"
#   expect(page).to have_content "Log an MVP"
#   fill_in "Description", with: "This is a new MVP"
#   click_on "Submit"
#   expect(page).to have_content("This is a new MVP")
# end
#
# scenario "visitor adds an mvp but cancels their form" do
#   visit "/"
#   click_on "mvps"
#   click_on "Add New"
#   click_on "Cancel"
#   expect(page).to have_content "charities"
# end