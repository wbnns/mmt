class VariablesController < ApplicationController
  def show
  end

  def create
    variable_draft = VariableDraft.find(params[:id])

    ingested = cmr_client.ingest_variable(variable_draft.draft.to_json, variable_draft.provider_id, variable_draft.native_id, token)

    if ingested.success?
      # get information for publication email notification before draft is deleted
      Rails.logger.info("Audit Log: Variable Draft #{variable_draft.entry_title} was published by #{current_user.urs_uid} in provider: #{current_user.provider_id}")
      short_name = variable_draft.short_name

      # Delete draft
      variable_draft.destroy

      concept_id = ingested.body['concept-id']
      revision_id = ingested.body['revision-id']

      # instantiate and deliver notification email
      DraftMailer.variable_draft_published_notification(get_user_info, concept_id, revision_id, short_name).deliver_now

      redirect_to variable_path(concept_id, revision_id: revision_id), flash: { success: I18n.t('controllers.variables.create.flash.success') }
    else
      # Log error message
      Rails.logger.error("Ingest Variable Metadata Error: #{ingested.inspect}")
      Rails.logger.info("User #{current_user.urs_uid} attempted to ingest variable draft #{variable_draft.entry_title} in provider #{current_user.provider_id} but encountered an error.")
      @ingest_errors = generate_ingest_errors(ingested)

      redirect_to variable_draft_path(variable_draft, flash: { error: I18n.t('controllers.variables.create.flash.error') })
    end
  end
end