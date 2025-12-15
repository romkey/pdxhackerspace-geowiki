class User < ApplicationRecord
  has_secure_password validations: false

  has_many :map_maintainers, dependent: :destroy
  has_many :maintained_maps, through: :map_maintainers, source: :map

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, if: -> { provider.blank? && password_digest.present? }
  validates :password_digest, presence: true, if: -> { provider.blank? }

  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize
    user.email = auth.info.email
    user.name = auth.info.name || auth.info.email
    user.is_admin = auth.extra.raw_info["is_admin"] == true || auth.extra.raw_info["is_admin"] == "true"
    user
  end

  def admin?
    is_admin
  end
end

