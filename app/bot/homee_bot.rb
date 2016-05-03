include Facebook::Messenger

Bot.on :message do |message|
  puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!NEW MESSAGE!!!!!!!!!!!!!!!!!!!!!!'
  puts message.id      # => 'mid.1457764197618:41d102a3e1ae206a38'
  puts message.sender  # => { 'id' => '1008372609250235' }
  puts message.seq     # => 73
  puts message.text    # => 'Hello, bot!'
  
  deliver_questions(recipient: message.sender, question: 'what room maeng', choices: ['livingroom, myroom, whateve'])
end

Bot.on :postback do |postback|
  postback.sender    # => { 'id' => '1008372609250235' }
  postback.recipient # => { 'id' => '2015573629214912' }
  postback.sent_at   # => 2016-04-22 21:30:36 +0200
  postback.payload   # => 'EXTERMINATE'

  if postback.payload == 'EXTERMINATE'
    puts "Human #{postback.recipient} marked for extermination"
  end
end

def deliver_questions(recipient: nil, question: 'default question', choices: [])
  Bot.deliver(
    recipient: recipient,
    message: {
    attachment: {
      type: 'template',
      payload: {
        template_type: 'button',
        text: question,
        buttons: choices.map { |choice|  {type: 'postback', title: choice, payload: choice } }
        }
      }
    }
  )
end
