# frozen_string_literal: true

require "rails_helper"

RSpec.describe Interaction, type: :model do
  describe "associations" do
    it "belongs to contact" do
      association = described_class.reflect_on_association(:contact)
      expect(association.macro).to eq(:belongs_to)
    end

    it "belongs to user" do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe "validations" do
    it "requires content" do
      interaction = build(:interaction, content: nil)
      expect(interaction).not_to be_valid
      expect(interaction.errors[:content]).to be_present
    end

    it "requires interaction_method" do
      interaction = build(:interaction, interaction_method: nil)
      expect(interaction).not_to be_valid
    end

    context "when interaction_method is appointment" do
      it "requires scheduled_at" do
        interaction = build(:interaction, interaction_method: :appointment, scheduled_at: nil)
        expect(interaction).not_to be_valid
        expect(interaction.errors[:scheduled_at]).to be_present
      end

      it "is valid with scheduled_at" do
        interaction = build(:interaction, :appointment, scheduled_at: 2.days.from_now)
        expect(interaction).to be_valid
      end
    end

    context "when interaction_method is not appointment" do
      it "does not require scheduled_at" do
        interaction = build(:interaction, interaction_method: :call, scheduled_at: nil)
        expect(interaction).to be_valid
      end
    end
  end

  describe "enums" do
    it "defines interaction_method enum with appointment" do
      expect(described_class.interaction_methods).to include("appointment" => 5)
    end

    it "defines all interaction methods" do
      expect(described_class.interaction_methods.keys).to contain_exactly(
        "note", "call", "zalo", "email", "meeting", "appointment"
      )
    end
  end

  describe "scopes" do
    describe ".recent" do
      it "orders by created_at descending" do
        contact = create(:contact)
        user = create(:user)

        old_interaction = create(:interaction, contact: contact, user: user, created_at: 2.days.ago)
        new_interaction = create(:interaction, contact: contact, user: user, created_at: 1.day.ago)

        result = described_class.where(contact: contact).recent
        expect(result.first).to eq(new_interaction)
        expect(result.last).to eq(old_interaction)
      end
    end
  end

  describe "#method_label" do
    it "returns translated label for appointment" do
      interaction = build(:interaction, interaction_method: :appointment)
      expect(interaction.method_label).to eq("Lịch hẹn")
    end

    it "returns translated label for call" do
      interaction = build(:interaction, interaction_method: :call)
      expect(interaction.method_label).to eq("Cuộc gọi")
    end
  end

  describe "#method_icon" do
    it "returns correct icon for appointment" do
      interaction = build(:interaction, interaction_method: :appointment)
      expect(interaction.method_icon).to eq("fa-solid fa-calendar-check")
    end

    it "returns correct icon for call" do
      interaction = build(:interaction, interaction_method: :call)
      expect(interaction.method_icon).to eq("fa-solid fa-phone")
    end

    it "returns correct icon for note" do
      interaction = build(:interaction, interaction_method: :note)
      expect(interaction.method_icon).to eq("fa-solid fa-sticky-note")
    end
  end

  describe "#method_color_class" do
    it "returns purple for appointment" do
      interaction = build(:interaction, interaction_method: :appointment)
      expect(interaction.method_color_class).to eq("bg-purple-100 text-purple-600")
    end

    it "returns blue for call" do
      interaction = build(:interaction, interaction_method: :call)
      expect(interaction.method_color_class).to eq("bg-blue-100 text-blue-600")
    end
  end

  describe "sync_appointment_to_contact callback" do
    let(:user) { create(:user) }
    let(:contact) { create(:contact, assigned_user: user, next_appointment: nil) }

    context "when creating an appointment interaction" do
      it "updates contact.next_appointment" do
        scheduled_time = 2.days.from_now

        create(:interaction,
               contact: contact,
               user: user,
               interaction_method: :appointment,
               scheduled_at: scheduled_time)

        expect(contact.reload.next_appointment).to be_within(1.second).of(scheduled_time)
      end
    end

    context "when creating a non-appointment interaction" do
      it "does not update contact.next_appointment" do
        create(:interaction,
               contact: contact,
               user: user,
               interaction_method: :call)

        expect(contact.reload.next_appointment).to be_nil
      end
    end

    context "when contact already has a next_appointment" do
      let(:existing_time) { 1.day.from_now }
      let(:contact) { create(:contact, assigned_user: user, next_appointment: existing_time) }

      it "updates if new appointment is in the future" do
        new_time = 3.days.from_now

        create(:interaction,
               contact: contact,
               user: user,
               interaction_method: :appointment,
               scheduled_at: new_time)

        expect(contact.reload.next_appointment).to be_within(1.second).of(new_time)
      end
    end
  end
end
