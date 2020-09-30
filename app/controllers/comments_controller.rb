# typed: true
# frozen_string_literal: true

class CommentsController < ApplicationController
  class IndexParams < T::Struct
    const :authority_id, T.nilable(String)
    const :page, T.nilable(Integer)
  end

  def index
    typed_params = TypedParams[IndexParams].new.extract!(params)
    @description = +"Recent comments"
    authority_id = typed_params.authority_id
    if authority_id
      authority = Authority.find_short_name_encoded!(authority_id)
      comments_to_display = authority.comments
      @description << " on applications from #{authority.full_name_and_state}"
    else
      comments_to_display = Comment.all
    end

    @comments = comments_to_display.confirmed.order("confirmed_at DESC").paginate page: typed_params.page
    @rss = comments_url(typed_params.serialize.merge(format: "rss", page: nil))

    respond_to do |format|
      format.html
      format.rss
      format.js { render content_type: Mime[:json] }
    end
  end

  class ConfirmedParams < T::Struct
    const :id, String
  end

  def confirmed
    typed_params = TypedParams[ConfirmedParams].new.extract!(params)
    @comment = Comment.find_by(confirm_id: typed_params.id)
    if @comment
      @comment.confirm!
      # rubocop:disable Rails/OutputSafety
      redirect_to @comment.application, notice: render_to_string(partial: "confirmed", locals: { comment: @comment }).html_safe
      # rubocop:enable Rails/OutputSafety
    else
      render plain: "", status: :not_found
    end
  end

  class PerWeekParams < T::Struct
    const :authority_id, String
  end

  def per_week
    typed_params = TypedParams[PerWeekParams].new.extract!(params)
    authority = Authority.find_short_name_encoded!(typed_params.authority_id)

    respond_to do |format|
      format.json { render json: authority.comments_per_week }
    end
  end

  class WriteitReplyHookParams < T::Struct
    const :message_id, T.nilable(String)
  end

  def writeit_reply_webhook
    typed_params = TypedParams[WriteitReplyHookParams].new.extract!(params)
    message_id = typed_params.message_id
    if message_id.nil?
      render plain: "No message_id", status: :not_found
      return
    end

    comment = Comment.find_by(writeit_message_id: message_id[%r{/api/v1/message/(\d*)/}, 1])
    if comment.nil?
      render plain: "Comment not found.", status: :not_found
      return
    end

    comment.create_replies_from_writeit!
    render plain: "Processing inbound message.", status: :ok
  end
end
