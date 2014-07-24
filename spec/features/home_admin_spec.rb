# feature "admin rights" do
#   scenario "As an Admin, I can see the index view of all charity applications" do
#     visit "/charities/new"
#     complete_application("Red Cross")
#     visit "/charities"
#
#     expect(page).to have_content("Red Cross")
#   end
# end