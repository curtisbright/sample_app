require 'spec_helper'

describe 'User pages' do

  subject { page }

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
      it { should have_heading('Update your profile') }
      it { should have_title('Edit user') }
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

    it { should have_heading(user.name) }
    it { should have_title(user.name) }

    describe 'microposts' do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end

    describe 'follow/unfollow buttons' do
      let(:other_user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe 'following a user' do
        before { visit user_path(other_user) }

        it 'should increment the followed user count' do
          expect do
            click_button 'Follow'
          end.to change(user.followed_users, :count).by(1)
        end

        it 'should increment the other user\'s followers count' do
          expect do
            click_button 'Follow'
          end.to change(other_user.followers, :count).by(1)
        end

        describe 'toggling the button' do
          before { click_button 'Follow' }
          it { should have_selector('input', value: 'Unfollow') }
        end
      end

      describe 'unfollowing a user' do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        it 'should decrement the followed user count' do
          expect do
            click_button 'Unfollow'
          end.to change(user.followed_users, :count).by(-1)
        end

        it 'should decrement the other user\'s followers count' do
          expect do
            click_button 'Unfollow'
          end.to change(other_user.followers, :count).by(-1)
        end

        describe 'toggling the button' do
          before { click_button 'Unfollow' }
          it { should have_selector('input', value: 'Follow') }
        end
      end
    end
  end

  describe 'following/followers' do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    before { user.follow!(other_user) }

    describe 'followed users' do
      before do
        sign_in user
        visit following_user_path(user)
      end

      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    describe 'followers' do
      before do
        sign_in other_user
        visit followers_user_path(other_user)
      end

      it { should have_link(user.name, href: user_path(user)) }
    end
  end

end
