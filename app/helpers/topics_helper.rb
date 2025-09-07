module TopicsHelper
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
