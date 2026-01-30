# frozen_string_literal: true

require "rails_helper"

RSpec.describe SmartRoutingExpandJob, type: :job do
  let(:team) { create(:team) }
  let(:service_type) { create(:service_type, team: team, visibility_expand_minutes: 2) }
  let(:sale_role) { Role.find_by(code: Role::SALE) || create(:role, code: Role::SALE, dashboard_type: :sale) }
  let(:sale_user) { create(:user, roles: [sale_role], teams: [team]) }
  let(:tongdai_role) { Role.find_by(name: "Tổng Đài") || create(:role, name: "Tổng Đài", code: "call_center") }
  let(:tongdai_user) { create(:user, roles: [tongdai_role]) }

  # Create contact without triggering smart routing callbacks
  let(:contact) do
    Contact.create!(
      name: "Test Contact",
      phone: "0901234567",
      service_type: service_type,
      source: Source.first || create(:source),
      created_by_id: tongdai_user.id,
      status: :new_contact,
      visible_to_user_ids: [sale_user.id],
      code: "KH2026-TEST#{rand(10_000)}"
    )
  end

  # Skip smart routing initialization for tests
  before do
    allow_any_instance_of(Contact).to receive(:initialize_smart_routing)
  end

  describe "#perform with contact_id" do
    context "when contact exists and is unassigned" do
      it "expands visibility via SmartRoutingService" do
        service_instance = instance_double(SmartRoutingService, expand_visibility: true)
        allow(SmartRoutingService).to receive(:new).and_return(service_instance)

        described_class.new.perform(contact.id)

        expect(service_instance).to have_received(:expand_visibility)
      end

      it "schedules next expansion job when expand returns true" do
        allow_any_instance_of(SmartRoutingService).to receive(:expand_visibility).and_return(true)

        # Use allow first to capture call, then verify
        job_double = instance_double(ActiveJob::ConfiguredJob)
        allow(described_class).to receive(:set).with(wait: 2.minutes).and_return(job_double)
        allow(job_double).to receive(:perform_later)

        described_class.new.perform(contact.id)

        expect(described_class).to have_received(:set).with(wait: 2.minutes)
        expect(job_double).to have_received(:perform_later).with(contact.id)
      end
    end

    context "when contact is already assigned" do
      before { contact.update!(assigned_user_id: sale_user.id) }

      it "does not expand visibility" do
        expect(SmartRoutingService).not_to receive(:new)

        described_class.new.perform(contact.id)
      end

      it "logs skip reason" do
        expect(Rails.logger).to receive(:info).with(/already assigned/)

        described_class.new.perform(contact.id)
      end
    end

    context "when contact does not exist" do
      it "handles gracefully without error" do
        expect { described_class.new.perform(999_999) }.not_to raise_error
      end

      it "logs skip reason" do
        expect(Rails.logger).to receive(:info).with(/not found/)

        described_class.new.perform(999_999)
      end
    end

    context "when contact status is not new_contact" do
      before { contact.update!(status: :potential) }

      it "does not expand visibility" do
        expect(SmartRoutingService).not_to receive(:new)

        described_class.new.perform(contact.id)
      end
    end

    context "when expand_visibility returns false (switched to pool mode)" do
      it "does not schedule next job" do
        allow_any_instance_of(SmartRoutingService).to receive(:expand_visibility).and_return(false)

        job_double = instance_double(ActiveJob::ConfiguredJob)
        allow(described_class).to receive(:set).and_return(job_double)
        allow(job_double).to receive(:perform_later)

        described_class.new.perform(contact.id)

        expect(described_class).not_to have_received(:set)
      end
    end
  end

  describe "#perform without contact_id (batch mode)" do
    it "calls SmartRoutingService.expand_all_pending" do
      expect(SmartRoutingService).to receive(:expand_all_pending)

      described_class.new.perform
    end
  end

  describe "job scheduling interval" do
    it "uses visibility_expand_minutes from service_type" do
      contact.service_type.update!(visibility_expand_minutes: 5)
      allow_any_instance_of(SmartRoutingService).to receive(:expand_visibility).and_return(true)

      job_double = instance_double(ActiveJob::ConfiguredJob)
      allow(described_class).to receive(:set).with(wait: 5.minutes).and_return(job_double)
      allow(job_double).to receive(:perform_later)

      described_class.new.perform(contact.id)

      expect(described_class).to have_received(:set).with(wait: 5.minutes)
    end
  end
end
