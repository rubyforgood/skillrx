class CsvGenerator::Base
  def perform
    CSV.generate do |csv|
      csv << headers
      scope.each do |row|
        csv << row
      end
    end
  end
end
