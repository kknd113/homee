class Conversation < ActiveRecord::Base
  belongs_to :user
  
  def update_conversation(message)
    self.update! text: "#{self.text}\n#{message}"
  end
  
  def mark_archived
    self.archived = true
  end
end
