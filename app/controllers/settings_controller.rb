class SettingsController < ApplicationController
  def provider
    provider = provider_scope.find(provider_params[:id])
    cookies.signed[:current_provider_id] = provider.id if provider
    redirect_to request.referer || root_path
  end

  private

  def provider_params
    params.expect(provider: :id)
  end
end
