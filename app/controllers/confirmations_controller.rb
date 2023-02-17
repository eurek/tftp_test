# Solution from https://github.com/heartcombo/devise/wiki/How-To:
# -Override-confirmations-so-users-can-pick-their-own -passwords-as-part-of-confirmation-activation
class ConfirmationsController < Devise::ConfirmationsController
  # Remove the first skip_before_filter (:require_no_authentication) if you
  # don't want to enable logged users to access the confirmation page.
  # If you are using rails 5.1+ use: skip_before_action
  skip_before_action :authenticate_user!
  layout "login"

  # TODO: Voir avec Manu l'UX de ce controller, est-ce qu'on empêche l'accès au new ?
  # Lors de l'opération il y avait des personnes dont le compte n'était pas créé qui du coup essayaient de se rendre
  # sur le site et tentaient des réinitialiser leur mot de passe. Et du coup on leur demander de confirmer leur email
  # d'abord. Est-ce qu'on peut gérer ça mieux ?

  # PUT /resource/confirmation
  def update
    with_unconfirmed_confirmable do
      if @confirmable.has_no_password?
        @confirmable.attempt_set_password(params[:user])
        if @confirmable.valid? && @confirmable.password_match?
          do_confirm
        else
          do_show
          @confirmable.errors.clear # so that we wont render :new
        end
      else
        @confirmable.errors.add(:email, :password_already_set)
      end
    end

    unless @confirmable.errors.empty?
      self.resource = @confirmable
      render "devise/confirmations/new" # Change this if you don't have the views on default path
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    with_unconfirmed_confirmable do
      if @confirmable.has_no_password?
        do_show
      else
        do_confirm
      end
    end
    unless @confirmable.errors.empty?
      self.resource = @confirmable
      render "devise/confirmations/new" # Change this if you don't have the views on default path
    end
  end

  protected

  def with_unconfirmed_confirmable
    @confirmable = User.find_or_initialize_with_error_by(:confirmation_token, params[:confirmation_token])
    unless @confirmable.new_record?
      @confirmable.only_if_unconfirmed { yield }
    end
  end

  def do_show
    @confirmation_token = params[:confirmation_token]
    @requires_password = true
    self.resource = @confirmable
    render "devise/confirmations/show" # Change this if you don't have the views on default path
  end

  def do_confirm
    @confirmable.confirm
    set_flash_message :notice, :confirmed
    sign_in_and_redirect(resource_name, @confirmable)
  end
end
