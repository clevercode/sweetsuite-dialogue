Dialogue
========

## The Larynx Api
The Larynx API is the way that SweetSuite apps talk back to clients. An app can
load messages onto its queue, then they are broadcasted to listening clients.

## Dialogue

Dialogue boils down to 3 things: users, channels, and messages.



### Client Process Flow

#### JS API

Client establishes connection to Larynx via a Dialogue::Channel

    channel = new Dialogue.Channel({user_id:1, id:1});

The catch the `message` event to handle them

    channel.bind('message', function (msg) {
      //  is an instance of Dialogue.Message
      // build a view & append to document      
    });

Client decides to create message.

    message = new Dialogue.Message({text:'Here is your sign'})

And send it to the channel.

    channel.send(message)

So the public API is 

Dialogue.Channel
  - new(params)
  - join()
  - leave()
  - send()

Dialogue.Message
  - new(params) 
  - asJson
  - ... 

### JS Internal Workings

Something to do with Larynx, a wrapper around WebSocket

    Larynx.connect(USER_API_KEY)
    Larynx.webSocket => the plain WebSocket Object

    Events:
      connect
      message - object
      disconnect - null or 'Connection lost'

Dialogue.Channel#send doesn't send through WebSocket, it POSTs to the REST
API, which pushes a message onto the queue

Options:

1. When the queue gets the message it firsts pushes out the raw message to the
   user then places the message into a second queue for processing entities,
   dynamic content. When that's finished push the extra information to the
   client

   Pros: Quicker push to clients
   Cons: Doubled bandwidth & client flicker ( flashing ugly and then
   specialized ) 

2. When the queue gets the message it processes then pushes to the client.

   Pros: 1 push to client, 1 view render.
   Cons: Not as real time.
  
   I could optimize the processing so that it returns immediately if the
   message matches a regex that says that it doesn't need to be processed.



#### Dialogue REST API

Information about the channel

    GET /channels/1

    - title
    - topic 
    - participants - Array of users in the channel and their information
    - recent messages

Join a channel

    POST /channels/1/join

    200 OK

Leave a channel

    POST /channels/1/leave

    200 OK

Page through a channel's messages

    GET /channels/1/messages

    Params: { since: time } OR { after_id: 11, before_id: 112 }

Post a message

    POST /channels/1/messages

    Params: {raw_content: 'This is the message', annotations: {from: 'Dialogue'}}

#### Taking Asynchronous-ness  into consideration

One goal is to only need to maintain a single WebSocket connection to Larynx.

I think that one simple solution, would to guarantee that the connection was
open during bootstrap
Larynx.connection(function(){
  Larynx.send({apple:'b'})
})
