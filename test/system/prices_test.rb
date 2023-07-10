require "application_system_test_case"

class PricesTest < ApplicationSystemTestCase
  setup do
    @price = prices(:one)
  end

  test "visiting the index" do
    visit prices_url
    assert_selector "h1", text: "Prices"
  end

  test "should create price" do
    visit prices_url
    click_on "New price"

    fill_in "Discount price", with: @price.discount_price
    fill_in "Original price", with: @price.original_price
    fill_in "Product", with: @price.product_id
    click_on "Create Price"

    assert_text "Price was successfully created"
    click_on "Back"
  end

  test "should update Price" do
    visit price_url(@price)
    click_on "Edit this price", match: :first

    fill_in "Discount price", with: @price.discount_price
    fill_in "Original price", with: @price.original_price
    fill_in "Product", with: @price.product_id
    click_on "Update Price"

    assert_text "Price was successfully updated"
    click_on "Back"
  end

  test "should destroy Price" do
    visit price_url(@price)
    click_on "Destroy this price", match: :first

    assert_text "Price was successfully destroyed"
  end
end
