require 'sqlite3'
require 'bloc_record/schema'

module Persistence
  def self.included(base)
    base.extend(ClassMethods)
  end

  def save
    self.save! rescue false
  end

  def save!
    unless self.id
      self.id = self.class.create(BlocRecord::Utility.instance_variables_to_hash(self)).id
      BlocRecord::Utility.reload_obj(self)
      return true
    end

    fields = self.class.attributes.map { |col| "#{col}=#{BlocRecord::Utility.sql_strings(self.instance_variable_get("@#{col}"))}" }.join(",")

    self.class.connection.execute <<-SQL
      UPDATE #{self.class.table}
      SET #{fields}
      WHERE id = #{self.id};
    SQL

    true
  end

  def update_attribute(attribute, value)
    self.class.update(self.id, { attribute => value })
  end

  def update_attributes(updates)
    self.class.update(self.id, updates)
  end

  module ClassMethods
    def create(attrs)
      attrs = BlocRecord::Utility.convert_keys(attrs)
      attrs.delete 'id'
      vals = attributes.map { |key| BlocRecord::Utility.sql_strings(attrs[key]) }

      connection.execute <<-SQL
        INSERT INTO #{table} (#{attributes.join ','})
        VALUES (#{vals.join ','});
      SQL

      data = Hash[attributes.zip attrs.values]
      data['id'] = connection.execute('SELECT last_insert_rowid();')[0][0]
      new(data)
    end

    def update(ids, updates)
      case updates
      when Hash
        build_updates_array(updates)

        if ids.class == Fixnum
          where_clause = "WHERE id = #{ids};"
        elsif ids.class == Array
          where_clause = ids.empty? ? ";" : "WHERE id IN (#{ids.join(",")});"
        else
          where_clause = ";"
        end

        connection.execute <<-SQL
          UPDATE #{table}
          SET #{updates_array * ","} #{where_clause}
        SQL
      when Array
        raise "size of 'ids' must match size of 'updates' when 'updates' is of class Array." if ids.size != updates.size

        updates.each do |update, index|
          updates_array = build_updates_array(update)

          connection.execute <<-SQL
            UPDATE #{table}
            SET #{updates_array * ","} WHERE id = #{ids[index]};
          SQL
        end
      end

      true
    end

    def update_all(updates)
      update(nil, updates)
    end
  end

  private

  def build_updates_array(hash)
    hash = BlocRecord::Utility.convert_keys(hash)
    hash.delete "id"
    hash_array = hash.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}" }
  end

  def method_missing(method_id, *args)
    method_name = method_id.to_s
    if method_name.index('update_') == 0
      attribute = method_name.slice(7..-1)
      value = args[1] ? nil : args[0]

      unless value
        raise "Unexpected number of arguments for #{method_id}. Expected 1, got #{args.size}."
      end

      self.update_attribute(attribute, value)
    else
      super
    end
  end
end
