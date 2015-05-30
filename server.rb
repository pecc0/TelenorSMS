require 'webrick'
require 'webrick/https'
require './lib/telenorsms'

cert_name = [
  %w[CN localhost],
]

server = WEBrick::HTTPServer.new(:Port => 8000,
                                 :SSLEnable => false,
                                 :SSLCertName => cert_name)

trap 'INT' do server.shutdown end

server.mount_proc '/sendsms' do |req, res|
  #res.body = req.query
  
  recipients = eval(File.open('recipients') {|f| f.read })
  
  if req.query.has_key?("username") && req.query.has_key?("password") && 
      req.query.has_key?("recipient") && req.query.has_key?("message") then
    recipient = req.query["recipient"];
    if recipients.has_key?(recipient) then
      recipient = recipients[recipient]
    end
    
    sms_sender = TelenorSMS.new req.query["username"], req.query["password"]
    sms_sender.send req.query["message"], recipient
  else
    res.content_type="html"

    selectOptions = recipients.keys.inject("") do |html,key|
      html + "<option value=" + key + ">"
    end
    res.body = '''
<html>
<body>
<form action="/sendsms" method="post">
Telenor number:<br>
<input type="text" name="username">
<br>
Telenor password:<br>
<input type="password" name="password">
<br>
Recipient:<br>
<input list="recipients" name="recipient">
<datalist id="recipients">
''' + selectOptions +
'''
</datalist>
<br>
Message:<br>
<textarea name="message"></textarea>

<input type="submit">

</form>
</body>
</html>
'''
  end
  
end

server.start