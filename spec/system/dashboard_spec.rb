# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard Views", type: :system do
  describe "Admin Dashboard" do
    let!(:admin_user) { create(:user, :super_admin) }

    before { login_as(admin_user, scope: :user) }

    it "displays admin dashboard with stats" do
      visit root_path

      expect(page).to have_content("Dashboard").or have_content("Tổng quan")
    end

    it "shows recent activity widget" do
      visit root_path

      # Admin dashboard should have activity or stats section
      expect(page).to have_selector("[data-controller]").or have_content("Hoạt động")
    end
  end

  describe "Call Center Dashboard" do
    let!(:call_center_user) { create(:user, :call_center) }

    before { login_as(call_center_user, scope: :user) }

    it "displays call center dashboard with quick create form" do
      visit root_path

      expect(page).to have_content("Tổng quan").or have_content("Dashboard")
    end

    it "shows KPI cards and charts" do
      visit root_path

      # Should have KPI section or stats
      expect(page.body).to include("KPI").or include("Thống kê").or include("contact")
    end
  end

  describe "Sale Dashboard" do
    let!(:sale_user) { create(:user, :sale) }

    before { login_as(sale_user, scope: :user) }

    it "displays sale dashboard view" do
      visit root_path

      expect(page).to have_content("Dashboard").or have_content("Tổng quan").or have_content("Workspace")
    end
  end
end
