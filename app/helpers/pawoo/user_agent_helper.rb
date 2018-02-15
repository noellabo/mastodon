module Pawoo::UserAgentHelper
  def ios_safari?
    request.user_agent =~ /Mac OS X.*Mobile.*Safari/ && !(request.user_agent =~ /Chrome/)
  end
end
