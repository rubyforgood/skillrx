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
    when "notice" then "bg-green-100 border border-green-200 text-green-800"
    when "alert" then "bg-red-100 border border-red-200 text-red-800"
    else "bg-blue-100 border border-blue-200 text-blue-800"
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
