# Beacon status in words and tone (docs/design/design.md, "Beacons"). One status per beacon: Revoked
# if its key is revoked, otherwise what it last reported about syncing.
module BeaconsHelper
  STATUSES = {
    "revoked" => ["Revoked", "neutral"],
    "synced" => ["Synced", "success"],
    "syncing" => ["Syncing", "info"],
    "outdated" => ["Needs update", "warning"],
    "error" => ["Error", "danger"],
    nil => ["Never synced", "neutral"]
  }.freeze

  def beacon_status_key(beacon)
    beacon.revoked? ? "revoked" : beacon.sync_status
  end

  def beacon_status_pill(beacon)
    label, tone = STATUSES.fetch(beacon_status_key(beacon), STATUSES[nil])
    tag.send(:"rfg-status-pill", label, tone: tone)
  end

  # "5 minutes ago", with the exact time on hover and for assistive tech. "Never" when blank.
  def time_ago_or_never(time)
    return tag.span("Never", class: "muted") if time.blank?

    tag.time("#{time_ago_in_words(time)} ago", datetime: time.iso8601, title: time.strftime("%b %-d, %Y at %-l:%M %p"))
  end
end
