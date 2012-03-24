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

        describe 'visit signup again' do
          before { visit signup_path }

          it { should_not have_title('Sign up') }
        end

        describe 'submitting to the create action' do
          before { put signup_path }

          it { should_not have_title('Sign up') }
        end
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

      let(:first_page)  { User.paginate(page: 1) }
      let(:second_page) { User.paginate(page: 2) }

      it { should have_link('Next') }
      it { should have_link('2') }
      it { should_not have_link('delete') }

      describe 'as an admin user' do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it 'should be able to delete another user' do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end

      it 'should list each user' do
        User.all[0..2].each do |user|
          page.should have_selector('li', text: user.name)
        end
      end

      it 'should list the first page of users' do
        first_page.each do |user|
          page.should have_selector('li', text: user.name)
        end
      end

      it 'should not list the second page of users' do
        second_page.each do |user|
          page.should_not have_selector('li', text: user.name)
        end
      end

      describe 'showing the second page' do
        before { visit users_path(page: 2) }

        it 'should list the second page of users' do
          second_page.each do |user|
            page.should have_selector('li', text: user.name)
          end
        end
      end
    end
  end

  describe 'profile page' do
    let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: 'Foo') }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: 'Bar') }

    before { visit user_path(user) }

    it { should have_selector('h1',    text: user.name) }
    it { should have_selector('title', text: user.name) }

    describe 'microposts' do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end
  end

end
