# frozen_string_literal: true

class Resource < ApplicationRecord
  include Journable

  belongs_to :parent, class_name: "Resource", optional: true, inverse_of: :children
  has_many :children, class_name: "Resource", foreign_key: "parent_id", dependent: :nullify, inverse_of: :parent

  has_many :resource_urls, dependent: :destroy
  has_many :resource_locations, dependent: :destroy
  has_many :resource_external_locations, dependent: :destroy
  has_many :maps, through: :resource_locations

  validates :name, presence: true

  accepts_nested_attributes_for :resource_urls, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :resource_locations, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :resource_external_locations, allow_destroy: true, reject_if: :all_blank

  scope :internal, -> { where(internal: true) }
  scope :external, -> { where(internal: false) }
  scope :top_level, -> { where(parent_id: nil) }
  scope :public_only, -> { where(admin_only: false) }
  scope :visible_to, ->(user) { user&.admin? ? all : public_only }

  def internal?
    internal
  end

  def external?
    !internal
  end

  def has_external_locations?
    resource_external_locations.any?
  end

  # Get all resources in this hierarchy (self + all descendants)
  def self_and_descendants(user = nil)
    [self] + descendants(user)
  end

  # Get all descendant resources recursively
  def descendants(user = nil)
    visible_children(user).flat_map { |c| c.self_and_descendants(user) }
  end

  # Get children visible to the given user
  def visible_children(user = nil)
    user&.admin? ? children : children.public_only
  end

  # Get all internal map locations including from children (recursive)
  def all_resource_locations(user = nil)
    self_and_descendants(user).flat_map(&:resource_locations)
  end

  # Get all external locations including from children (recursive)
  def all_external_locations(user = nil)
    self_and_descendants(user).flat_map(&:resource_external_locations)
  end

  # Get breadcrumb trail from root to this resource
  def ancestors
    parent ? parent.ancestors + [parent] : []
  end

  # Get the root parent of this resource
  def root
    parent ? parent.root : self
  end
end
