module PaginationHelper
  def custom_pagy_nav(pagy)
    return "" unless pagy.pages > 1

    content_tag :nav, class: "pagination-nav", 'aria-label': "Pagination Navigation" do
      content_tag :ul, class: "pagination-list" do
        safe_join([
          prev_link(pagy),
          page_links(pagy),
          next_link(pagy),
        ].compact)
      end
    end
  end

  private

  def prev_link(pagy)
    if pagy.prev
      content_tag :li, class: "pagination-item" do
        link_to pagy_url_for(pagy, pagy.prev),
                class: "pagination-link pagination-prev",
                'aria-label': "Go to previous page" do
          content_tag(:span, class: "pagination-icon") do
            svg_icon("chevron-left")
          end +
          content_tag(:span, "Previous", class: "pagination-text")
        end
      end
    else
      content_tag :li, class: "pagination-item pagination-disabled" do
        content_tag :span, class: "pagination-link pagination-prev" do
          content_tag(:span, class: "pagination-icon") do
            svg_icon("chevron-left")
          end +
          content_tag(:span, "Previous", class: "pagination-text")
        end
      end
    end
  end

  def next_link(pagy)
    if pagy.next
      content_tag :li, class: "pagination-item" do
        link_to pagy_url_for(pagy, pagy.next),
                class: "pagination-link pagination-next",
                'aria-label': "Go to next page" do
          content_tag(:span, "Next", class: "pagination-text") +
          content_tag(:span, class: "pagination-icon") do
            svg_icon("chevron-right")
          end
        end
      end
    else
      content_tag :li, class: "pagination-item pagination-disabled" do
        content_tag :span, class: "pagination-link pagination-next" do
          content_tag(:span, "Next", class: "pagination-text") +
          content_tag(:span, class: "pagination-icon") do
            svg_icon("chevron-right")
          end
        end
      end
    end
  end

  def page_links(pagy)
    pagy.series.map do |item|
      case item
      when Integer
        page_link(pagy, item)
      when "gap"
        gap_element
      end
    end
  end

  def page_link(pagy, page)
    if page == pagy.page
      content_tag :li, class: "pagination-item pagination-current" do
        content_tag :span, page, class: "pagination-link", 'aria-current': "page"
      end
    else
      content_tag :li, class: "pagination-item" do
        link_to page, pagy_url_for(pagy, page),
                class: "pagination-link",
                'aria-label': "Go to page #{page}"
      end
    end
  end

  def gap_element
    content_tag :li, class: "pagination-item pagination-gap" do
      content_tag :span, "…", class: "pagination-link"
    end
  end

  def svg_icon(name)
    case name
    when "chevron-left"
      '<svg style="width: 1rem; height: 1rem;" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>'.html_safe
    when "chevron-right"
      '<svg style="width: 1rem; height: 1rem;" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>'.html_safe
    end
  end
end
