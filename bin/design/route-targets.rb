# Every GET route that renders an HTML screen, with a real record id substituted for :id.
# Printed as JSON: [{path, controller, action}]. This is the adapter's route list for the Ruby For
# Good design system audits (https://github.com/rubyforgood/designsystem). Never hardcode a page
# list instead: a list goes stale silently, and an audit then reports a clean app it never visited.
#
# Usage: bin/rails runner bin/design/route-targets.rb > tmp/design-targets.json
require "json"

# One real record per controller, so :id resolves to something that exists. A controller with no
# record is skipped rather than guessed: a guessed id is a 404 wearing a screen's name.
IDS = {
  "languages" => Language.first, "providers" => Provider.first, "regions" => Region.first,
  "users" => User.first, "tags" => ActsAsTaggableOn::Tag.first, "topics" => Topic.first,
  "import_reports" => ImportReport.first, "beacons" => Beacon.first
}.compact.transform_values(&:id)

# Not screens. registrations#new and topics/tags#index are routed but have no controller (both 500
# with NameError, measured 2026-11-24), and sessions#edit has no action (404). Matched by controller#action, never by action name alone: a bare action name also
# hides any real screen elsewhere that shares it.
SKIP_PAIR = %w[
  beacons#filter_options sessions#show sessions#edit passwords#index passwords#show home#index
  registrations#new topics/tags#index
].freeze
# `/` and `/home/index` both render home#index; keep the root path only.
KEEP_PATH = %w[/].freeze

targets, seen = [], {}
Rails.application.routes.routes.each do |r|
  next unless r.verb.to_s.include?("GET")
  controller, action = r.defaults[:controller], r.defaults[:action]
  next if controller.nil? || controller.start_with?("rails/", "turbo/", "active_storage/", "action_mailbox/", "api/")
  path = r.path.spec.to_s.sub("(.:format)", "")
  next if SKIP_PAIR.include?("#{controller}##{action}") && !KEEP_PATH.include?(path)
  next if path.include?("*") || path == "/up" || path.include?(":token")

  if path.include?(":")
    resolved = true
    path = path.gsub(/:([a-z_]+)_id/) do
      parent = IDS[Regexp.last_match(1).pluralize]
      resolved &&= !parent.nil?
      parent.to_s
    end
    if path.include?(":id")
      own = IDS[controller.split("/").last]
      resolved &&= !own.nil?
      path = path.sub(":id", own.to_s)
    end
    next unless resolved && !path.include?(":")
  end
  next if seen[path]
  seen[path] = true
  targets << {path: path, controller: controller, action: action}
end

puts JSON.generate(targets)
