module ProvidersHelper
  # Deleting a provider doesn't delete its topics: they're left with no provider and stop appearing
  # anywhere (measured 2026-11-25; no foreign key prevents it). Until the app decides what should
  # happen, the confirmation says so plainly.
  def provider_delete_warning(provider, count = provider.topics.count)
    message = "Delete #{provider.name}? This can't be undone."
    return message if count.zero?

    "#{message} Its #{pluralize(count, "topic")} will be left without a provider and won't appear in any list."
  end

end
