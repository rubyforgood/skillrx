
module Api
  module V1
    class TagsController < ApplicationController
      before_action :validate_language

      def index
        @tags = ActsAsTaggableOn::Tag.for_context(language_tag_context)

        render json: @tags
      end

      private

      def language_tag_context
        Language.find(params[:language_id]).code.to_sym
      end

      def validate_language
        render_error unless language_id_param
      end

      def language_id_param
        params.require(:language_id)
      end

      def render_error
        render json: { error: "Language is required" }, status: :bad_request
      end
    end
  end
end
