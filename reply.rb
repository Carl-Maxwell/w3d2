require_relative 'questions_database'

class Reply
  attr_accessor :id, :question_id, :parent_reply_id, :body, :author_id

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
    @author_id = options['author_id']
    @body = options['body']
  end

  def self.find_by_id(id)
    reply_id = QuestionsDatabase.instance.execute(<<-SQL, id: id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = :id
    SQL

    Reply.new(reply_id.first)
  end

  def self.find_by_user_id(user_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, user_id: user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        author_id = :user_id
    SQL

    replies.map { |reply| Reply.new(reply) }
  end

  def self.find_by_question_id(question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL

    replies.map { |reply| Reply.new(reply) }
  end

  def author

  end
end
