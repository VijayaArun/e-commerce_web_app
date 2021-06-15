module Spree
  module Admin
    class RacksController < ResourceController
      def index
        @racks = Rack.all.includes(:stock_location)
      end

      def new
          @rack = Rack.new
          @stock_locations = Spree::StockLocation.all
      end

      def create
        @stock_locations = Spree::StockLocation.all
        count_of_racks = params[:rack][:name].split(',').count
        @stock_location = params[:rack][:stock_location_id]
        if (count_of_racks > 1)
          no_of_racks = params[:rack][:name].split(',')
          unique_rack_names = []
          if params[:rack][:name].present?
            rack_names = params[:rack][:name].split(',')
            # @new_ ms[:rack][:name]
          end
          rack_names.each do |rack_name|
            if check_for_unique_rack_name(rack_name,nil) == true
              unique_rack_names << rack_name
            end
            unique_rack_names
          end
          no_of_racks.each_with_index do |rack, index|
            if rack_names - unique_rack_names == []
              @new_rack_name = unique_rack_names[index].upcase
              @rack = Rack.new(name: @new_rack_name, stock_location_id: params[:rack][:stock_location_id])
              @rack.save
              flash[:success] = flash_message_for(@rack, :successfully_created)
            else
              flash[:error] = Spree.t(:please_give_unique_rack_name)
            end
          end
          redirect_to admin_racks_path
        else
          if params[:rack][:name].present?
            @new_rack_name = params[:rack][:name].upcase
          end
          if check_for_unique_rack_name(@new_rack_name,nil) == true
            @rack = Rack.new(name: @new_rack_name, stock_location_id: params[:rack][:stock_location_id])
            if @rack.save
              flash[:success] = flash_message_for(@rack, :successfully_created)
              redirect_to admin_racks_path
            else
              render :new, status: :unprocessable_entity
            end
          else
            flash[:error] = Spree.t(:please_give_unique_rack_name)
            render :new, status: :unprocessable_entity
          end
        end
      end

      def check_for_unique_rack_name(rack_name,current_rack_name)
        if (rack_name == current_rack_name)
          return true
        else
          rack_names = Rack.pluck(:name)
          #rack_names = Rack.where(id: rack_id).pluck(:name)
          if !rack_names.collect {|e| e.downcase}.include? rack_name.downcase
            return true
          else
            return false
          end
        end
      end

      def edit
        @rack = Rack.find(params[:id])
        @stock_locations = Spree::StockLocation.all
      end

      def update
        @rack = Rack.find(params[:id])
        @stock_location = params[:rack][:stock_location_id]
        if check_for_unique_rack_name(params[:rack][:name],@rack.name) == true
          if @rack.update_attributes(permitted_resource_params_update)
            flash[:success] = flash_message_for(@rack, :successfully_updated)
            redirect_to edit_admin_rack_path
          else
            @stock_locations = Spree::StockLocation.all
            render :edit, status: :unprocessable_entity
          end
        else
          flash[:error] = Spree.t(:please_give_unique_rack_name)
          @stock_locations = Spree::StockLocation.all
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        rack_items = RackItem.where(rack_id: params[:id])
        is_stock = false
        rack_items.each do |rack_item|
          if rack_item.count_on_hand > 0
            is_stock = true
            break;
          end
        end
        unless (is_stock)
          super
        else
          render :json => Spree.t(:still_stock_on_rack), :status => 428, :content_type => 'text/html'
        end
      end

      private

      def permitted_resource_params
        params.require(:rack).permit([:stock_location_id, :name])
      end

      def permitted_resource_params_update
        params.require(:rack).permit([:name])
      end
    end
  end
end