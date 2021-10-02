# typed: ignore
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

    @comments = comments_to_display.confirmed.order("confirmed_at DESC").page(typed_params.page)
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
      redirect_to @comment.application, notice: render_to_string(partial: "confirmed", locals: { comment: @comment })
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
end
