function connect() {

  var socket = new WebSocket('ws://localhost:3000/talk')
  socket.onopen = function() { console.log('opened!') }
  socket.onclose = function() { console.log('closed!') }
  socket.onmessage = function(msg) { console.log(msg) }
  socket.onerror = function(err) { console.log('Error:' + err) }

  return(socket)
}
