module BlocRecord
  class Collection < Array
    def update_all(updates)
      ids = map(&:id)
      any? ? first.class.update(ids, updates) : false
    end

    def take(limit = 1)
      slice(0, limit)
    end

    def where(arg)
      collection = BlocRecord::Collection.new

      expression_hash = BlocRecord::Utility.convert_keys(arg)
      keys = expression_hash.keys
      values = expression_hash.values

      if any?
        each do |record|
          if record
        end
      else
        false
      end
    end

    def not(*args); end
  end
end
