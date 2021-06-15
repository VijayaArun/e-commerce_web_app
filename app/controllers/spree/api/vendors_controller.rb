
class Spree::Api::VendorsController < Spree::Api::BaseController
  include Spree::AuthenticationHelpers
  include UserHelper
  include VendorHelper

  before_action :authorize_salesman!, only: :vendor_visit

	#Api to get vendor details
  def index
    if api_key.blank? 
      user = spree_current_user
      @users = user.vendors
    else
      @users = current_api_user.vendors
    end 
  end

  #Api to create a vendor
  def create
    if api_key.blank?
      current_user_id = spree_current_user[:id]
    else
      user = Spree::User.find_by(spree_api_key: api_key)
      current_user_id = user[:id]
    end
    create_vendor(current_user_id)
  end

  def vendor_visit
    @visit = Visit.new(vendor_visit_params.merge(salesman_id: current_api_user.id))
    visit_remark_params = {:action => "Vendor visit",:content => params[:visit][:remark]}
    @visit.build_visit_remark(visit_remark_params) if params[:visit][:remark].present?
    @visit.spree_order_number = params[:visit][:order] if params[:visit][:order].present?
    unless @visit.save
      render :json => @visit.errors.messages, status: 422
    end
  end

  private

  def vendor_visit_params
      params.require(:visit).permit(:vendor_id , :in_time , :out_time)
  end

  def authorize_salesman!
    head 401 unless current_api_user.vendors.pluck(:user_id).include?(params[:visit][:vendor_id].try(:to_i))
  end

end

