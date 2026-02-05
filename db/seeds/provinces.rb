# frozen_string_literal: true

# TASK-061: Seed 63 Vietnamese provinces
# Data source: https://provinces.open-api.vn/api/p/

PROVINCES = [
  # Bắc (Northern Vietnam) - 25 provinces
  { name: "Hà Nội", code: "01", phone_code: "24", position: 1 },
  { name: "Hà Giang", code: "02", phone_code: "219", position: 2 },
  { name: "Cao Bằng", code: "04", phone_code: "206", position: 3 },
  { name: "Bắc Kạn", code: "06", phone_code: "209", position: 4 },
  { name: "Tuyên Quang", code: "08", phone_code: "207", position: 5 },
  { name: "Lào Cai", code: "10", phone_code: "214", position: 6 },
  { name: "Điện Biên", code: "11", phone_code: "215", position: 7 },
  { name: "Lai Châu", code: "12", phone_code: "213", position: 8 },
  { name: "Sơn La", code: "14", phone_code: "212", position: 9 },
  { name: "Yên Bái", code: "15", phone_code: "216", position: 10 },
  { name: "Hoà Bình", code: "17", phone_code: "218", position: 11 },
  { name: "Thái Nguyên", code: "19", phone_code: "208", position: 12 },
  { name: "Lạng Sơn", code: "20", phone_code: "205", position: 13 },
  { name: "Quảng Ninh", code: "22", phone_code: "203", position: 14 },
  { name: "Bắc Giang", code: "24", phone_code: "204", position: 15 },
  { name: "Phú Thọ", code: "25", phone_code: "210", position: 16 },
  { name: "Vĩnh Phúc", code: "26", phone_code: "211", position: 17 },
  { name: "Bắc Ninh", code: "27", phone_code: "222", position: 18 },
  { name: "Hải Dương", code: "30", phone_code: "220", position: 19 },
  { name: "Hải Phòng", code: "31", phone_code: "225", position: 20 },
  { name: "Hưng Yên", code: "33", phone_code: "221", position: 21 },
  { name: "Thái Bình", code: "34", phone_code: "227", position: 22 },
  { name: "Hà Nam", code: "35", phone_code: "226", position: 23 },
  { name: "Nam Định", code: "36", phone_code: "228", position: 24 },
  { name: "Ninh Bình", code: "37", phone_code: "229", position: 25 },

  # Trung (Central Vietnam) - 19 provinces
  { name: "Thanh Hoá", code: "38", phone_code: "237", position: 26 },
  { name: "Nghệ An", code: "40", phone_code: "238", position: 27 },
  { name: "Hà Tĩnh", code: "42", phone_code: "239", position: 28 },
  { name: "Quảng Bình", code: "44", phone_code: "232", position: 29 },
  { name: "Quảng Trị", code: "45", phone_code: "233", position: 30 },
  { name: "Thừa Thiên Huế", code: "46", phone_code: "234", position: 31 },
  { name: "Đà Nẵng", code: "48", phone_code: "236", position: 32 },
  { name: "Quảng Nam", code: "49", phone_code: "235", position: 33 },
  { name: "Quảng Ngãi", code: "51", phone_code: "255", position: 34 },
  { name: "Bình Định", code: "52", phone_code: "256", position: 35 },
  { name: "Phú Yên", code: "54", phone_code: "257", position: 36 },
  { name: "Khánh Hoà", code: "56", phone_code: "258", position: 37 },
  { name: "Ninh Thuận", code: "58", phone_code: "259", position: 38 },
  { name: "Bình Thuận", code: "60", phone_code: "252", position: 39 },
  { name: "Kon Tum", code: "62", phone_code: "260", position: 40 },
  { name: "Gia Lai", code: "64", phone_code: "269", position: 41 },
  { name: "Đắk Lắk", code: "66", phone_code: "262", position: 42 },
  { name: "Đắk Nông", code: "67", phone_code: "261", position: 43 },
  { name: "Lâm Đồng", code: "68", phone_code: "263", position: 44 },

  # Nam (Southern Vietnam) - 19 provinces
  { name: "Bình Phước", code: "70", phone_code: "271", position: 45 },
  { name: "Tây Ninh", code: "72", phone_code: "276", position: 46 },
  { name: "Bình Dương", code: "74", phone_code: "274", position: 47 },
  { name: "Đồng Nai", code: "75", phone_code: "251", position: 48 },
  { name: "Bà Rịa - Vũng Tàu", code: "77", phone_code: "254", position: 49 },
  { name: "TP. Hồ Chí Minh", code: "79", phone_code: "28", position: 50 },
  { name: "Long An", code: "80", phone_code: "272", position: 51 },
  { name: "Tiền Giang", code: "82", phone_code: "273", position: 52 },
  { name: "Bến Tre", code: "83", phone_code: "275", position: 53 },
  { name: "Trà Vinh", code: "84", phone_code: "294", position: 54 },
  { name: "Vĩnh Long", code: "86", phone_code: "270", position: 55 },
  { name: "Đồng Tháp", code: "87", phone_code: "277", position: 56 },
  { name: "An Giang", code: "89", phone_code: "296", position: 57 },
  { name: "Kiên Giang", code: "91", phone_code: "297", position: 58 },
  { name: "Cần Thơ", code: "92", phone_code: "292", position: 59 },
  { name: "Hậu Giang", code: "93", phone_code: "293", position: 60 },
  { name: "Sóc Trăng", code: "94", phone_code: "299", position: 61 },
  { name: "Bạc Liêu", code: "95", phone_code: "291", position: 62 },
  { name: "Cà Mau", code: "96", phone_code: "290", position: 63 }
].freeze

# Default region mappings (provinces to regions)
REGION_MAPPINGS = {
  "bac" => (1..25).to_a,      # Northern: positions 1-25
  "trung" => (26..44).to_a,   # Central: positions 26-44
  "nam" => (45..63).to_a      # Southern: positions 45-63
}.freeze

# Clean up old data first
Rails.logger.debug "🗑️ Cleaning up old province data..."
ProvinceRegion.delete_all
Province.delete_all

# Seed provinces
Province.transaction do
  PROVINCES.each do |attrs|
    Province.create!(
      name: attrs[:name],
      code: attrs[:code],
      position: attrs[:position],
      active: true
    )
  end

  Rails.logger.debug { "✅ Seeded #{Province.count} provinces" }
end

# Seed province-region mappings
ProvinceRegion.transaction do
  REGION_MAPPINGS.each do |region_code, positions|
    region = Region.find_by(code: region_code)
    next unless region

    positions.each do |position|
      province = Province.find_by(position: position)
      next unless province

      ProvinceRegion.find_or_create_by!(province: province, region: region)
    end
  end

  Rails.logger.debug { "✅ Created #{ProvinceRegion.count} province-region mappings" }
end
