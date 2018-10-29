require 'sqlite3'
require 'active_support/inflector'

module Associations
  def has_many(association)
    define_method(association) do
      rows = self.class.query <<-SQL
        SELECT * FROM #{association.to_s.singularize}
        WHERE #{self.class.table}_id = #{id}
      SQL

      class_name = association.to_s.classify.constantize
      collection = BlocRecord::Collection.new

      rows.each do |row|
        if BlocRecord.platform == "pg"
          row['id'] = row['id'].to_i if row['id']
          row = row.values
        end
        collection << class_name.new(Hash[class_name.columns.zip(row)])
      end

      collection
    end
  end

  def belongs_to(association)
    define_method(association) do
      association_name = association.to_s
      row = self.class.query <<-SQL
        SELECT * FROM #{association_name}
        WHERE id = #{self.send(association_name + "_id")}
      SQL

      class_name = association_name.classify.constantize

      if row
        if BlocRecord.platform == "pg"
          row = row[0]
          row['id'] = row['id'].to_i if row['id']
        end

        data = Hash[class_name.columns.zip(row)]
        class_name.new(data)
      end
    end
  end

  def has_one
    define_method(association) do
      association_name = association.to_s
      row = self.class.query <<-SQL
        SELECT * FROM #{association_name}
        WHERE #{self.class.table}_id = #{id}
      SQL

      class_name = association_name.classify.constantize

      if row
        if BlocRecord.platform == "pg"
          row = row[0]
          row['id'] = row['id'].to_i if row['id']
        end

        data = Hash[class_name.columns.zip(row)]
        class_name.new(data)
      end
    end
  end
end
