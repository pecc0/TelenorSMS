require 'lib/telenorsms'

username = ARGV[0]
password = ARGV[1]
message = ARGV[2]
recipients = ARGV[3]

Guard::require username != nil, "Username must be specified (first arg)"
Guard::require password != nil, "Password must be specified (second arg)"
Guard::require message != nil, "Message must be specified (third arg)"
Guard::require recipients != nil, "Recipients must be specified (forth arg)"

sms_sender = TelenorSMS.new username, password
sms_sender.send message, recipients