# frozen_string_literal: true

module DashboardMockData
  extend ActiveSupport::Concern

  private

  def mock_recent_activities
    [
      { icon: "fa-user-plus", color: "text-brand-blue", bg: "bg-blue-100", title: "Khách hàng mới",
        desc: "KH2026-099 đã được tạo.", time: "5 phút trước" },
      { icon: "fa-check-circle", color: "text-green-600", bg: "bg-green-100", title: "Chốt đơn thành công",
        desc: "HD-2026-001 - 15,000,000 ₫", time: "1 giờ trước" }
    ]
  end

  def mock_sale_activities
    [
      { text: "KH2026-099 đã được gán cho bạn.", time: "5 phút trước", icon: "fa-user-plus", color: "text-brand-blue" },
      { text: "Lịch hẹn với KH2026-055 sắp đến.", time: "30 phút nữa", icon: "fa-clock", color: "text-orange-500" }
    ]
  end

  def mock_chart_data
    {
      labels: %w[Th2 Th3 Th4 Th5 Th6 Th7 CN],
      contacts: [12, 19, 3, 5, 2, 3, 15],
      deals: [2, 3, 1, 4, 1, 2, 5]
    }
  end

  def mock_top_performers
    users = User.where(status: :active).limit(5).map do |user|
      {
        name: user.name,
        deals: rand(1..20),
        revenue: rand(10..500) * 1_000_000,
        avatar: "https://ui-avatars.com/api/?name=#{URI.encode_www_form_component(user.name)}&background=random"
      }
    end
    users.sort_by { |u| -u[:deals] }
  end
end
