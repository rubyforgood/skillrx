module PaginationHelper
  def custom_pagy_nav(pagy, params: {})
    return "" unless pagy.pages > 1

    content_tag :nav, 'aria-label': "Page navigation" do
      content_tag :ul, class: "flex -space-x-px text-sm", style: "list-style: none; margin: 0; padding: 0;" do
        safe_join([
          prev_link(pagy, params),
          page_links(pagy, params),
          next_link(pagy, params),
        ].compact.flatten)
      end
    end
  end

  private

  def prev_link(pagy, extra_params)
    content_tag :li, style: "list-style: none;" do
      if pagy.prev
        link_to "Previous", pagy_url_for(pagy, pagy.prev, **extra_params),
                class: "flex items-center justify-center text-gray-700 bg-gray-100 border border-gray-300 hover:bg-blue-600 hover:text-white font-medium rounded-l-md text-sm px-3 h-10",
                style: "box-sizing: border-box;",
                'aria-label': "Go to previous page"
      else
        content_tag :span, "Previous",
                    class: "flex items-center justify-center text-gray-400 bg-gray-50 border border-gray-300 font-medium rounded-l-md text-sm px-3 h-10 cursor-not-allowed",
                    style: "box-sizing: border-box;"
      end
    end
  end

  def next_link(pagy, extra_params)
    content_tag :li, style: "list-style: none;" do
      if pagy.next
        link_to "Next", pagy_url_for(pagy, pagy.next, **extra_params),
                class: "flex items-center justify-center text-gray-700 bg-gray-100 border border-gray-300 hover:bg-blue-600 hover:text-white font-medium rounded-r-md text-sm px-3 h-10",
                style: "box-sizing: border-box;",
                'aria-label': "Go to next page"
      else
        content_tag :span, "Next",
                    class: "flex items-center justify-center text-gray-400 bg-gray-50 border border-gray-300 font-medium rounded-r-md text-sm px-3 h-10 cursor-not-allowed",
                    style: "box-sizing: border-box;"
      end
    end
  end

  def page_links(pagy, extra_params)
    pagy.series.map do |item|
      case item
      when Integer
        page_link(pagy, item, extra_params)
      when String
        # Handle page numbers that come as strings (like "1") or gaps
        if item == "gap"
          gap_element
        else
          # Convert string page number to integer
          page_link(pagy, item.to_i, extra_params)
        end
      when :gap
        gap_element
      end
    end
  end

  def page_link(pagy, page, extra_params)
    content_tag :li, style: "list-style: none;" do
      if page == pagy.page
        content_tag :span, page,
                    class: "flex items-center justify-center text-blue-600 bg-blue-50 border border-gray-300 font-semibold text-sm w-10 h-10",
                    style: "box-sizing: border-box;",
                    'aria-current': "page"
      else
        link_to page, pagy_url_for(pagy, page, **extra_params),
                class: "flex items-center justify-center text-gray-700 bg-gray-100 border border-gray-300 hover:bg-blue-600 hover:text-white font-medium text-sm w-10 h-10",
                style: "box-sizing: border-box;",
                'aria-label': "Go to page #{page}"
      end
    end
  end

  def gap_element
    content_tag :li, style: "list-style: none;" do
      content_tag :span, "…",
                  class: "flex items-center justify-center text-gray-700 bg-gray-100 border border-gray-300 font-medium text-sm w-10 h-10",
                  style: "box-sizing: border-box;"
    end
  end
end
