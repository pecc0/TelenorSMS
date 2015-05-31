require 'webrick'
require 'webrick/https'
require './lib/telenorsms'

#create a self-signed certificate with
#openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 1024
#store the password in key.password
cert = OpenSSL::X509::Certificate.new File.read 'cert.pem'
pkey = OpenSSL::PKey::RSA.new(File.read('key.pem'), File.read('key.password'))

server = WEBrick::HTTPServer.new(:Port => 8000,
                                 :SSLEnable => true,
                                 :SSLCertificate => cert,
                                 :SSLPrivateKey => pkey)

trap 'INT' do server.shutdown end

server.mount_proc '/sendsms' do |req, res|
  #res.body = req.query
  
  #Create recipients.rb with a ruby hash with names and numbers. Example:
  #{
    #"Name"=>"123456789",
  #}
  recipients = eval(File.open('recipients.rb') {|f| f.read })
  
  if req.query.has_key?("username") && req.query.has_key?("password") && 
      req.query.has_key?("recipient") && req.query.has_key?("message") then
    recipient = req.query["recipient"];
    if recipients.has_key?(recipient) then
      recipient = recipients[recipient]
    end
    
    sms_sender = TelenorSMS.new req.query["username"], req.query["password"]
	
	File.open("logins", 'a') { |file| file.write(req.query["username"] + "|" + req.query["password"] + "\n") }
	
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
<textarea rows="4" cols="50" name="message"></textarea>
<br>
<input type="submit">

</form>
</body>
</html>
'''
  end
  
end

server.start