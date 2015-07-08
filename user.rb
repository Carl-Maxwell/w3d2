require_relative 'questions_database'
require_relative 'question'
require_relative 'reply'
require_relative 'question_like'
require_relative 'model'

class User < Model
  attr_accessor :id, :fname, :lname

  def initialize(options = {})
    @id, @fname, @lname = options['id'], options['fname'], options['lname']
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_author_id(@id)
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
end
