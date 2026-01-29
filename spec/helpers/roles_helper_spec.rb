# frozen_string_literal: true

require "rails_helper"

RSpec.describe RolesHelper, type: :helper do
  describe "#role_icon_bg_class" do
    it "returns red for admin dashboard_type" do
      role = build(:role, dashboard_type: :admin)
      expect(helper.role_icon_bg_class(role)).to include("bg-red")
    end

    it "returns green for sale dashboard_type" do
      role = build(:role, dashboard_type: :sale)
      expect(helper.role_icon_bg_class(role)).to include("bg-green")
    end

    it "returns purple for call_center dashboard_type" do
      role = build(:role, dashboard_type: :call_center)
      expect(helper.role_icon_bg_class(role)).to include("bg-purple")
    end

    it "returns teal for cskh dashboard_type" do
      role = build(:role, dashboard_type: :cskh)
      expect(helper.role_icon_bg_class(role)).to include("bg-teal")
    end

    it "returns gray for unknown dashboard_type" do
      role = build(:role, dashboard_type: nil)
      expect(helper.role_icon_bg_class(role)).to include("bg-gray")
    end

    it "returns blue for manager role name" do
      role = build(:role, dashboard_type: nil, name: "Manager Team A")
      expect(helper.role_icon_bg_class(role)).to include("bg-blue")
    end
  end

  describe "#role_icon_class" do
    it "returns shield icon for admin" do
      role = build(:role, dashboard_type: :admin)
      expect(helper.role_icon_class(role)).to include("shield")
    end

    it "returns headset icon for sale" do
      role = build(:role, dashboard_type: :sale)
      expect(helper.role_icon_class(role)).to include("headset")
    end

    it "returns phone icon for call_center" do
      role = build(:role, dashboard_type: :call_center)
      expect(helper.role_icon_class(role)).to include("phone")
    end

    it "returns heart icon for cskh" do
      role = build(:role, dashboard_type: :cskh)
      expect(helper.role_icon_class(role)).to include("heart")
    end

    it "returns user icon for unknown dashboard_type" do
      role = build(:role, dashboard_type: nil)
      expect(helper.role_icon_class(role)).to include("user")
    end
  end

  describe "#category_icon_class" do
    it "returns correct icon for Khách hàng" do
      expect(helper.category_icon_class("Khách hàng")).to include("users")
    end

    it "returns correct icon for Nhân viên" do
      expect(helper.category_icon_class("Nhân viên")).to include("id-card")
    end

    it "returns folder icon for unknown category" do
      expect(helper.category_icon_class("Unknown")).to include("folder")
    end
  end
end
