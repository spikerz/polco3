feature "Signing up" do
  background do
    User.make(:email => 'user@example.com', :password => 'caplin')
  end

  scenario "Voting on house bills" do
    load_ten_house_bills
    visit '/represent/house_bills'
    within("#session") do
      fill_in 'Login', :with => 'user@example.com'
      fill_in 'Password', :with => 'caplin'
    end
    click_link 'Sign in'
    page.should have_content 'Success'
  end

  given(:other_user) { User.make(:email => 'other@example.com', :password => 'rous') }

  scenario "Signing in as another user" do
    visit '/sessions/new'
    within("#session") do
      fill_in 'Login', :with => other_user.email
      fill_in 'Password', :with => other_user.password
    end
    click_link 'Sign in'
    page.should have_content 'Invalid email or password'
  end
end