module Pagination
extend ActiveSupport::Concern

def default_per_page
    25
end

def page_no
    params[:page]&.to_i || 1
end

def per_page
    params[:per_page]&.to_i || default_per_page
end

def paginate_offset
    (page_no - 1) * per_page
end

def order_by
    params.fetch(:order_by, :id)
end

def order_direction
    params.fetch(:order_direction, :asc)
end

def paginate
    ->(it) { it.limit(per_page).offset(paginate_offset).order("#{order_by}": order_direction) }
end
end
