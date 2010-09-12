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
    @login_url = "https://www.telenor.no/privat/minesider/logginnfelles.cms"
    login username, password
  end

  def login username, password
    forms = @agent.get(@login_url).forms
    login_form = nil
    forms.each {|form| login_form = form if form.action == "https://telenormobil.no/minesider/login.do" }
    login_form.j_username = username
    login_form.j_password = password
    @agent.submit(login_form)

    if @agent.page.uri == @login_url then
      error = @agent.page / "div[id='main_content']" / "div[class='section error']" / "span"
      if error != nil then raise error.inner_html end
    end
  end

  def send message, recipients
    Guard::require message != nil && message != "", "Must contain message"
    Guard::require recipients != nil && recipients != "", "Must contain recipients"

    @agent.get "https://telenormobil.no/norm/telenor/sms/send.do"
    sms_form = nil
    @agent.page.forms.each{|form| sms_form = form if form.action == "/norm/telenor/sms/send/process.do" }
    sms_form.toAddress = recipients
    sms_form.message = message
    sms_form.click_button
  end

end
