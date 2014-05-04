class NotificationMessage < ActiveRecord::Base

  TypeAt = 1
  TypeVote = 2
  TypePraisePost = 3
  TypePraiseComment = 4
  
  def self.notify(user, initiator, target, type)
    return nil if user.id == initiator.id
    attributes = {
      :user_id => user.id,
      :initiator_id => initiator.id,
      :target_id => target.id,
      :notify_type => type
    }
    notify = self.where(attributes).first || self.new(attributes)
    notify.create_at = Time.now
    notify.save!
  end
  
  def self.count(user)
    self.where(:user_id => user.id).count
  end
  
end
