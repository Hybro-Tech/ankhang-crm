# frozen_string_literal: true

# Seed 34 tỉnh/thành phố từ 34tinhthanh.com API
# Data source: https://34tinhthanh.com/api/provinces

Rails.logger.debug "Seeding 34 provinces..."

# Clear foreign key references first
Contact.where.not(province_id: nil).update_all(province_id: nil)
User.where.not(region_id: nil).update_all(region_id: nil)
Rails.logger.debug "  Cleared foreign key references"

# Clear existing data
ProvinceRegion.delete_all
Province.delete_all
Region.delete_all
Rails.logger.debug "  Cleared old province and region data"

# 34 tỉnh/thành từ API (sorted by code)
provinces_data = [
  { code: "01", name: "Thành phố Hà Nội" },
  { code: "04", name: "Cao Bằng" },
  { code: "08", name: "Tuyên Quang" },
  { code: "11", name: "Điện Biên" },
  { code: "12", name: "Lai Châu" },
  { code: "14", name: "Sơn La" },
  { code: "15", name: "Lào Cai" },
  { code: "19", name: "Thái Nguyên" },
  { code: "20", name: "Lạng Sơn" },
  { code: "22", name: "Quảng Ninh" },
  { code: "24", name: "Bắc Ninh" },
  { code: "25", name: "Phú Thọ" },
  { code: "33", name: "Hưng Yên" },
  { code: "37", name: "Ninh Bình" },
  { code: "38", name: "Thanh Hóa" },
  { code: "40", name: "Nghệ An" },
  { code: "42", name: "Hà Tĩnh" },
  { code: "44", name: "Quảng Trị" },
  { code: "46", name: "Thành phố Huế" },
  { code: "48", name: "Thành phố Đà Nẵng" },
  { code: "51", name: "Quảng Ngãi" },
  { code: "52", name: "Gia Lai" },
  { code: "56", name: "Khánh Hòa" },
  { code: "66", name: "Đắk Lắk" },
  { code: "68", name: "Lâm Đồng" },
  { code: "75", name: "Đồng Nai" },
  { code: "79", name: "Thành phố Hồ Chí Minh" },
  { code: "80", name: "Tây Ninh" },
  { code: "82", name: "Đồng Tháp" },
  { code: "86", name: "Vĩnh Long" },
  { code: "91", name: "An Giang" },
  { code: "92", name: "Thành phố Cần Thơ" },
  { code: "96", name: "Cà Mau" }
].freeze

provinces_data.each_with_index do |prov, index|
  Province.create!(
    code: prov[:code],
    name: prov[:name],
    position: index + 1,
    active: true
  )
end

Rails.logger.debug { "  Created #{Province.count} provinces" }

# Regions sẽ được tạo thủ công bởi Admin
# Không tạo regions mặc định nữa
Rails.logger.debug "  Regions sẽ được tạo thủ công bởi Admin thông qua UI"

Rails.logger.debug "Done seeding provinces!"
