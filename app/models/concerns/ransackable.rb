module Ransackable
  extend ActiveSupport::Concern

  class_methods do
    private

    def common_attributes
      %w[id created_at updated_at]
    end

    def base_namespace
      "Bscf::Core::"
    end

    def model_attributes_mapping
      @model_attributes_mapping ||= {
        "DeliveryOrder" => {
          attributes: %w[driver_phone delivery_notes estimated_delivery_time delivery_start_time delivery_end_time status driver_id pickup_address_id actual_delivery_time actual_delivery_price estimated_delivery_price],
          associations: %w[driver pickup_address delivery_order_items]
        },
        "DeliveryOrderItem" => {
          attributes: %w[delivery_order_id order_item_id quantity status notes pickup_address_id dropoff_address_id position],
          associations: %w[delivery_order order_item pickup_address dropoff_address]
        },
        "Address" => {
          attributes: %w[city sub_city woreda latitude longitude house_number],
          associations: %w[pickup_delivery_orders dropoff_delivery_order_items pickup_delivery_order_items]
        },
        "Vehicle" => {
          attributes: %w[driver_id plate_number vehicle_type brand model year color],
          associations: %w[driver]
        }
      }.freeze
    end

    def model_key
      self.name.delete_prefix(base_namespace)
    end

    def model_config
      model_attributes_mapping[model_key] || { attributes: [], associations: [] }
    end

    public

    def ransackable_attributes(auth_object = nil)
      attributes = common_attributes + model_config[:attributes]
      Set.new(attributes).freeze & column_names
    end

    def ransackable_associations(auth_object = nil)
      associations = model_config[:associations]
      Set.new(associations).freeze & reflect_on_all_associations.map(&:name).map(&:to_s)
    end

    def ransackable_scopes(auth_object = nil)
      []
    end
  end
end
