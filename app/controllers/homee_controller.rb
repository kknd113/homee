class HomeeController < ApplicationController
  
  def index
  end
  
  def webhook
    result = params['hub.verify_token'] == 'verifyme' ? params['hub.challenge'] : 'verification failed'
    
    render plain: result
  end
end
