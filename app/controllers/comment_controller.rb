class CommentController < ApplicationController

  def create
    if not can_post?
      render :text => 'error'
      return
    end
    post = Post.find_by_id(params[:post_id].to_i)
    if post.nil? or (not post.can_reply?)
      render :text => 'error'
      return
    end
    
    comment = Comment.create(
      :author => curr_user,
      :content => params[:content],
      :post => post,
      :create_at => Time.now
    )
    post.last_reply_user = curr_user
    post.last_reply_at = Time.now
    post.save
    
    find_at_users(comment)
    
    render :text => 'ok'
  end
  
  def index
    post = Post.find_by_id(params[:post_id].to_i)
    if post.nil?
      render :text => 'Post Not Found'
      return
    end
    page = params[:page].to_i
    page = page == 0 ? 1 : page
    @comments = post.comments.page(page).per_page(Comment::PerPage)
    @can_reply = can_reply?(post)
    
    render :layout => false
  end
  
  def destroy
    comment = Comment.find_by_id(params[:id].to_i)
    if comment.nil?
      render :text => 'error'
      return
    end
    if not comment.post.can_delete_by?(curr_user)
      render :text => 'error'
      return
    end
    comment.destroy
    
    render :text => 'ok'
  end
  
  private
  
  def find_at_users(comment)
    users = {}
    params[:content].scan(/@\S+ /).each do |user_name|
      user_name = user_name[1..(user_name.length - 2)]
      if users[user_name].nil?
        user = User.find_by_name(user_name)
        users[user_name] = (user.nil?) ? :NULL: user
      end
    end
    users.each do |name, user|
      if user != :NULL
        NotificationMessage.notify(user, curr_user, comment, NotificationMessage::TypeAt)
      end
    end
  end
  
end
