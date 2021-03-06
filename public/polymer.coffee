template = document.querySelector('#template')
socket = io.connect document.location.origin,
  reconnectionDelay: 200
  reconnectionDelayMax: 1000

avatars = ['tabby', 'bengal', 'persian', 'mainecoon', 'ragdoll', 'sphynx', 'siamese', 'korat', 'japanesebobtail', 'abyssinian', 'scottishfold']
colors = ['navy', 'slate', 'olive', 'moss', 'chocolate', 'buttercup', 'maroon', 'cerise', 'plum', 'orchid']

avatar = (Math.random() * avatars.length) >>> 0
color  = (Math.random() * colors.length) >>> 0

template.avatar = "images/avatars/#{avatars[avatar]}.jpg"
template.color  = colors[color]
template.status = 'connected'
template.messages = []
template.users = []
template.userName = prompt('Enter your username')

sendMessage = (msg)->
  socket.emit 'chat:msg',
    message: msg
    nick: template.userName
    avatar: avatar
    color: color

parseMessage = (msg)->
  msg.timestamp = new Date(msg.timestamp).toISOString();
  msg.avatar = "images/avatars/#{avatars[msg.avatar]}.jpg" if Number.isInteger msg.avatar
  msg.color = colors[msg.color] if msg.color?
  msg

showMessage = (msg)->
  msg = parseMessage msg
  template.messages.push msg
  template.async ()->
    chatDiv = document.querySelector('.chat-list');
    chatDiv.scrollTop = chatDiv.scrollHeight;

template.sendMyMessage = (msg) ->
  sendMessage(msg)

template.checkKey = (e) ->
  $input = $(e.target)
  if e.which == 13
    if socket.socket.connected == false
      alert 'Please wait while we reconnect'
    else if $input.val().trim() != ''
      sendMessage $input.val()
      $input.val ''
  e.preventDefault()

socket.on 'disconnect', ->
  template.status = 'disconnected'

socket.on 'reconnect', ->
  template.status = 'connected'

socket.on 'connect', ->
  template.status = 'connected'
  socket.emit 'chat:demand'
  socket.emit 'presence:demand'

socket.on 'chat:msg', (msg)->
  showMessage msg

socket.on 'chat:log', (log)->
  log.map showMessage

socket.on 'presence:list', (list)->
  template.users = list
