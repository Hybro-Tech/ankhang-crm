# frozen_string_literal: true

# TASK-061: Seed 63 Vietnamese provinces
# Data source: https://vi.wikipedia.org/wiki/Tỉnh_thành_Việt_Nam

PROVINCES = [
  # Bắc (Northern Vietnam) - 25 provinces
  { name: "Hà Nội", code: "HN", position: 1 },
  { name: "Hà Giang", code: "HG", position: 2 },
  { name: "Cao Bằng", code: "CB", position: 3 },
  { name: "Bắc Kạn", code: "BK", position: 4 },
  { name: "Tuyên Quang", code: "TQ", position: 5 },
  { name: "Lào Cai", code: "LC", position: 6 },
  { name: "Điện Biên", code: "DB", position: 7 },
  { name: "Lai Châu", code: "LAC", position: 8 },
  { name: "Sơn La", code: "SL", position: 9 },
  { name: "Yên Bái", code: "YB", position: 10 },
  { name: "Hoà Bình", code: "HB", position: 11 },
  { name: "Thái Nguyên", code: "TN", position: 12 },
  { name: "Lạng Sơn", code: "LS", position: 13 },
  { name: "Quảng Ninh", code: "QN", position: 14 },
  { name: "Bắc Giang", code: "BG", position: 15 },
  { name: "Phú Thọ", code: "PT", position: 16 },
  { name: "Vĩnh Phúc", code: "VP", position: 17 },
  { name: "Bắc Ninh", code: "BN", position: 18 },
  { name: "Hải Dương", code: "HD", position: 19 },
  { name: "Hải Phòng", code: "HP", position: 20 },
  { name: "Hưng Yên", code: "HY", position: 21 },
  { name: "Thái Bình", code: "TB", position: 22 },
  { name: "Hà Nam", code: "HNA", position: 23 },
  { name: "Nam Định", code: "ND", position: 24 },
  { name: "Ninh Bình", code: "NB", position: 25 },

  # Trung (Central Vietnam) - 19 provinces
  { name: "Thanh Hoá", code: "TH", position: 26 },
  { name: "Nghệ An", code: "NA", position: 27 },
  { name: "Hà Tĩnh", code: "HT", position: 28 },
  { name: "Quảng Bình", code: "QB", position: 29 },
  { name: "Quảng Trị", code: "QT", position: 30 },
  { name: "Thừa Thiên Huế", code: "TTH", position: 31 },
  { name: "Đà Nẵng", code: "DN", position: 32 },
  { name: "Quảng Nam", code: "QNA", position: 33 },
  { name: "Quảng Ngãi", code: "QNG", position: 34 },
  { name: "Bình Định", code: "BD", position: 35 },
  { name: "Phú Yên", code: "PY", position: 36 },
  { name: "Khánh Hoà", code: "KH", position: 37 },
  { name: "Ninh Thuận", code: "NT", position: 38 },
  { name: "Bình Thuận", code: "BTH", position: 39 },
  { name: "Kon Tum", code: "KT", position: 40 },
  { name: "Gia Lai", code: "GL", position: 41 },
  { name: "Đắk Lắk", code: "DL", position: 42 },
  { name: "Đắk Nông", code: "DNG", position: 43 },
  { name: "Lâm Đồng", code: "LD", position: 44 },

  # Nam (Southern Vietnam) - 19 provinces
  { name: "Bình Phước", code: "BP", position: 45 },
  { name: "Tây Ninh", code: "TNI", position: 46 },
  { name: "Bình Dương", code: "BDU", position: 47 },
  { name: "Đồng Nai", code: "DNO", position: 48 },
  { name: "Bà Rịa - Vũng Tàu", code: "VT", position: 49 },
  { name: "TP. Hồ Chí Minh", code: "HCM", position: 50 },
  { name: "Long An", code: "LA", position: 51 },
  { name: "Tiền Giang", code: "TG", position: 52 },
  { name: "Bến Tre", code: "BT", position: 53 },
  { name: "Trà Vinh", code: "TV", position: 54 },
  { name: "Vĩnh Long", code: "VL", position: 55 },
  { name: "Đồng Tháp", code: "DTP", position: 56 },
  { name: "An Giang", code: "AG", position: 57 },
  { name: "Kiên Giang", code: "KG", position: 58 },
  { name: "Cần Thơ", code: "CT", position: 59 },
  { name: "Hậu Giang", code: "HGI", position: 60 },
  { name: "Sóc Trăng", code: "ST", position: 61 },
  { name: "Bạc Liêu", code: "BL", position: 62 },
  { name: "Cà Mau", code: "CM", position: 63 }
].freeze

# Default region mappings (provinces to regions)
REGION_MAPPINGS = {
  "bac" => (1..25).to_a,      # Northern: positions 1-25
  "trung" => (26..44).to_a,   # Central: positions 26-44
  "nam" => (45..63).to_a      # Southern: positions 45-63
}.freeze

# Seed provinces
Province.transaction do
  PROVINCES.each do |attrs|
    Province.find_or_create_by!(code: attrs[:code]) do |province|
      province.name = attrs[:name]
      province.position = attrs[:position]
      province.active = true
    end
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
