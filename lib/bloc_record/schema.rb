require 'sqlite3'
require 'bloc_record/utility'

module Schema
  def table
    BlocRecord::Utility.underscore(name)
  end

  def schema
    unless @schema
      @schema = {}
      case BlocRecord.platform
      when 'sqlite3'
        connection.table_info(table) do |col|
          @schema[col['name']] = col['type']
        end
      when 'pg'
        sql = <<-SQL
          SELECT attname, format_type(atttypid, atttypmod) AS type
          FROM pg_attribute
          WHERE attrelid = #{BlocRecord::Utility.sql_strings(table)}::regclass
          AND attnum > 0
          AND NOT attisdropped
          ORDER BY attnum;
        SQL
        result = query(sql)
        result.each do |col|
          @schema[col['attname']] = col['type']
        end
      end
    end
    @schema
  end

  def columns
    schema.keys
  end

  def attributes
    columns - ['id']
  end

  def count
    res = query <<-SQL
      SELECT COUNT(*) FROM #{table};
    SQL
    case BlocRecord.platform
    when 'pg'
      res[0]['count']
    when 'sqlite3'
      res[0][0]
    end
  end
end
