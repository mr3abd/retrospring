class Sleipnir::Entities::ReportCommentEntity < Sleipnir::Entities::BaseEntity
  expose :id, format_with: :strid

  expose :content, as: :comment

  expose :user, with: Sleipnir::Entities::UserSlimEntity

  expose :created_at, format_with: :nanotime
end