require_relative 'questions_database'
require_relative 'question'
require_relative 'reply'
require_relative 'question_like'

class User
  attr_accessor :id, :fname, :lname

  def initialize(options = {})
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

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(id)
  end

  def average_karma
    average_karma = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        CAST(COUNT(question_likes.id) AS FLOAT) / COUNT(DISTINCT(questions.id)) ave
      FROM
        questions
      LEFT OUTER JOIN
        question_likes ON question_likes.question_id = questions.id
      WHERE
        questions.user_id = ?
    SQL

    average_karma[0]['ave']
  end

  def save
    if id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
        INSERT INTO
          users (fname, lname)
        VALUES
          (?, ?)
      SQL

      self.id = QuestionsDatabase.instance.last_insert_row_id
    else
      options = {id: id, fname: fname, lname: lname}
      QuestionsDatabase.instance.execute(<<-SQL, options)
        UPDATE
          users
        SET
          fname = :fname, lname = :lname
        WHERE
          id = :id
      SQL
    end
  end
end
