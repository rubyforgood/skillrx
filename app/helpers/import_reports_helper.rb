module ImportReportsHelper
  TONES = { "completed" => "success", "failed" => "danger", "pending" => "neutral", "planned" => "info" }.freeze

  def import_status_pill(report)
    tag.send(:"rfg-status-pill", report.status.to_s.humanize, tone: TONES.fetch(report.status.to_s, "neutral"))
  end

  def import_time(time, blank)
    time ? time.strftime("%b %-d, %Y at %-l:%M %p") : tag.span(blank, class: "muted")
  end
end
