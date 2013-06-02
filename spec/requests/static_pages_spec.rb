require 'spec_helper'

describe "Static pages" do

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1',    text: heading) }
    it { should have_selector('title', text: full_title(page_title)) }
  end

  describe "Home page" do
    before { visit root_path }
    let(:heading)    { 'Sample App' }
    let(:page_title) { '' }

    it_should_behave_like "all static pages"
    it { should_not have_selector 'title', text: '| Home' }

    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        valid_signin user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
        end
      end

      it "should show the correct micropost count" do
        page.should have_selector 'span', text: "#{user.feed.count} microposts"
      end

      it "should show the correct micropost count pluralization" do
        micropost = user.feed.first.destroy
        visit root_path
        page.should have_selector 'span', text: "#{user.feed.count} micropost"
      end
    end
  end

  describe "pagination on home page for a signed-in user" do
    let(:pagination_user) { FactoryGirl.create(:user) }
    before do
      35.times { FactoryGirl.create(:micropost, user: pagination_user) }
      valid_signin pagination_user
      visit root_path
    end

    it { should have_selector('div.pagination') }

    it "should list each micropost of the first page" do
      pagination_user.feed.paginate(page: 1).each do |mpost|
        page.should have_selector("li##{mpost.id}", text: mpost.content)
      end
    end

    it "should NOT list each micropost of the second page" do
      pagination_user.feed.paginate(page: 2).each do |mpost|
        page.should_not have_selector("li##{mpost.id}", text: mpost.content)
      end
    end
  end

  describe "Help page" do
    before { visit help_path }
    let(:heading)    { 'Help' }
    let(:page_title) { 'Help' }

    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }
    let(:heading)    { 'About' }
    let(:page_title) { 'About Us' }

    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before { visit contact_path }
    let(:heading)    { 'Contact' }
    let(:page_title) { 'Contact' }

    it_should_behave_like "all static pages"
  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    page.should have_selector 'title', text: full_title('About Us')
    click_link "Help"
    page.should have_selector 'title', text: full_title('Help')
    click_link "Contact"
    page.should have_selector 'title', text: full_title('Contact')
    click_link "Home"
    click_link "Sign up now!"
    page.should have_selector 'title', text: full_title('Sign up')
    click_link "sample app"
    page.should have_selector 'title', text: full_title('')
  end
end