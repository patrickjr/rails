require 'test_helper'

class BoxUsersControllerTest < ActionController::TestCase
  setup do
    @box_user = box_users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:box_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create box_user" do
    assert_difference('BoxUser.count') do
      post :create, box_user: {  }
    end

    assert_redirected_to box_user_path(assigns(:box_user))
  end

  test "should show box_user" do
    get :show, id: @box_user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @box_user
    assert_response :success
  end

  test "should update box_user" do
    patch :update, id: @box_user, box_user: {  }
    assert_redirected_to box_user_path(assigns(:box_user))
  end

  test "should destroy box_user" do
    assert_difference('BoxUser.count', -1) do
      delete :destroy, id: @box_user
    end

    assert_redirected_to box_users_path
  end
end
