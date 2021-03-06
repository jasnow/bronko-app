class CommentsController < ApplicationController

  def show
    @comment = Comment.find(params['id'])
    @post = @comment.post
  end

  def create
    if params['parent_id']
      @comment = Comment.find(params['parent_id']).children.create(comment_params)
      @comment.post_id = params['post_id']
    else
      @post = Post.find(params['post_id'])
      @comment = @post.comments.build(comment_params)
    end

    @comment.user = current_user
    @comment.popmeter = Popmeter.create

    # +1 to parent comment
    unless @comment.root?
      parentComment = @comment.parent
      parentComment.sub_comments = parentComment.sub_comments + 1
      parentComment.save
    end

    # +1 post comment counter
    p = @comment.post
    p.sub_comments = p.sub_comments + 1
    p.save

    if @comment.valid?

      if @comment.save
        flash[:success] = 'Comment was successfully created.'
        redirect_to Post.find(@comment.post_id)
      else
        flash[:alert] = 'Error, comment not created.'
        # TODO: add more options here
        render @post
      end

    else
      flash[:alert] = "Form fields missing."
      render "new"
    end
  end

  private

    def comment_params
      params.require(:comment).permit(:text, :post_id, :parent_id)
    end

end
