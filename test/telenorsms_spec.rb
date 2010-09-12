require 'rubygems'
require 'spec'
require '../lib/telenorsms'

describe TelenorSMS, "when creating object" do
  it "should validate username argument" do
    lambda { TelenorSMS.new nil, "a password" }.should raise_exception
    lambda { TelenorSMS.new "", "a password" }.should raise_exception
  end

  it "should validate password argument" do
    lambda { TelenorSMS.new "username", nil }.should raise_exception
    lambda { TelenorSMS.new "username", "" }.should raise_exception
  end
end

describe TelenorSMS, "when providing wrong credentials" do
  it "should raise exception" do
    lambda { TelenorSMS.new "99999999", "wrongpass" }.should raise_exception
  end
end

describe TelenorSMS, "when sending message" do
  class TelenorSMSFake < TelenorSMS
    def login username, password

    end
  end

  before :all do
    @sms_sender = TelenorSMSFake.new "99999999", "password"
  end

  it "should validate message argument" do
    lambda { @sms_sender.send nil, "91919191" }.should raise_exception "Must contain message"
    lambda { @sms_sender.send "", "91919191" }.should raise_exception "Must contain message"
  end

  it "should validate recipients argument" do
    lambda { @sms_sender.send "hello", nil }.should raise_exception "Must contain recipients"
    lambda { @sms_sender.send "hello", "" }.should raise_exception "Must contain recipients"
  end
end