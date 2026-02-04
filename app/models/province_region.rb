# frozen_string_literal: true

# == Schema Information
#
# Table name: province_regions
#
#  id          :bigint           not null, primary key
#  province_id :bigint           not null
#  region_id   :bigint           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_province_regions_on_province_id_and_region_id (province_id, region_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_... (province_id => provinces.id)
#  fk_rails_... (region_id => regions.id)
#

# TASK-061: Join model for Province <-> Region (many-to-many)
class ProvinceRegion < ApplicationRecord
  belongs_to :province
  belongs_to :region
end
