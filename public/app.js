var socket = io.connect(document.location.origin,{
  reconnectionDelay: 200,
  reconnectionDelayMax: 1000
});
var userName = prompt("Enter your username");

$(function(){
  // Compile template function
  var template = $('#template-message').text();
  Mustache.parse(template);
  // Attach event handler
  $('#message-input').keydown(function(e){
    var $input = $(this);
    if(e.which == 13){
      if(socket.socket.connected===false){
        alert('Please wait while we reconnect');
        return;
      }
      if($input.val().trim() !== ""){
        socket.emit('chat:msg', {message: $input.val(), classes:"", nick: userName});
        $input.val("");
      }
      e.preventDefault();
    }
  }).focus();

  // Handle a chat message
  socket.on('chat:msg', function(data){
    var timestamp = new Date(data.timestamp).toISOString();
    var templateData = {
      classes: data.classes,
      message: data.message,
      nick: data.nick,
      timestamp: timestamp
    };
    var html = Mustache.render(template, templateData);
    $el = $(html);
    $('.channel-log tbody').append($el);
    $('.channel-log').animate({
      scrollTop: $('.channel-log')[0].scrollHeight
    });
    $el.find('.date').timeago();
  });

  socket.on('connect', function(){
    socket.emit('chat:demand');
  });
  socket.on('reconnect', function(){
    $('#message-input').removeClass('disconnected').attr('placeholder', "Message");
  });
  socket.on('disconnect', function(){
    $('#message-input').addClass('disconnected').attr('placeholder', "Disconnected");
  });
});