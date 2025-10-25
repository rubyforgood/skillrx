class CsvGenerator::Base
  def perform
    CSV.generate(row_sep: "\n") do |csv|
      csv << headers
      scope.each do |row|
        csv << row
      end
    end
  end
end
