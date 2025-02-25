class AdminController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  # No need for custom authentication methods as Devise provides authenticate_admin!
end
