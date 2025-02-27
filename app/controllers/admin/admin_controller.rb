module Admin
  class AdminController < ApplicationController
    before_action :authenticate_admin_user!
    layout "admin"

    private

    def current_admin
      current_admin_user
    end

    helper_method :current_admin
  end
end
