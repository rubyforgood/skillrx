class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def provider_scope
    @provider_scope ||= if Current.user.is_admin?
      Provider.all
    else
      Current.user.providers
    end
  end

  def current_provider
    @current_provider ||= begin
      provider_scope.find(cookies.signed[:current_provider_id])
    rescue ActiveRecord::RecordNotFound
      provider_scope.first || NullProvider.new
    end
  end
  helper_method :current_provider

  # "Clear filters" is a submit button in a list's form (name="clear"), not a link, so it sends the
  # current sort: a link's address is drawn with the page, and changing Sort only reloads the list.
  # Redirect to the list with the sort kept and every filter dropped (sort isn't a filter:
  # docs/design/decisions.md, 2026-11-26). `extra` adds params, such as Topics' provider=all.
  def redirect_clearing_filters(path_helper, **extra)
    order = params.dig(:search, :order).presence
    query = extra
    query = query.merge(search: { order: }) if order
    redirect_to public_send(path_helper, query)
  end

  def non_contributor_redirect_path
    topics_path
  end
end
