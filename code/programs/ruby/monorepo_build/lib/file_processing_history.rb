require 'set'

class FileProcessingHistory
  def initialize
    @processed_files = Set.new
  end

  def already_processed?(path)
    @processed_files.include?(path)
  end

  def mark_processed(path)
    @processed_files.add(path)
  end
end
