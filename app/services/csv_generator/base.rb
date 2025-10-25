class CsvGenerator::Base
  def initialize(source, **args)
    @source = source
    @args = args
  end

  def perform
    CSV.generate(row_sep: "\n") do |csv|
      csv << headers
      scope.each do |row|
        csv << row
      end
    end
  end

  private

  attr_reader :source, :args

  def topics_collection
    return source.topics if provider?

    source.topics
  end

  def language = language? ? source : args.fetch(:language)
  def language? = source.is_a?(Language)
  def provider? = source.is_a?(Provider)
end
