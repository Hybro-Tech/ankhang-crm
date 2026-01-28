# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contact, type: :model do
  let(:creator) { create(:user) }
  let(:service_type) { create(:service_type) }

  describe "validations" do
    it "requires name" do
      contact = build(:contact, name: nil)
      expect(contact).not_to be_valid
      expect(contact.errors[:name]).to be_present
    end

    it "limits name to 100 characters" do
      contact = build(:contact, name: "a" * 101)
      expect(contact).not_to be_valid
      expect(contact.errors[:name]).to be_present
    end

    it "requires at least one contact method (phone, zalo_id, or zalo_qr)" do
      contact = build(:contact, phone: nil, zalo_id: nil)
      expect(contact).not_to be_valid
      expect(contact.errors[:base]).to be_present
    end

    it "requires unique phone" do
      create(:contact, phone: "0912121212", created_by_id: creator.id, service_type: service_type)
      contact = build(:contact, phone: "0912121212")
      expect(contact).not_to be_valid
      expect(contact.errors[:phone]).to include("đã tồn tại trong hệ thống")
    end

    it "requires phone minimum 10 digits" do
      contact = build(:contact, phone: "123456789") # 9 chars
      expect(contact).not_to be_valid
    end

    it "validates email format" do
      contact = build(:contact, email: "invalid-email")
      expect(contact).not_to be_valid
      expect(contact.errors[:email]).to be_present
    end

    it "allows blank email" do
      contact = build(:contact, email: nil)
      expect(contact.errors[:email]).to be_empty
    end
  end

  describe "associations" do
    it "belongs to service_type" do
      contact = create(:contact)
      expect(contact.service_type).to be_a(ServiceType)
    end

    it "belongs to team (optional)" do
      contact = create(:contact, team: nil)
      expect(contact).to be_valid
    end

    it "belongs to assigned_user (optional)" do
      contact = create(:contact, assigned_user: nil)
      expect(contact).to be_valid
    end

    it "belongs to creator" do
      contact = create(:contact)
      expect(contact.creator).to be_a(User)
    end

    it "belongs to source" do
      contact = create(:contact)
      expect(contact.source).to be_a(Source)
    end
  end

  describe "enums" do
    it "defines status enum" do
      expect(described_class.statuses.keys).to match_array(
        %w[new_contact potential in_progress potential_old closed_new
           closed_old failed cskh_l1 cskh_l2 closed]
      )
    end
  end

  describe "callbacks" do
    describe "#generate_code" do
      it "auto-generates code on create" do
        contact = create(:contact)
        expect(contact.code).to match(/^KH\d{4}-\d{5}$/)
      end

      it "generates sequential codes" do
        first = create(:contact)
        second = create(:contact)

        first_num = first.code.split("-").last.to_i
        second_num = second.code.split("-").last.to_i

        expect(second_num).to eq(first_num + 1)
      end
    end

    describe "#normalize_phone" do
      it "removes non-digit characters from phone" do
        contact = build(:contact, phone: "+84 (123) 456-7890")
        contact.valid?
        expect(contact.phone).to eq("841234567890")
      end
    end

    describe "#set_team_from_service_type" do
      let(:team) { create(:team) }
      let(:service_type_with_team) { create(:service_type, team: team) }

      it "auto-assigns team from service_type" do
        contact = create(:contact, service_type: service_type_with_team, team: nil)
        expect(contact.team).to eq(team)
      end
    end
  end

  describe "scopes" do
    let(:sale_user) { create(:user) }
    let(:creator_user) { create(:user) }
    let(:st) { create(:service_type) }

    let!(:unassigned_contact) do
      create(:contact, service_type: st, created_by_id: creator_user.id)
    end

    let!(:assigned_contact) do
      create(:contact, service_type: st, assigned_user: sale_user, status: :potential, created_by_id: creator_user.id)
    end

    describe ".unassigned" do
      it "returns contacts without assignee" do
        expect(described_class.unassigned).to include(unassigned_contact)
        expect(described_class.unassigned).not_to include(assigned_contact)
      end
    end

    describe ".assigned" do
      it "returns contacts with assignee" do
        expect(described_class.assigned).to include(assigned_contact)
        expect(described_class.assigned).not_to include(unassigned_contact)
      end
    end

    describe ".search" do
      it "finds by name" do
        contact = create(:contact, name: "Nguyễn Văn Test", created_by_id: creator_user.id, service_type: st)
        expect(described_class.search("Văn")).to include(contact)
      end

      it "finds by phone" do
        contact = create(:contact, phone: "0966666666", created_by_id: creator_user.id, service_type: st)
        expect(described_class.search("0966666")).to include(contact)
      end

      it "finds by code" do
        contact = create(:contact, created_by_id: creator_user.id, service_type: st)
        expect(described_class.search(contact.code)).to include(contact)
      end
    end
  end

  describe "class methods" do
    describe ".phone_exists?" do
      it "returns true if phone exists" do
        create(:contact, phone: "0988888888", created_by_id: creator.id, service_type: service_type)
        expect(described_class.phone_exists?("0988888888")).to be true
      end

      it "returns false if phone does not exist" do
        expect(described_class.phone_exists?("0999999999")).to be false
      end
    end

    describe ".find_by_phone" do
      it "finds contact by normalized phone" do
        contact = create(:contact, phone: "0977777777", created_by_id: creator.id, service_type: service_type)
        # rubocop:disable Rails/DynamicFindBy
        expect(described_class.find_by_phone("0977777777")).to eq(contact)
        # rubocop:enable Rails/DynamicFindBy
      end
    end
  end

  describe "instance methods" do
    let(:sale) { create(:user) }

    describe "#pickable?" do
      it "returns true for unassigned new contact" do
        contact = create(:contact, status: :new_contact, created_by_id: creator.id, service_type: service_type)
        expect(contact.pickable?).to be true
      end

      it "returns false for assigned contact" do
        contact = create(:contact, assigned_user: sale, status: :potential,
                                   created_by_id: creator.id, service_type: service_type)
        expect(contact.pickable?).to be false
      end
    end

    describe "#assign_to!" do
      it "assigns contact to user" do
        contact = create(:contact, created_by_id: creator.id, service_type: service_type)
        result = contact.assign_to!(sale)

        expect(result).to be true
        expect(contact.reload.assigned_user).to eq(sale)
        expect(contact.status).to eq("potential")
        expect(contact.assigned_at).to be_present
      end

      it "returns false if already assigned" do
        contact = create(:contact, assigned_user: sale, status: :potential,
                                   created_by_id: creator.id, service_type: service_type)
        result = contact.assign_to!(creator)

        expect(result).to be false
      end
    end

    describe "#status_label" do
      it "returns translated status" do
        contact = build(:contact, status: :new_contact)
        expect(contact.status_label).to eq("Mới")
      end
    end

    describe "#source_label" do
      let(:source) { create(:source, name: "Facebook Test Label") }
      it "returns source name" do
        contact = build(:contact, source: source)
        expect(contact.source_label).to eq("Facebook Test Label")
      end
    end
  end
end
