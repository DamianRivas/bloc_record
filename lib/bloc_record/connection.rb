require 'sqlite3'
require 'pg'

module Connection
  def connection
    case BlocRecord.platform
    when 'sqlite3'
      @connection ||= SQLite3::Database.new(BlocRecord.database_filename)
    when 'pg'
      @connection ||= PG::Connection.open(dbname: BlocRecord.database_filename)
    end
  end

  def query(sql, params=nil)
    case BlocRecord.platform
    when "pg"
      unless params
        connection.exec(sql)
      else
        connection.exec_params(sql, params)
      end
    when "sqlite3"
      connection.execute(sql, params)
    end
  end
end
