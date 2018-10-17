module BlocRecord
  class Collection < Array
    def update_all(updates)
      ids = map(&:id)
      any? ? first.class.update(ids, updates) : false
    end

    def take(limit = 1)
      slice(0, limit)
    end

    def where(*args)
      return self unless any?

      ids = map(&:id)

      if args.count > 1
        expression = args.shift
        params = args
      elsif args.count == 0
        return self
      else
        case args.first
        when String
          expression = args.first
        when Hash
          expression_hash = BlocRecord::Utility.convert_keys(args.first)
          expression = expression_hash.map { |key, _value| "#{key} = ?" }.join(' and ')
          params = args.first.values
        end
      end

      expression = "id IN (#{ids.join(',')}) AND #{expression}"

      if params
        first.class.where(expression, *params)
      else
        first.class.where(expression)
      end
    end

    def not(*args)
      return nil unless any?

      ids = map(&:id)

      if args.count > 1
        expression = "NOT (#{args.shift})"
        params = args
      elsif args.count == 0
        return nil
      else
        case args.first
        when String
          expression = "NOT (#{args.first})"
        when Hash
          expression_hash = BlocRecord::Utility.convert_keys(args.first)
          expression = expression_hash.map { |key, _value| "#{key} != ?" }.join(' and ')
          params = args.first.values
        end
      end

      if params
        first.class.where(expression, *params)
      else
        first.class.where(expression)
      end
    end
  end
end
