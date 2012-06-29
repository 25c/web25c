require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  test "should create a button" do
    user = User.create!(
      :email => "test@test.com",
      :password => "asdfasdf"
    )
    # force refresh from database
    user.reload
    # assert that a single default button has been created
    assert_equal 1, user.buttons.size
  end

end
