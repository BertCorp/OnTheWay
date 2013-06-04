require 'test_helper'

class AppointmentsControllerTest < ActionController::TestCase
  setup do
    @appointment = appointments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:appointments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create appointment" do
    assert_difference('Appointment.count') do
      post :create, appointment: { arrived_at: @appointment.arrived_at, company_id: @appointment.company_id, confirmed_at: @appointment.confirmed_at, customer_id: @appointment.customer_id, feedback: @appointment.feedback, finished_at: @appointment.finished_at, provider_id: @appointment.provider_id, provider_location: @appointment.provider_location, rating: @appointment.rating, shortcode: @appointment.shortcode, status: @appointment.status, when: @appointment.when, where: @appointment.where }
    end

    assert_redirected_to appointment_path(assigns(:appointment))
  end

  test "should show appointment" do
    get :show, id: @appointment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @appointment
    assert_response :success
  end

  test "should update appointment" do
    put :update, id: @appointment, appointment: { arrived_at: @appointment.arrived_at, company_id: @appointment.company_id, confirmed_at: @appointment.confirmed_at, customer_id: @appointment.customer_id, feedback: @appointment.feedback, finished_at: @appointment.finished_at, provider_id: @appointment.provider_id, provider_location: @appointment.provider_location, rating: @appointment.rating, shortcode: @appointment.shortcode, status: @appointment.status, when: @appointment.when, where: @appointment.where }
    assert_redirected_to appointment_path(assigns(:appointment))
  end

  test "should destroy appointment" do
    assert_difference('Appointment.count', -1) do
      delete :destroy, id: @appointment
    end

    assert_redirected_to appointments_path
  end
end
