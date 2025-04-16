
module Api
  module V1
    class TagsController < ApplicationController
      def index
        if tag_params[:language_id].present?
          @tags = ActsAsTaggableOn::Tag.for_context(language_tag_context)
        else
          @tags = ActsAsTaggableOn::Tag.all
        end

        render json: @tags
      end

      private

      def language_tag_context
        Language.find(params[:language_id]).code.to_sym
      end

      def tag_params
        params.permit(:language_id)
      end
    end
  end
end
