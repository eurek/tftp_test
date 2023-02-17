module CustomHelpers
  def sign_in_as_admin
    AdminUser.create(email: "admin@example.com", password: "1234567890", password_confirmation: "1234567890")
    post "/en/admin/login", params: {admin_user: {email: "admin@example.com", password: "1234567890"}}
  end

  def sign_in_as(user)
    post "/fr/users/sign_in", params: {user: {email: user.email, password: "password"}}
  end

  def response_json
    return "" if response.body == ""

    JSON.parse(response.body)
  end
end
