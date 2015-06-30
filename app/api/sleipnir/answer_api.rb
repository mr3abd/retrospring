class Sleipnir::AnswerAPI < Sleipnir::MountAPI
  include Sleipnir::Concerns

  helpers Sleipnir::Helpers

  namespace :answer do
    desc "Given answer's content"
    # oauth2 'public'
    throttle hourly: 720
    params do
      requires :test
    end
    get "/:id", as: :answer_api do
      answer = Answer.find params["id"]
      if answer.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_ANSWER_NOT_FOUND"})
      end
      represent answer, with: Sleipnir::Entities::AnswerEntity
    end

    desc "Delete given answer"
    oauth2 'write'
    throttle hourly: 360
    delete "/:id", as: :delete_answer_api do
      answer = Answer.find(params[:id])

      if answer.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_ANSWER_NOT_FOUND"})
      end

      unless (current_user == answer.user) or (privileged? answer.user)
        status 403
        return present({success: false, code: 403, result: "ERR_USER_NO_PRIV"})
      end

      if answer.user == current_user
        Inbox.create!(user: answer.user, question: answer.question, new: true)
      end
      answer.destroy

      status 204
      return
    end

    desc "Given answer's comments"
    # oauth2 'public'
    throttle hourly: 720
    get "/:id/comments", as: :comment_api do
      collection = since_id Comment, "answer_id = ?", [params[:id]]
      represent_collection collection, with: Sleipnir::Entities::CommentsEntity
    end

    desc "Comment on given answer"
    oauth2 'write'
    throttle hourly: 720
    params do
      requires :comment, type: String
    end
    post "/:id/comments", as: :write_comment_api do
      answer = Answer.find params[:id]
      if answer.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_USER_NOT_FOUND"})
      end

      current_user.comment(answer, params[:comment], current_application)
      status 201
      present({success: true, code: 201, result: "SUCCESS_COMMENT"})
    end

    desc "Delete comment"
    oauth2 'write'
    throttle hourly: 360
    delete "/:id/comments/:comment_id", as: :delete_comment_api do
      comment = Comment.find params[:comment_id]
      if comment.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_COMMENT_NOT_FOUND"})
      end

      unless (current_user == answer.user) or (privileged? answer.user)
        status 403
        return present({success: false, code: 403, result: "ERR_USER_NO_PRIV"})
      end

      comment.answer.decrement! :comment_count
      comment.destroy

      status 204
      return
    end

    desc "Subscribe to an answer"
    oauth2 'write'
    throttle hourly: 720
    post "/:id/subscribe", as: :new_subscription_api do
      answer = Answer.find(params[:id])
      if answer
        status 404
        return present({success: false, code: 404, result: "ERR_ANSWER_NOT_FOUND"})
      end

      if Subscription.subscribe(current_user, answer).nil?
        status 412
        return present({success: false, code: 412, result: "ERR_ALREADY_SUBSCRIBED"})
      else
        status 201
        return present({success: true, code: 201, result: "SUBSCRIBED"})
      end
    end

    desc "Unsubscribe from an answer"
    oauth2 'write'
    throttle hourly: 720
    delete "/:id/subscribe", as: :delete_subscription_api do
      answer = Answer.find(params[:id])
      if answer
        status 404
        return present({success: false, code: 404, result: "ERR_ANSWER_NOT_FOUND"})
      end

      if Subscription.unsubscribe(current_user, answer).nil?
        status 412
        return present({success: false, code: 412, result: "ERR_NOT_SUBSCRIBED"})
      else
        status 204
        return
      end
    end

    desc "Smile an answer"
    oauth2 'write'
    throttle hourly: 720
    post "/:id/smile", as: :smile_api do
      # TODO
    end

    desc "View answer smiles"
    # oauth2 'write'
    throttle hourly: 720
    get "/:id/smile", as: :view_smile_api do
      # TODO
    end

    desc "Frown an answer"
    oauth2 'write'
    throttle hourly: 720
    delete "/:id/smile", as: :frown_api do
      # TODO
    end

    desc "Smile a comment"
    oauth2 'write'
    throttle hourly: 720
    post "/:id/comment/:comment_id", as: :comment_smile_api do
      # TODO
    end

    desc "View comment smiles"
    # oauth2 'write'
    throttle hourly: 720
    get "/:id/comment/:comment_id", as: :view_comment_smile_api do
      # TODO
    end

    desc "Frown a comment"
    oauth2 'write'
    throttle hourly: 720
    delete "/:id/comment/:comment_id", as: :comment_frown_api do
      # TODO
    end
  end
end