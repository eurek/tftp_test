# from https://github.com/heartcombo/devise/wiki/How-To:-Use-custom-mailer
class DeviseMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: "devise/mailer" # to make sure that your mailer uses the devise views

  def confirmation_instructions(record, token, opts = {})
    opts[:bcc] = "Laurent Morel<laurent@time-planet.com>"
    super
  end
end
