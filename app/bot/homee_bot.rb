include Facebook::Messenger
ROOM_TYPES = %w(living bed office)
BUDGET_TYPES = %w(0 500 1000 3000 5000)
SHIPPING_TYPES = %w(0-1 1-2 3-4 more)
STYLE_TYPES = %w(modern traditional industrial ecelectic contemporary)

Bot.on :message do |message|
  answer = message.text
  recipient = message.sender
  @user = User.find_or_create_by(fb_id: recipient['id'])
  initiate_conversation(recipient)
end

def initiate_conversation(recipient)
  @conversation = @user.conversations.create
  message = "Hey! Welcome! :)\n I am going to ask you some questions to match you with the best designer for your project!"
  Bot.deliver(recipient: recipient, message:{text: message})
  @conversation.update_conversation(message)
  ask_room_type_question(recipient)
end

def ask_room_type_question(recipient)
  deliver_questions(recipient: recipient, question: 'So, what room can we help you with?', choices: ROOM_TYPES)
  Bot.on :message do |message|
    if ROOM_TYPES.include? message.text
      @conversation.update_conversation(message.text)
      @user.update! room_type: message.text
      puts 'expected answer save to users table'
      ask_budget_type_question(recipient)
    else
      deliver_warning(recipient)
      ask_room_type_question(recipient)
    end
  end
end

def ask_budget_type_question(recipient)
  deliver_questions(recipient: recipient, question: "Sweet :) \n what is your budget or price range?", choices: BUDGET_TYPES)
  Bot.on :message do |message|
    if BUDGET_TYPES.include? message.text
      @conversation.update_conversation(message.text)
      @user.update! budget: message.text
      ask_shipping_type_question(recipient)
    else
      deliver_warning(recipient)
      ask_budget_type_question(recipient)
    end
  end
end

def ask_shipping_type_question(recipient)
  deliver_questions(recipient: recipient, question: 'Ok, when do you need your furniture by?', choices: SHIPPING_TYPES)
  Bot.on :message do |message|
    if SHIPPING_TYPES.include? message.text
      @conversation.update_conversation(message.text)
      @user.update! shipping_type: message.text
      ask_style_type_question(recipient)
    else
      deliver_warning(recipient)
      ask_shipping_type_question(recipient)
    end
  end
end

def ask_style_type_question(recipient)
  deliver_questions(recipient: recipient, question: 'Got it! How would you best describe your style preference?', choices: STYLE_TYPES)
  Bot.on :message do |message|
    if STYLE_TYPES.include? message.text
      @conversation.update_conversation(message.text)
      @user.update! style_type: message.text
      ask_image_question(recipient)
    else
      deliver_warning(recipient)
      ask_style_type_question(recipient)
    end
  end
end

def ask_image_question(recipient)
  Bot.deliver(recipient: recipient, message: { text: 'Can you send us some pictures of your space?' })
  Bot.on :message do |message|
    if message.image_attachment.present? 
      @conversation.update_conversation(message.text)
      @user.update! picture_url: message.text
      ask_misc_question(recipient)
    else
      deliver_warning(recipient)
      ask_image_question(recipient)
    end
  end
end

def ask_misc_question(recipient)
  Bot.deliver(recipient: recipient, message: { text: 'Any special request or additional information?' })
  Bot.on :message do |message|
    @conversation.update_conversation(message.text)
    @user.update! special_request: message.text
  end_conversation(recipient)
  end
end

def end_conversation(recipient)
  @conversation.mark_archived
  message = "Thanks for your time! Bye :)\n If you want to restart conversation type 'restart'"
  Bot.deliver(
    recipient: recipient,
    message: {
      text: message
    }
  )
  
  Bot.on :message do |message|
    if message.text == 'restart'
      initiate_conversation(message.sender)
    else
      end_conversation(message.sender)
    end
  end
end

def deliver_questions(recipient: nil, question: 'default question', choices: [])
  @conversation.update_conversation(question)
  Bot.deliver(
    recipient: recipient,
    message: {
      text: question + "\n\n" + "Please pick from:\n" + choices.to_s
    }
  )
end

def deliver_warning(recipient)
  Bot.deliver(
    recipient: recipient,
    message: {
      text: "I am still a little dumb :/ \n Although case-insensitive, I'm looking for exact match with the choices"
    }
  )
end


module Facebook
  module Messenger
    module Incoming
      class Message
                
        def image_attachment
          attachments = @payload['message']['attachments']
          if attachments.present? && attachments.first['type'] == 'image'
            attachments.first['payload']['url']
          else 
            nil
          end
        end
      end
    end
  end
end
