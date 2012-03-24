require 'spec_helper'

describe 'User pages' do

  subject { page }

  describe 'profile page' do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_heading(user.name) }
    it { should have_title(user.name) }
  end

  describe 'signup page' do
    before { visit signup_path }

    it { should have_heading('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

  describe 'signup' do

    before { visit signup_path }

    describe 'with invalid information' do
      it 'should not create a user' do
        expect { click_button 'Create my account' }.not_to change(User, :count)
      end

      describe 'error messages' do
        before { click_button 'Create my account' }

        it { should have_title('Sign up') }
        it { should have_content('error') }
        it { should have_content('Password can\'t be blank') }
        it { should have_content('Name can\'t be blank') }
        it { should have_content('Email can\'t be blank') }
        it { should have_content('Email is invalid') }
        it { should have_content('Password is too short (minimum is 6 characters)') }
        it { should have_content('Password confirmation can\'t be blank') }
      end
    end

    describe 'with valid information' do
      before do
        valid_login
      end

      describe 'after saving the user' do
        before { click_button 'Create my account' }
        let(:user) { User.find_by_email('user@example.com') }

        it { should have_title(user.name) }
        it { should have_success_message('Welcome') }

        it { should have_link('Sign out') }
      end

      it 'should create a user' do
        expect do
          click_button 'Create my account'
        end.to change(User, :count).by(1)
      end
    end
  end

  describe 'edit' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end
    before { visit edit_user_path(user) }

    describe 'page' do
      it { should have_selector('h1',    text: 'Update your profile') }
      it { should have_selector('title', text: 'Edit user') }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe 'with valid information' do
      let(:new_name)  { 'New Name' }
      let(:new_email) { 'new@example.com' }
      before do
        fill_in 'Name',             with: new_name
        fill_in 'Email',            with: new_email
        fill_in 'Password',         with: user.password
        fill_in 'Confirm Password', with: user.password
        click_button 'Save changes'
      end

      it { should have_title(new_name) }
      it { should have_success_message('') }
      it { should have_link('Sign out', :href => signout_path) }
      specify { user.reload.name.should  == new_name }
      specify { user.reload.email.should == new_email }
    end

    describe 'with invalid information' do
      before { click_button 'Save changes' }

      it { should have_content('error') }
    end
  end

  describe 'index' do
    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in user
      visit users_path
    end

    it { should have_selector('title', text: 'All users') }

    describe 'pagination' do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it { should have_link('Next') }
      it { should have_link('2') }

      it 'should list each user' do
        User.all[0..2].each do |user|
          page.should have_selector('li', text: user.name)
        end
      end
    end
  end
end
