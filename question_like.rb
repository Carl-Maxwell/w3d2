require_relative 'questions_database'

class QuestionLike
  attr_accessor :id, :user_id, :question_id

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def self.find_by_id(id)
    question_like_id = QuestionsDatabase.instance.execute(<<-SQL, id: id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = :id
    SQL

    QuestionLike.new(question_like_id.first)
  end
end
