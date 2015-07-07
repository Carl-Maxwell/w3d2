require 'active_support/inflector'

class Model
  def values_symbols
    instance_variables.map { |e| e = e[1..-1].to_sym }
  end

  def save
    options = {}

    values_symbols.each do |ivar|
      options[ivar] = ivar.to_proc.call(self)
    end

    if id.nil?
      options.delete(:id) # otherwise we get 'bind error'
      columns = values_symbols.join(", ")
      values = values_symbols.map {|e| ":" + e.to_s }.join(", ")

      QuestionsDatabase.instance.execute(<<-SQL, options)
        INSERT INTO
          #{self.class.to_s.pluralize}
          (#{columns})
        VALUES
          (#{values})
      SQL

      self.id = QuestionsDatabase.instance.last_insert_row_id
    else
      setting = values_symbols.map { |e| e.to_s + " = :" + e.to_s }.join(",\n")

      QuestionsDatabase.instance.execute(<<-SQL, options)
        UPDATE
          #{self.class.to_s.pluralize}
        SET
          #{setting}
        WHERE
          id = :id
      SQL
    end
  end
end
