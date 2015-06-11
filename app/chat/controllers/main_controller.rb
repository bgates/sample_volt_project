module Chat
  class MainController < Volt::ModelController
    model :store
    def index
      # Add code for when the index view is loaded
    end

    private

    # the main template contains a #template binding that shows another
    # template.  This is the path to that template.  It may change based
    # on the params._controller and params._action values.
    def main_path
      "#{params._component || 'main'}/
       #{params._controller || 'main'}/
       #{params._action || 'index'}"
    end

    def other_users
      _users.select{|user| user._id != Volt.current_user._id }
    end

    def select_conversation(user)
      params._user_id = user._id
      unread_notifications_from(user).then do |results|
        results.each do |notification|
          _notifications.delete(notification)
        end
      end 
      clear_message
    end

    def unread_notifications_from(user)
      _notifications.find({ sender_id: user._id, 
                            receiver_id: Volt.current_user._id })
    end
    
    def unseen_messages_from?(user)
      unread_notifications_from(user).count > 0 && 
      params._user_id != user._id
    end

    def current_conversation
      _messages.find({ "$or" => [{ sender_id: Volt.current_user._id, 
                                   receiver_id: params._user_id }, 
                                 { sender_id: params._user_id, 
                                   receiver_id: Volt.current_user._id }] })
    end

    def send_message
      unless page._new_message.strip.empty?
        from_and_to = { sender_id: Volt.current_user._id, 
                        receiver_id: params._user_id }
        _messages << from_and_to.merge(text: page._new_message) 
                        
        _notifications << from_and_to
        clear_message
      end
    end

    def clear_message
      page._new_message = ''
    end
  end
end