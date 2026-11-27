# Buttons in the Jobs engine's pages (layouts/mission_control/jobs), in the app's variants
# (docs/design/design.md, "Buttons"). The same action partials render in a list's rows and in a
# job or queue page's header: in a row they're ghost at 32px, like every row action in the app; in
# the header, the action is secondary at 40px. Discard is ghost-danger in both: red only on hover,
# the confirmation is what protects.
module JobsHelper
  def jobs_button_class(kind = :action)
    in_row = action_name == "index"
    variant = (kind == :discard) ? "button-ghost-danger" : (in_row ? "button-ghost" : "button-secondary")
    [ "button", variant, ("button-sm" if in_row) ].compact.join(" ")
  end
end
