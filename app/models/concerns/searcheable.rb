module Searcheable
  extend ActiveSupport::Concern

  SEARCH = Data.define(:query, :state, :provider_id, :language_id, :year, :month, :order)
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

    def by_provider(provider_id)
      where(provider_id: provider_id)
    end

    def by_language(language_id)
      where(language_id: language_id)
    end

    def by_state(state)
      where(state: state)
    end

    def order(order_from_params)
      return :desc unless SORTS.include?(order_from_params)

      order_from_params
    end

    def search_with_params(params)
      self
        .then { |scope| params[:state].present? ? scope.by_state(params[:state]) : scope }
        .then { |scope| params[:provider_id].present? ? scope.by_provider(params[:provider_id]) : scope }
        .then { |scope| params[:language_id].present? ? scope.by_language(params[:language_id]): scope }
        .then { |scope| params[:year].present? ? scope.by_year(params[:year]) : scope }
        .then { |scope| params[:month].present? ? scope.by_month(params[:month]) : scope }
        .then { |scope| params[:query].present? ? scope.search(params[:query]) : scope }
        .then { |scope| scope.order(created_at: order(params[:order])) }
    end
  end
end
