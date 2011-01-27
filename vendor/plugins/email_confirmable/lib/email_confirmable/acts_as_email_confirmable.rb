# Requires a field email, confirm_id and confirmed on model
module EmailConfirmable
  mattr_accessor :from

  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods
    def acts_as_email_confirmable
      send :include, InstanceMethods
      
      validates_presence_of :email
      validates_email_format_of :email, :on => :create
      before_create :set_confirm_info
      after_create :send_confirmation_email

      named_scope :confirmed, :conditions => {:confirmed => true}
    end
  end
  
  module InstanceMethods
    def confirm!
      self.confirmed = true
      save!
      after_confirm if self.respond_to?(:after_confirm)
    end
  
    def send_confirmation_email
      Notifier.deliver_confirm(self)
    end
  
    protected
    
    def set_confirm_info
      # TODO: Should check that this is unique across all objects and if not try again
      self.confirm_id = Digest::MD5.hexdigest(rand.to_s + Time.now.to_s)[0...20]
    end
  end
end

ActiveRecord::Base.send :include, EmailConfirmable
