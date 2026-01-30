# frozen_string_literal: true

# TASK-023: Interactions Controller
# Manages care history / interaction notes for contacts
class InteractionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contact
  before_action :set_interaction, only: [:destroy]

  # POST /contacts/:contact_id/interactions
  def create
    @interaction = @contact.interactions.build(interaction_params)
    @interaction.user = current_user

    # Check if user can edit the contact (Sale/CSKH has this)
    authorize! :edit, @contact

    if @interaction.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @contact, notice: t(".success") }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :create_error, status: :unprocessable_content }
        format.html { redirect_to @contact, alert: @interaction.errors.full_messages.join(", ") }
      end
    end
  end

  # DELETE /contacts/:contact_id/interactions/:id
  def destroy
    # Check if user can edit the contact
    authorize! :edit, @contact

    @interaction.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @contact, notice: t(".success") }
    end
  end

  private

  def set_contact
    @contact = Contact.find(params[:contact_id])
  end

  def set_interaction
    @interaction = @contact.interactions.find(params[:id])
  end

  def interaction_params
    params.expect(interaction: %i[content interaction_method scheduled_at])
  end
end
