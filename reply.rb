require_relative 'questions_database'
require_relative 'model'

class Reply < Model
  attr_accessor :id, :question_id, :parent_reply_id, :body, :author_id

  def initialize(options = {})
    @id = options['id']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
    @author_id = options['author_id']
    @body = options['body']
  end

  def author
    User.find_by_id(author_id)
  end

  def question
    Question.find_by_id(question_id)
  end

  def parent_reply
    Reply.find_by_id(parent_reply_id) unless parent_reply_id.nil?
  end

  def child_replies
    child_replies = QuestionsDatabase.instance.execute(<<-SQL, id: id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply_id = :id
    SQL

    child_replies.map { |child| Reply.new(child) }
  end
end
