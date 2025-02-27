class AdminController < ApplicationController
  before_action :authenticate_admin_user!
  layout "admin"

  # No need for custom authentication methods as Devise provides authenticate_admin_user!
end
