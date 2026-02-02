module ApplicationHelper
  include Pagy::Frontend

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

  def nav_link_class(path)
    base_style = "display: flex; align-items: center; gap: 0.75rem; padding: 0.75rem 1rem; text-decoration: none; border-radius: 0.5rem; transition: all 0.2s; font-weight: 500;"

    if current_page?(path)
      base_style + " background-color: #dbeafe; color: #1d4ed8;"
    else
      base_style + " color: #374151;"
    end
  end
end
