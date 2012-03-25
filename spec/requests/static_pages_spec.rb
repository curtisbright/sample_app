require 'spec_helper'

describe 'Static pages' do

  subject { page }

  shared_examples_for 'all static pages' do
    it { should have_heading(heading) }
    it { should have_title(full_title(page_title)) }
  end

  describe 'Home page' do
    before { visit root_path }
    let(:heading)    { 'Sample App' }
    let(:page_title) { '' }

    it_should_behave_like 'all static pages'
    it { should_not have_title('| Home') }

    describe 'for signed-in users' do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: 'Lorem ipsum')
        FactoryGirl.create(:micropost, user: user, content: 'Dolor sit amet')
        sign_in user
        visit root_path
      end

      it 'should render the user\'s feed' do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
        end
      end

      describe 'should count microposts' do
        it { should have_content('2 microposts') }

        describe 'with proper pluralization' do
          before { click_link "delete" }

          it { should have_content('1 micropost') }
          it { should_not have_content('microposts') }
        end
      end

      describe 'pagination' do
        before(:all) { 29.times { FactoryGirl.create(:micropost, user: user) } }
        after(:all)  { Micropost.delete_all }

        it { should have_link('Next') }
        it { should have_link('2') }

        describe 'with only one page necessary' do
          before { click_link "delete" }

          it { should_not have_link('Next') }
          it { should_not have_link('2') }          
        end
      end
    end
  end

  describe 'Help page' do
    before { visit help_path }
    let(:heading) { 'Help' }
    let(:page_title) { 'Help' }
    it_should_behave_like 'all static pages'
  end

  describe 'About page' do
    before { visit about_path }
    let(:heading) { 'About' }
    let(:page_title) { 'About Us' }
    it_should_behave_like 'all static pages'
  end

  describe 'Contact page' do
    before { visit contact_path }
    let(:heading) { 'Contact' }
    let(:page_title) { 'Contact' }
    it_should_behave_like 'all static pages'
  end

  it 'should have the right links on the layout' do
    visit root_path
    click_link 'About'
    page.should have_title(full_title('About Us'))
    click_link 'Help'
    page.should have_title(full_title('Help'))
    click_link 'Contact'
    page.should have_title(full_title('Contact'))
    click_link 'Home'
    page.should have_title(full_title(''))
    click_link 'Sign up now!'
    page.should have_title(full_title('Sign up'))
  end
end
