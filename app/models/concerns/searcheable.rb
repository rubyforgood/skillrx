module Searcheable
  extend ActiveSupport::Concern

  SORTS = %i[asc desc].freeze

  class_methods do
    def search(query)
      where("title ILIKE :query OR description ILIKE :query", query: "%#{query}%")
    end

    def by_year(year)
      where("extract(year from created_at) = ?", year)
    end

    def by_month(month)
      where("extract(month from created_at) = ?", month)
    end

    def by_language(language_id)
      where(language_id: language_id)
    end

    def by_state(state)
      where(state: state)
    end

    def by_tag_list(tag_list)
      tagged_with(tag_list, any: true)
    end

    def sort_order(order_from_params)
      return :desc unless SORTS.include?(order_from_params)

      order_from_params
    end
  end

  included do
    scope :search_with_params, ->(params) do
      self
        .then { |scope| params[:state].present? ? scope.by_state(params[:state]) : scope }
        .then { |scope| params[:language_id].present? ? scope.by_language(params[:language_id]): scope }
        .then { |scope| params[:year].present? ? scope.by_year(params[:year]) : scope }
        .then { |scope| params[:month].present? ? scope.by_month(params[:month]) : scope }
        .then { |scope| params[:query].present? ? scope.search(params[:query]) : scope }
        .then { |scope| params[:tag_list].present? ? scope.by_tag_list(params[:tag_list]) : scope }
        .then { |scope| scope.order(created_at: sort_order(params[:order].present? ? params[:order].to_sym : :desc)) }
    end
  end
end
