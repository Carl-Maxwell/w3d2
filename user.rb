require_relative 'questions_database'
require_relative 'question'
require_relative 'reply'

class User
  attr_accessor :id, :fname, :lname

  def initialize(options)
    @id, @fname, @lname = options['id'], options['fname'], options['lname']
  end

  def self.find_by_id(id)
    user_id = QuestionsDatabase.instance.execute(<<-SQL, id: id)
      SELECT
        *
      FROM
        users
      WHERE
        id = :id
    SQL

    User.new(user_id.first)
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL

    User.new(user.first)
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end
end
