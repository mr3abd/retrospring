class InboxController < ApplicationController
  before_filter :authenticate_user!

  def show
    @inbox = Inbox.where(user: current_user).order(:created_at).reverse_order
  end
end