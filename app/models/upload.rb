class Upload < ApplicationRecord
  belongs_to :user

  has_prefix_id :file

  has_one_attached :file
end
