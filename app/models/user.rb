class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable

  # Soft delete functionality
  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true, on: :update
  validates :phone_number, format: { with: /\A\+?[\d\s-]+\z/, message: "format is invalid" }, allow_blank: true

  # Virtual attribute for full name
  def full_name
    [first_name, last_name].compact.join(" ").presence || email
  end

  # Soft delete methods
  def soft_delete
    update_attribute(:deleted_at, Time.current)
  end

  def active_for_authentication?
    super && !deleted_at
  end

  def inactive_message
    deleted_at ? :deleted_account : super
  end

  # Admin check
  def admin?
    is_admin
  end
end
