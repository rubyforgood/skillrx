module TopicsHelper
  def topic_sort_header(label, column)
    current_column = search_params[:sort].presence_in(%w[published_at created_at]) || "published_at"
    current_order = search_params[:order].presence_in(%w[asc desc]) || "desc"
    active = current_column == column.to_s
    next_order = current_order
    next_order = current_order == "asc" ? "desc" : "asc" if active
    indicator = active ? (current_order == "asc" ? "▲" : "▼") : "↕"
    query = search_params.to_h.merge(sort: column, order: next_order)

    link_to topics_path(search: query),
      class: "inline-flex items-center gap-1 hover:text-gray-900 focus-visible:outline-2 focus-visible:outline-offset-2",
      aria: { label: "Sort by #{label} #{next_order == "asc" ? "ascending" : "descending"}" },
      data: { turbo_frame: "_top" } do
      safe_join([
        content_tag(:span, label),
        content_tag(:span, indicator, class: active ? "text-gray-700" : "text-gray-400", aria: { hidden: true }),
      ])
    end
  end

  def topic_sort_aria(column)
    current_column = search_params[:sort].presence_in(%w[published_at created_at]) || "published_at"
    return "none" unless current_column == column.to_s

    search_params[:order] == "asc" ? "ascending" : "descending"
  end

  def card_preview_media(file)
    case file.content_type
    in /image/ then render_image(file)
    in /pdf/ then render_pdf(file)
    in /video/ then render_video(file)
    in /audio/ then render_audio(file)
    else render_download_link(file)
    end
  end

  private

  def render_image(file)
    image_tag(rails_blob_path(file, disposition: "inline"), class: "img-fluid w-100")
  end

  def render_pdf(file)
    content_tag(:div, class: "embed-responsive embed-responsive-item embed-responsive-16by9 w-100") do
      content_tag(:object, data: rails_blob_path(file, disposition: "inline"), type: "application/pdf", width: "100%", height: "400px") do
        content_tag(:iframe, "", src: rails_blob_path(file, disposition: "inline"), width: "100%", height: "100%", style: "border: none;") do
          content_tag(:p, "Your browser does not support PDF viewing. #{link_to('Download the PDF', rails_blob_path(file))}")
        end
      end
    end
  end

  def render_video(file)
    video_tag(rails_blob_path(file, disposition: "inline"), style: "width: 100%")
  end

  def render_audio(file)
    audio_tag(rails_blob_path(file, disposition: "inline"), controls: true, style: "width: 100%")
  end

  def render_download_link(file)
    link_to file.filename, rails_blob_path(file)
  end
end
