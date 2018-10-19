module BlocRecord
  class Collection < Array
    def update_all(updates)
      ids = map(&:id)
      any? ? first.class.update(ids, updates) : false
    end

    def destroy_all
      ids = map(&:id)
      if any?
        ids_list = ids.join(',')
        expression = "id IN (#{ids_list})"

        first.class.destroy_all(expression)
      end
    end
  end
end
