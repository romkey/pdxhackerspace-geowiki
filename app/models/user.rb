# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password validations: false

  has_many :map_maintainers, dependent: :destroy
  has_many :maintained_maps, through: :map_maintainers, source: :map

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, if: -> { provider.blank? && password_digest.blank? }
  validates :password_digest, presence: true, if: -> { provider.blank? }

  def self.hash_password(unencrypted_password)
    BCrypt::Password.create(unencrypted_password)
  end

  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize
    user.email = auth.info.email
    user.name = auth.info.name || auth.info.email
    user.is_admin = [true, "true"].include?(auth.extra.raw_info["is_admin"])
    user
  end

  def admin?
    is_admin
  end
end
