# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReassignRequest, type: :model do
  # Factories and let blocks
  let(:team) { create(:team, manager: leader) }
  let(:leader) { create(:user) }
  let(:contact) { create(:contact, team: team) }
  let(:from_user) { create(:user) }
  let(:to_user) { create(:user) }
  let(:requested_by) { create(:user) }

  # Associations
  describe "associations" do
    let(:request) do
      create(:reassign_request,
             contact: contact,
             from_user: from_user,
             to_user: to_user,
             requested_by: requested_by)
    end

    it "belongs to contact" do
      expect(request.contact).to eq(contact)
    end

    it "belongs to from_user" do
      expect(request.from_user).to eq(from_user)
    end

    it "belongs to to_user" do
      expect(request.to_user).to eq(to_user)
    end

    it "belongs to requested_by" do
      expect(request.requested_by).to eq(requested_by)
    end

    it "optionally belongs to approved_by" do
      expect(request.approved_by).to be_nil

      request.update!(approved_by: leader, status: :approved, decided_at: Time.current)
      expect(request.approved_by).to eq(leader)
    end
  end

  # Validations
  describe "validations" do
    it "requires reason" do
      request = build(:reassign_request,
                      contact: contact,
                      from_user: from_user,
                      to_user: to_user,
                      requested_by: requested_by,
                      reason: nil)
      expect(request).not_to be_valid
      expect(request.errors[:reason]).to be_present
    end

    describe "to_user requirement for reassign" do
      context "when reassigning (to_user present)" do
        it "is valid with to_user" do
          request = build(:reassign_request,
                          contact: contact,
                          from_user: from_user,
                          to_user: to_user,
                          requested_by: requested_by)
          # set_request_type callback will set request_type to :reassign
          expect(request).to be_valid
          expect(request.request_type).to eq("reassign")
        end
      end

      context "when unassigning (to_user nil)" do
        it "is valid without to_user" do
          request = build(:reassign_request,
                          contact: contact,
                          from_user: from_user,
                          to_user: nil,
                          requested_by: requested_by)
          # set_request_type callback will set request_type to :unassign
          expect(request).to be_valid
          expect(request.request_type).to eq("unassign")
        end
      end
    end
  end

  # Enums
  describe "enums" do
    it "has status enum" do
      expect(described_class.statuses).to eq("pending" => 0, "approved" => 1, "rejected" => 2)
    end

    it "has request_type enum" do
      expect(described_class.request_types).to eq("reassign" => 0, "unassign" => 1)
    end
  end

  # Scopes
  describe "scopes" do
    describe ".for_approver" do
      let!(:request_in_team) do
        create(:reassign_request,
               contact: contact,
               from_user: from_user,
               to_user: to_user,
               requested_by: requested_by)
      end

      let(:other_team) { create(:team, manager: create(:user)) }
      let(:other_contact) { create(:contact, team: other_team) }
      let!(:request_other_team) do
        create(:reassign_request,
               contact: other_contact,
               from_user: from_user,
               to_user: to_user,
               requested_by: requested_by)
      end

      it "returns requests for contacts in teams managed by the user" do
        result = described_class.for_approver(leader)
        expect(result).to include(request_in_team)
        expect(result).not_to include(request_other_team)
      end
    end

    describe ".pending" do
      let!(:pending_request) do
        create(:reassign_request, :pending,
               contact: contact,
               from_user: from_user,
               to_user: to_user,
               requested_by: requested_by)
      end

      let(:other_contact) { create(:contact, team: team) }
      let!(:approved_request) do
        create(:reassign_request, :approved,
               contact: other_contact,
               from_user: from_user,
               to_user: to_user,
               requested_by: requested_by,
               approved_by: leader)
      end

      it "returns only pending requests" do
        expect(described_class.pending).to include(pending_request)
        expect(described_class.pending).not_to include(approved_request)
      end
    end
  end

  # Instance Methods
  describe "#reassign?" do
    it "returns true for reassign type" do
      request = build(:reassign_request, to_user: to_user)
      request.valid? # trigger callback
      expect(request.reassign?).to be true
    end

    it "returns false for unassign type" do
      request = build(:reassign_request, to_user: nil)
      request.valid? # trigger callback
      expect(request.reassign?).to be false
    end
  end

  describe "#unassign?" do
    it "returns true for unassign type" do
      request = build(:reassign_request, to_user: nil)
      request.valid? # trigger callback
      expect(request.unassign?).to be true
    end
  end

  describe "#approve!" do
    let!(:request) do
      create(:reassign_request,
             contact: contact,
             from_user: from_user,
             to_user: to_user,
             requested_by: requested_by)
    end

    before do
      contact.update!(assigned_user: from_user)
    end

    it "updates status to approved" do
      request.approve!(leader)
      expect(request.reload.status).to eq("approved")
    end

    it "sets approved_by" do
      request.approve!(leader)
      expect(request.reload.approved_by).to eq(leader)
    end

    it "reassigns the contact" do
      request.approve!(leader)
      expect(contact.reload.assigned_user).to eq(to_user)
    end
  end

  describe "#reject!" do
    let!(:request) do
      create(:reassign_request,
             contact: contact,
             from_user: from_user,
             to_user: to_user,
             requested_by: requested_by)
    end

    it "updates status to rejected" do
      request.reject!(leader, "Không đồng ý")
      expect(request.reload.status).to eq("rejected")
    end

    it "stores rejection reason" do
      request.reject!(leader, "Không đồng ý")
      expect(request.reload.rejection_reason).to eq("Không đồng ý")
    end
  end
end
