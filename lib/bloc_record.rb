module BlocRecord
  def self.connect_to(filename, platform)
    @database_filename = filename
    @platform = platform.to_s
  end

  def self.database_filename
    @database_filename
  end

  def self.platform
    @platform
  end
end
