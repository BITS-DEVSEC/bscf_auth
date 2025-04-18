module Common
  extend ActiveSupport::Concern
  include Pagination

  included do
    before_action :set_clazz
    before_action :set_object, only: %i[show update]
  end

  def index
    data = nil
    options = {}
    if block_given?
      incoming = yield
      if incoming.instance_of?(Array)
        data, options = incoming
      elsif incoming.instance_of?(Hash)
        options = incoming
      else
        data = incoming
      end
    else
      data = @clazz.all
    end

    data = filter_records(data) if params[:q].present?

    total = data.count
    data = data.then(&paginate) if params[:page]
    result = {
      success: true,
      data: serialize(data, options)
    }
    if params[:page]
      result[:page] = params[:page]
      result[:total] = total
    end

    render json: result
  end

  def show
    data = nil
    options = {}
    if block_given?
      incoming = yield
      if incoming.instance_of?(Array)
        data, options = incoming
      elsif incoming.instance_of?(Hash)
        data = @obj
        options = incoming
      else
        data = incoming
      end
    else
      data = @obj
    end
    result = {
      success: true,
      data: serialize(data, options)
    }
    render json: result
  end

  def create
    obj = nil
    options = {}
    if block_given?
      incoming = yield
      if incoming.instance_of?(Array)
        obj, options = incoming
      elsif incoming.instance_of?(Hash)
        obj = @clazz.new(model_params)
        options = incoming
      else
        obj = incoming
      end
    else
      obj = @clazz.new(model_params)
    end

    if obj.save
      result = {
        success: true,
        data: serialize(obj, options)
      }
      render json: result, status: :created
    else
      render json: { success: false, error: obj.errors.full_messages[0] }, status: 422
    end
  rescue StandardError => e
    render json: { success: false, error: e.message }
  end

  def update
    obj = nil
    options = {}
    if block_given?
      incoming = yield
      if incoming.instance_of?(Array)
        obj, options = incoming
      elsif incoming.instance_of?(Hash)
        obj = set_object
        options = incoming
      else
        obj = incoming
      end
    else
      obj = set_object
    end

    if obj.update(model_params)
      result = {
        success: true,
        data: serialize(obj, options)
      }
      render json: result
    else
      render json: { success: false, error: obj.errors.full_messages[0] }, status: 422
    end
  rescue StandardError => e
    render json: { success: false, error: e.message }
  end

  private

  def serialize(data, options = {})
    ActiveModelSerializers::SerializableResource.new(data, options)
  end

  def set_clazz
    @clazz = "Bscf::Core::#{controller_name.classify}".constantize
  end

  def set_object
    @obj = @clazz.find(params[:id])
  end

  # This method should be overridden by respective child controllers
  def model_params; end
end
