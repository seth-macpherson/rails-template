require "rails_helper"

RSpec.feature "Users", type: :feature do
  scenario "sending password reset", js: true do
    login_as create(:user, :admin), scope: :user, run_callbacks: false

    user = create(:user)
    visit "/users"
    click_link user.email

    click_link I18n.t(:send_reset_password)

    expect(page).to have_content("Sent password reset instructions to #{user.email}", wait: 3)
  end

  scenario "signing in as a disabled user", js: true do
    user = create :user, disabled: true
    visit new_user_session_path

    fill_in "Email Address", with: user.email
    fill_in "Password", with: user.password
    click_button I18n.t("devise.sessions.new.submit")

    expect(page).to have_current_path new_user_session_path
  end

  scenario "signing in and out", js: true do
    user = create(:user)

    visit "/"
    expect(page).to have_current_path new_user_session_path
    fill_in "Email Address", with: user.email
    fill_in "Password", with: user.password
    click_button I18n.t("devise.sessions.new.submit")

    # PhantomJS is confounded by flexbox so the menu doesn"t show up properly
    find("a.launch.icon").click
    click_link I18n.t("nav.sign_out")

    expect(page).to have_current_path new_user_session_path
  end

  scenario "visiting the welcome page when logged in" do
    login_as create(:user, :admin)
    visit "/"
    expect(page).to have_current_path(root_path)
  end

  scenario "signing up" do
    visit "/"
    click_link "Sign up"

    password = Faker::Internet.password
    email = Faker::Internet.safe_email
    fill_in "Email Address", with: email
    fill_in "Password", with: password
    fill_in "Confirm Password", with: password
    fill_in "First Name", with: Faker::Name.first_name
    fill_in "Surname", with: Faker::Name.last_name

    click_button "Sign up"

    expect(page).to have_current_path root_path
  end

  scenario "signing up as a user that will be auto-elevated" do
    visit "/"
    click_link "Sign up"

    password = Faker::Internet.password
    email = "#{Faker::Internet.user_name}@webgents.dk"

    fill_in "Email Address", with: email
    fill_in "Password", with: password
    fill_in "Confirm Password", with: password
    fill_in "First Name", with: Faker::Name.first_name
    fill_in "Surname", with: Faker::Name.last_name

    click_button "Sign up"

    # Should get bounced to the sign-in page saying confirmation is required
    expect(page).to have_current_path new_user_session_path
    expect(page).to have_content I18n.t("devise.registrations.signed_up_but_unconfirmed")

    # Try logging in
    fill_in "Email Address", with: email
    fill_in "Password", with: password
    click_button "Login"

    expect(page).to have_current_path new_user_session_path
    expect(page).to have_content I18n.t("devise.failure.unconfirmed")

    # Confirm the email address by visiting the confirmation page
    user = User.find_by(email: email)
    visit "/users/confirmation?confirmation_token=#{user.confirmation_token}"

    expect(page).to have_current_path root_path
  end
end
