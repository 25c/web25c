require 'test_helper'

class ButtonControllerTest < ActionController::TestCase
  
  setup do
    @user = users(:sylvio)
    @publisher = users(:duane)
  end
  
  test "should get state unauthorized" do
    get :state, { :format => :json }
    assert_response :success
    result = JSON.parse(@response.body)
    assert_equal 'unauthorized', result['response']
  end
  
  test "should get state ok" do
    get :state, { :format => :json }, { :user => @user.uuid }
    assert_response :success
    result = JSON.parse(@response.body)
    assert_equal 'ok', result['response']
  end
  
  test "should post click unauthorized" do
    get :click, { :format => :json, :publisher_id => @publisher.uuid }
    assert_response :success
    result = JSON.parse(@response.body)
    assert_equal 'unauthorized', result['response']
  end
  
  test "should post click ok" do
    assert_equal 0, @user.clicks_submitted.size
    get :click, { :format => :json, :publisher_id => @publisher.uuid, :url => "http://test.com/" }, { :user => @user.uuid }
    assert_response :success
    result = JSON.parse(@response.body)
    assert_equal 'ok', result['response']
    
    @user.reload
    assert_equal 1, @user.clicks_submitted.size
    
    click = @user.clicks_submitted.first
    assert_equal @publisher.id, click.publisher_user_id
    assert_equal @user.id, click.user_id
    assert_equal "http://test.com/", click.url
  end
  
end
