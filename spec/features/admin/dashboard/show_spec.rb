require 'rails_helper'

RSpec.describe "Admin Dashboard Page" do
  before :each do
    @dog_shop = Merchant.create!(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Denver', state: 'CO', zip: 80210)

    @employee = User.create!({ name: "Jack", address: "333 Jack Blvd", city: "Denver", state: "Colorado", zip: 83243, email: "john@hotmail.com", password: "3455", password_confirmation: "3455", role: 1, merchant_id: @dog_shop.id})
    @user = User.create!(name:"Jill", address:"123 Street", city:"Cityville", state:"CO", zip: 80110, email: "email2@email.com", password: "abcd", password_confirmation:"abcd", role:0)
    @user1 = User.create!(name:"Sarah", address:"123 Street", city:"Cityville", state:"CO", zip: 80110, email: "email1@email.com", password: "abcd", password_confirmation:"abcd", role:0)
    @user2 = User.create!(name:"Kevin", address:"123 Street", city:"Cityville", state:"CO", zip: 80110, email: "email3@email.com", password: "abcd", password_confirmation:"abcd", role:0)
    @admin = User.create!(name:"Jan", address:"123 Street", city:"Cityville", state:"CO", zip: 80110, email: "email@email.com", password: "abcd", password_confirmation:"abcd", role:2)

    @pull_toy = @dog_shop.items.create!(name: "Pull Toy", description: "Great pull toy!", price: 10, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 32)
    @tennis_ball = @dog_shop.items.create!(name: "Tennis Ball", description: "Great ball!", price: 5, image: "http://lovencaretoys.com/image/cache/dog/tu-toy-dog-pull-9010_2-800x800.jpg", inventory: 40)
    @racket = @dog_shop.items.create!(name: "Tennis Racket", description: "Great Tennis Racket!", price: 200, image: "http://lvencaretoys.com/image/cache/dog/tu-toy-dog-pull-9010_2-800x800.jpg", inventory: 10)

    @order1 = Order.create!(name: "Jill", address: "1234 something", city: "Den", state: "CO", zip: 12344, user: @user, status: "pending")
    @orderp = Order.create!(name: "Jack", address: "1234 something", city: "Den", state: "CO", zip: 12344, user: @user, status: "pending")
    @order2 = Order.create!(name: "Sarah", address: "1234 something", city: "Den", state: "CO", zip: 12344, user: @user1, status: "packaged")
    @order3 = Order.create!(name: "Sarah", address: "1234 something", city: "Den", state: "CO", zip: 12344, user: @user1, status: "shipped")
    @order4 = Order.create!(name: "Kevin", address: "1234 something", city: "Den", state: "CO", zip: 12344, user: @user2, status: "cancelled")

    @order1.item_orders.create!(item: @pull_toy, price: @pull_toy.price, quantity: 2)
    @order1.item_orders.create!(item: @tennis_ball, price: @tennis_ball.price, quantity: 1)
    @order2.item_orders.create!(item: @tennis_ball, price: @tennis_ball.price, quantity: 1)
    @order3.item_orders.create!(item: @tennis_ball, price: @tennis_ball.price, quantity: 1)
    @order4.item_orders.create!(item: @tennis_ball, price: @tennis_ball.price, quantity: 1)
    @orderp.item_orders.create!(item: @tennis_ball, price: @tennis_ball.price, quantity: 1)
  end

  it "an Admin can see all orders on dashboard" do
    # allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)

    visit "/login"
    fill_in :email, with: "email@email.com"
    fill_in :password, with: "abcd"
    click_on "Submit"


    expect(current_path).to eq("/admin/dashboard")
    within "#packaged" do
      expect(page).to have_content("#{@order2.name}")
      expect(page).to have_content("#{@order2.id}")
      expect(page).to have_content("#{@order2.created_at}")
      click_link "#{@order2.name}"
    end
      expect(current_path).to eq("/profile/#{@order2.user.id}/admin")

      visit "/admin/dashboard"

    within "#pending" do
      expect(page).to have_content("#{@order1.name}")
      expect(page).to have_content("#{@order1.id}")
      expect(page).to have_content("#{@order1.created_at}")
      expect(page).to_not have_content("#{@order2.name}")
      expect(page).to_not have_content("#{@order2.id}")
      click_link "#{@order1.name}"
    end
      expect(current_path).to eq("/profile/#{@order1.user.id}/admin")

  end

  it "an admin can ship pending orders" do

    visit "/login"
    fill_in :email, with: "email@email.com"
    fill_in :password, with: "abcd"
    click_on "Submit"

    expect(current_path).to eq("/admin/dashboard")

    within "#pending" do
      expect(page).to have_content("#{@order1.name}")
      expect(page).to have_content("#{@order1.id}")
      expect(page).to have_content("#{@order1.created_at}")
      expect("#{@order1.status}").to eq("pending")
      click_link "Ship Order #{@order1.id}"
    end
  end

  it "user cannot cancel shipped orders" do

    visit "/login"
    fill_in :email, with: "email1@email.com"
    fill_in :password, with: "abcd"
    click_on "Submit"
    click_link "My Orders"
    click_on "Show Order #{@order3.id}"
    expect(page).to_not have_content("Cancel")
    visit "/logout"

    visit "/login"
    fill_in :email, with: "email2@email.com"
    fill_in :password, with: "abcd"
    click_on "Submit"
    click_link "My Orders"
    click_on "Show Order #{@order1.id}"
    expect(page).to have_content("Cancel")
  end

  it "only admin can see link to merchant dashboard in nav bar" do
    visit "/login"

    fill_in :email, with: @admin.email
    fill_in :password, with: @admin.password
    click_on "Submit"

    visit "/"
    within '.topnav' do
      expect(page).to have_content("Dashboard")
    end

    visit "/admin"
    within '.topnav' do
      expect(page).to have_content("Dashboard")
    end

    visit "logout"
    visit "login"

    fill_in :email, with: @user.email
    fill_in :password, with: @user.password
    click_on "Submit"

    visit "/"
    within '.topnav' do
      expect(page).to_not have_content("Dashboard")
    end

    visit "/merchants"
    within '.topnav' do
      expect(page).to_not have_content("Dashboard")
    end
  end

  it "admin can use dashboard link to navigate to dashboard" do
    visit "/login"

    fill_in :email, with: @admin.email
    fill_in :password, with: @admin.password
    click_on "Submit"
    visit "/"

    within '.topnav' do
      click_on "Dashboard"
    end

    expect(current_path).to eq("/admin/dashboard")
  end

  it "Dashboard link does not show up while in dashboard" do
    visit "/login"

    fill_in :email, with: @admin.email
    fill_in :password, with: @admin.password
    click_on "Submit"

    within '.topnav' do
      expect(page).to_not have_content("Dashboard")
    end

    expect(current_path).to eq("/admin/dashboard")
  end

end
