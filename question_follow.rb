require_relative 'questions_database'
require_relative 'user'
require_relative 'question'
require_relative 'model'

class QuestionFollow < Model
  attr_accessor :id, :user_id, :question_id

  def initialize(options = {})
    @id = options['id']
    @user_id, @question_id = options['user_id'], options['question_id']
  end

  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, q_id: question_id)
      SELECT
        users.*
      FROM
        users
      JOIN
        question_follows ON users.id = question_follows.user_id
      WHERE
        question_follows.question_id = :q_id
    SQL

    followers.map { |user| User.new(user) }
  end

  def self.followed_questions_for_user_id(user_id)
    followed_questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_follows ON questions.id = question_follows.question_id
      WHERE
        questions.author_id = ?
    SQL

    followed_questions.map { |question| Question.new(question) }
  end

  def self.most_followed_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_follows ON questions.id = question_follows.question_id
      GROUP BY
        questions.id
      ORDER BY
        count(question_follows.user_id) DESC
      LIMIT
        ?
    SQL

    questions.map { |question| Question.new(question) }
  end
end
