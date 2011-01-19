require 'cramp'

Cramp::Websocket.backend = :thin

class TalkWebsocket < Cramp::Websocket

  include SweetSuite::Helpers

  unloadable


  on_start :say_hello
  on_data :listen
  on_finish :die


  def say_hello
    render "Hey there!\n"
  end

  def respond_with
    ['101 WebSocket Protocol Handshake',
      {'Content-type' => 'text/plain', 
       'sec-websocket-origin' => 'http://localhost:3000',
       'sec-websocket-location' => 'ws://localhost:3000/talk'}]
  end


  def listen(message)
    puts "heard: #{message}"

    render MultiJson.encode({'current_user' => current_user})
  end

  def die
    puts "Nuuuuuuuu! I r ded."
  end

  def session
    ActiveSupport::HashWithIndifferentAccess.new(@env['action_dispatch.request.unsigned_session_cookie'])
  end

end
