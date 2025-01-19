class Upload < ApplicationRecord
  belongs_to :user

  has_prefix_id :file
end
