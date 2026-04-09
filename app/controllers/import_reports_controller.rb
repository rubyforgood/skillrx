class ImportReportsController < ApplicationController
  include Pagy::Method

  before_action :redirect_contributors
  before_action :set_import_report, only: [ :show ]

  def index
    @pagy, @import_reports = pagy(scope.includes(:import_errors))

    # Optional filtering by status
    @import_reports = @import_reports.where(status: params[:status]) if params[:status].present?

    # Collect unique statuses and import types for filter dropdowns
    @available_statuses = ImportReport.statuses.keys
    @available_import_types = scope.unscope(:order).distinct.pluck(:import_type).compact.sort
  end

  def show
    @import_errors = @import_report.import_errors
  end

  private

  def set_import_report
    @import_report = ImportReport.includes(:import_errors).find(params[:id])
  end

  def scope
    @scope ||= ImportReport.order(completed_at: :desc)
  end
end
