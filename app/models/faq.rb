class Faq < ApplicationRecord
  validates :question, presence: true, uniqueness: true
  validates :answer, presence: true
  validates :category, presence: true

  # Define common categories
  CATEGORIES = [
    "Orders & Shipping",
    "Returns & Refunds",
    "Product Information",
    "Account & Payment",
    "Technical Support",
  ].freeze

  validates :category, inclusion: { in: CATEGORIES }

  # Scopes for easier querying
  scope :by_category, ->(category) { where(category: category).order(:question) }

  # Improved search functionality
  scope :search, ->(query) {
          where("
      question ILIKE :q OR
      answer ILIKE :q OR
      category ILIKE :q OR
      :q = ANY (
        regexp_split_to_array(
          lower(question || ' ' || answer || ' ' || category),
          '\s+'
        )
      )",
                q: "%#{query}%")
        }

  # Returns the most relevant FAQ(s) for a given query
  def self.find_relevant(query)
    return none if query.blank?

    # Clean and normalize the query
    normalized_query = query.downcase.strip

    # Try exact matches first
    exact_matches = search(normalized_query)
    return exact_matches if exact_matches.any?

    # If no exact matches, try matching individual words
    words = normalized_query.split(/\s+/)
    words.each do |word|
      next if word.length < 3  # Skip very short words
      matches = search(word)
      return matches if matches.any?
    end

    # If still no matches, try fuzzy matching with key terms
    key_terms = extract_key_terms(normalized_query)
    key_terms.each do |term|
      matches = search(term)
      return matches if matches.any?
    end

    none
  end

  private

  def self.extract_key_terms(query)
    # Add common synonyms and related terms for better matching
    terms = {
      "order" => ["purchase", "buy", "ordering"],
      "shipping" => ["delivery", "ship", "tracking"],
      "payment" => ["pay", "card", "billing"],
      "return" => ["refund", "exchange", "send back"],
      "account" => ["login", "sign in", "profile"],
      "product" => ["item", "merchandise"],
      "price" => ["cost", "pricing", "expensive", "cheap"],
      "cancel" => ["stop", "remove"],
      "status" => ["where", "track", "following"],
    }

    extracted_terms = []
    terms.each do |key, synonyms|
      if query.include?(key) || synonyms.any? { |s| query.include?(s) }
        extracted_terms << key
        extracted_terms.concat(synonyms)
      end
    end

    extracted_terms.uniq
  end
end
