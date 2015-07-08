require_relative 'questions_database'
require_relative 'user'
require_relative 'model'

class QuestionLike < Model
  attr_accessor :id, :user_id, :question_id

  def initialize(options = {})
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def self.likers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, q_id: question_id)
      SELECT
        users.*
      FROM
        question_likes
      JOIN
        users ON question_likes.user_id = users.id
      WHERE
        question_likes.id = :q_id
    SQL

    users.map { |user| User.new(user) }
  end

  def self.num_likes_for_question_id(question_id)
    num_likes = QuestionsDatabase.instance.execute(<<-SQL, q_id: question_id)
      SELECT
        COUNT(question_likes.id) AS num_likes
      FROM
        question_likes
      WHERE
        question_likes.id = :q_id
      GROUP BY
        question_likes.question_id
    SQL

    num_likes[0]['num_likes']
  end

  def self.liked_questions_for_user_id(user_id)
    liked_questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_likes
      JOIN
        questions ON question_likes.question_id = questions.id
      WHERE
        question_likes.user_id = ?
    SQL

    liked_questions.map { |question| Question.new(question) }
  end

  def self.most_liked_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        question_likes
      JOIN
        questions ON question_likes.question_id = questions.id
      GROUP BY
        question_likes.question_id
      ORDER BY
        COUNT(question_likes.id) DESC
      LIMIT
        ?
    SQL

    questions.map { |question| Question.new(question) }
  end
end
