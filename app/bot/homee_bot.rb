include Facebook::Messenger
ROOM_TYPES = %w(living bed office)
BUDGET_TYPES = %w(0 500 1000 3000 5000)
SHIPPING_TYPES = %w(0-1 1-2 3-4 more)
STYLE_TYPES = %w(modern traditional industrial ecelectic contemporary)

Bot.on :message do |message|
  answer = message.text
  recipient = message.sender
  
  initiate_conversation(recipient)
end

def initiate_conversation(recipient)
  Bot.deliver(recipient: recipient, message:{text: 'Hey! Welcome! :)'})
  Bot.deliver(recipient: recipient, message:{text: 'I am going to ask you some questions to match you with the best designer for your project!'})
  ask_room_type_question(recipient)
end

def ask_room_type_question(recipient)
  deliver_questions(recipient: recipient, question: 'So, what room can we help you with?', choices: ROOM_TYPES)
  Bot.on :message do |message|
    if ROOM_TYPES.include? message.text
      puts 'expected answer save to users table'
      ask_budget_type_question(recipient)
    else
      ask_room_type_question(recipient)
    end
  end
end

def ask_budget_type_question(recipient)
  deliver_questions(recipient: recipient, question: 'Sweet :) \n what is your budget or price range?', choices: BUDGET_TYPES)
  Bot.on :message do |message|
    if BUDGET_TYPES.include? message.text
      puts 'expected answer save to users table'
      ask_shipping_type_question(recipient)
    else
      ask_budget_type_question(recipient)
    end
  end
end

def ask_shipping_type_question(recipient)
  deliver_questions(recipient: recipient, question: 'Ok, when do you need your furniture by?', choices: SHIPPING_TYPES)
  Bot.on :message do |message|
    if SHIPPING_TYPES.include? message.text
      puts 'expected answer save to users table'
      ask_style_type_question(recipient)
    else
      ask_shipping_type_question(recipient)
    end
  end
end

def ask_style_type_question(recipient)
  deliver_questions(recipient: recipient, question: 'Got it! How would you best describe your style preference?', choices: STYLE_TYPES)
  Bot.on :message do |message|
    if STYLE_TYPES.include? message.text
      puts 'expected answer save to users table'
      ask_image_question(recipient)
    else
      ask_style_type_question(recipient)
    end
  end
end

def ask_image_question(recipient)
  Bot.deliver(recipient: recipient, message: { text: 'Can you send us some pictures of your space?' })
  Bot.on :message do |message|
    if message.image_attachment.present? 
      puts 'expected answer save to users table'
      ask_misc_question(recipient)
    else
      ask_image_question(recipient)
    end
  end
end

def ask_misc_question(recipient)
  Bot.deliver(recipient: recipient, message: { text: 'Any special request or additional information?' })
  Bot.on :message do |message|
    puts 'save misc here'
  end_conversation(recipient)
  end
end

def end_conversation(recipient)
  Bot.deliver(
    recipient: recipient,
    message: {
      text: 'baiiiiii'
    }
  )
end

def deliver_questions(recipient: nil, question: 'default question', choices: [])
  Bot.deliver(
    recipient: recipient,
    message: {
      text: question + "\n\n" + choices.to_s
    }
  )
end


module Facebook
  module Messenger
    module Incoming
      class Message
                
        def image_attachment
          attachments = @payload['message']['attachments']
          if attachments.any? && attachments.first['type'] == 'image'
            attachments.first['payload']['url']
          else 
            nil
          end
        end
      end
    end
  end
end
