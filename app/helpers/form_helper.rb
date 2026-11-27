# One form field, server-rendered (docs/design/design.md, "Forms"): label, required marker, hint and
# error, wired with aria-describedby and aria-invalid so a screen reader hears all of it.
#
#   <%= form_field f, :title, label: "Title", required: true, hint: "…" do %>
#     <%= f.text_field :title, class: "form-input" %>
#   <% end %>
#
# The block renders the control; this adds the id/aria attributes to it.
module FormHelper
  def form_field(form, attribute, label:, required: false, optional: false, hint: nil, for_id: nil, &block)
    object = form.object
    input_id = for_id || [form.object_name.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, ""), attribute].join("_")
    # A select of ids (language_id) also shows its association's errors (belongs_to puts "required" on
    # :language), so the message sits at the field and not only in the summary.
    errors = if object.respond_to?(:errors)
      [ attribute.to_s, attribute.to_s.delete_suffix("_id") ].uniq.flat_map { object.errors.full_messages_for(_1) }
    else
      []
    end
    hint_id = "#{input_id}_hint" if hint
    error_id = "#{input_id}_error" if errors.any?
    described = [hint_id, error_id].compact.join(" ").presence

    control = capture(&block)
    control = control.sub(/<(input|select|textarea)\b/) do
      extra = +""
      extra << %( aria-describedby="#{described}") if described
      extra << %( aria-invalid="true") if errors.any?
      extra << %( aria-required="true") if required
      "<#{Regexp.last_match(1)}#{extra}"
    end.html_safe

    tag.div(class: ["form-field", ("form-field--invalid" if errors.any?)]) do
      safe_join([
        label_tag(input_id, class: "form-label") do
          safe_join([label, (tag.abbr("*", title: "required", class: "form-required") if required),
                     (tag.span(" (optional)", class: "form-optional") if optional)].compact)
        end,
        (tag.p(hint, id: hint_id, class: "form-help-text") if hint),
        control,
        (tag.p(errors.to_sentence, id: error_id, class: "form-error") if errors.any?)
      ].compact)
    end
  end
end
