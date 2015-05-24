require 'rubygems'
require 'open-uri'
require 'mechanize'

module Guard
  def Guard.require expression, message
    if expression == false then raise message end
  end
end

class TelenorSMS
  def initialize username, password
    Guard::require username != nil && username != "", "username must be specified"
    Guard::require password != nil && password != "", "password must be specified"

    @agent = Mechanize.new
    @agent.user_agent_alias = "Windows IE 6"
    @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE #windows openssl "fix". I don't care for security
    @login_url = "https://login.telenor.bg/login"
    login username, password
  end

  def login username, password
    forms = @agent.get(@login_url).forms
    login_form = nil
    forms.each {|form| login_form = form if form.dom_id == "fm1" }
    login_form.username = username
    login_form.password = password
    @agent.submit(login_form)

    if @agent.page.uri == @login_url then
      error = @agent.page / "div[id='main_content']" / "div[class='section error']" / "span"
      if error != nil then raise error.inner_html end
    end
  end

  def send message, recipients
    Guard::require message != nil && message != "", "Must contain message"
    Guard::require recipients != nil && recipients != "", "Must contain recipients"

    @agent.get "https://my.telenor.bg/compose"
    sms_form = nil
    @agent.page.forms.each{|form| sms_form = form if form.dom_id == "new-sms-form" }
    sms_form.receiverPhoneNum = recipients
    sms_form.txtareaMessage = message
    sms_form.click_button
  end

end
