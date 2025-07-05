class ImportJob < ApplicationJob
  def perform
    DataImport.reset
  end
end
