require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  test "should_create_user_with_tipper_role" do
    user = User.new
    user.password = SecureRandom.hex
    user.facebook_uid = "100004500043696"
    assert user.save
    assert_equal "tipper", user.role
  end
  
end
