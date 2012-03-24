def full_title(page_title)
  base_title = "Ruby on Rails Tutorial Sample App"
  if page_title.empty?
    base_title
  else
    "#{base_title} | #{page_title}"
  end
end

def valid_signin(user)
  fill_in 'Email',    with: user.email
  fill_in 'Password', with: user.password
  click_button 'Sign in'
end

def sign_in(user)
  visit signin_path
  valid_signin(user)
  # Sign in when not using Capybara as well.
  #session[:remember_token] = user.id
  cookies[:remember_token] = user.remember_token
end

def valid_login
  fill_in 'Name',             with: 'Example User'
  fill_in 'Email',            with: 'user@example.com' 
  fill_in 'Password',         with: 'foobar'
  fill_in 'Confirm Password', with: 'foobar'
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-success', text: message)
  end
end

RSpec::Matchers.define :have_title do |title|
  match do |page|
    page.should have_selector('title', text: title)
  end
end

RSpec::Matchers.define :have_heading do |heading|
  match do |page|
    page.should have_selector('h1', text: heading)
  end
end
