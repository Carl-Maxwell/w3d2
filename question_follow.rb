require_relative 'questions_database'

class QuestionFollow
  attr_accessor :id, :user_id, :question_id

  def initialize(options)
    @id = options['id']
    @user_id, @question_id = options['user_id'], options['question_id']
  end

  def self.find_by_id(id)
    question_follow_id = QuestionsDatabase.instance.execute(<<-SQL, id: id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = :id
    SQL

    QuestionFollow.new(question_follow_id.first)
  end
end
