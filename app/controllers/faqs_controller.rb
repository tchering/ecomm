class FaqsController < ApplicationController
  def index
    @faqs = Faq.all.order(:category, :question)
    @categories = Faq::CATEGORIES
  end
end
