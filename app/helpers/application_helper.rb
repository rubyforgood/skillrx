module ApplicationHelper
  def flash_class(level)
    case level
    when "notice" then "alert-light-success"
    when "alert" then "alert-light-danger"
    else "alert-light-info"
    end
  end

  def tailwind_flash_class(level)
    case level
    when "notice" then "bg-gradient-to-r from-green-50 to-emerald-50 border border-green-200 text-green-800 shadow-sm"
    when "alert" then "bg-gradient-to-r from-red-50 to-rose-50 border border-red-200 text-red-800 shadow-sm"
    when "warning" then "bg-gradient-to-r from-yellow-50 to-amber-50 border border-yellow-200 text-yellow-800 shadow-sm"
    when "error" then "bg-gradient-to-r from-red-50 to-rose-50 border border-red-200 text-red-800 shadow-sm"
    when "success" then "bg-gradient-to-r from-green-50 to-emerald-50 border border-green-200 text-green-800 shadow-sm"
    when "info" then "bg-gradient-to-r from-blue-50 to-cyan-50 border border-blue-200 text-blue-800 shadow-sm"
    else "bg-gradient-to-r from-gray-50 to-slate-50 border border-gray-200 text-gray-800 shadow-sm"
    end
  end

  # A sidebar destination: `nav_link_to "Label", path` or `nav_link_to(path) { ... }`. Current for
  # its own path and everything under it, so /topics/new still shows Topics as where you are.
  # `aria-current` carries both the meaning and the styling; there is no separate active class.
  def nav_link_to(name_or_path, path = nil, **options, &block)
    path = name_or_path if block
    current = nav_section_current?([path])
    attrs = options.merge(class: ["shell-nav-link", options[:class]].compact.join(" "),
                          aria: {current: (current ? "page" : nil)})
    block ? link_to(path, **attrs, &block) : link_to(name_or_path, path, **attrs)
  end

  # True when the current page is one of the given paths or under one, so the nav group holding
  # it opens on load.
  def nav_section_current?(paths)
    paths.any? { |path| request.path == path || request.path.start_with?("#{path}/") }
  end
end
