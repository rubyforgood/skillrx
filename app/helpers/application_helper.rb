module ApplicationHelper
  include Pagy::Frontend

  def flash_class(level)
    case level
    when "notice" then "alert-light-success"
    when "alert" then "alert-light-danger"
    else "alert-light-info"
    end
  end
end
