require 'active_support/inflector'

class Model
  def self.grab_all
    rows = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table}
    SQL

    rows.map { |row| self.new(row) }
  end

  def self.table
    self.to_s.tableize
  end

  def self.where(options)
    if options.include?(:or)
      operator = "OR"
      options.delete(:or)
    else
      operator = "AND"
    end

    options_arr = options.to_a

    p conditions = options_arr.map { |(key, _)| "#{key} = :#{key}" }.join(" #{operator} ")
    rows = QuestionsDatabase.instance.execute(<<-SQL, options)
      SELECT
        *
      FROM
        #{self.table}
      WHERE
        #{conditions}
    SQL

    rows.map { |row| self.new(row) }
  end

  def self.method_missing(method_sym, *arguments, &block)
    method_name = method_sym.to_s.split("_")

    if method_name.take(2) == ["find", "by"]
      options = {}

      is_or = method_name.drop(2).include?("or")
      conditions = method_name.drop(2).join("_").split(/_and_|_or_/)

      conditions.each.with_index do |condition, i|
        options[condition.to_sym] = arguments[i]
      end

      if is_or
        options[:or] = true
      end

      self.where(options)
    else
      super
    end
  end

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
          #{self.class.table}
          (#{columns})
        VALUES
          (#{values})
      SQL

      self.id = QuestionsDatabase.instance.last_insert_row_id
    else
      setting = values_symbols.map { |e| e.to_s + " = :" + e.to_s }.join(",\n")

      QuestionsDatabase.instance.execute(<<-SQL, options)
        UPDATE
          #{self.class.table}
        SET
          #{setting}
        WHERE
          id = :id
      SQL
    end
  end
end
