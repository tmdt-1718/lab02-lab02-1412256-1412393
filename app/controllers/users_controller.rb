class UsersController < ApplicationController
  before_action :authenticate, only: [:index, :show, :friendlist, :requestlist, :addfriend, :acceptfriend]
  before_action :get_user, only: [:show]

    def new
        add_breadcrumb "Register", new_user_path
    end

    def create
        user = User.find_by(email: user_params[:email])
        if user
            flash[:error] = "Cannot register new account."
            render :new
        else
            user = User.create(user_params)
            if user
                flash[:success] = "Register successfully."
                redirect_to login_path
            else
                flash[:error] = "Cannot register new account."
                render :new
            end
        end
    end

    def index
        @users=User.all
        add_breadcrumb "Users", users_path
    end

    def show
        add_breadcrumb "Users", users_path
        add_breadcrumb @user.name, user_path(@user.id)
        @cur_user = User.find_by(id: session[:current_user_id])
        @friend = @cur_user.friendships.find_by(friend_email: @user.email)
        @add = @cur_user.addingfriends.find_by(friend_email: @user.email)
        @accept = @cur_user.accepttingfriends.find_by(friend_email: @user.email)
        #@user.view=1
        #@user.save
        # @user = User.find(params[:id])
        #@user.update(view: @user.view+1)
        #@user.save
    end

    def friendlist
        @cur_user = User.find_by(id: session[:current_user_id])
        @users=User.all
        #@friendlist=@cur_user.friendships
        #@users = Array.new(100, User)
        #@users.push(@cur_user)
        add_breadcrumb "Users", users_path
        add_breadcrumb "Friends", friendlist_path

    end

    def requestlist

      @cur_user = User.find_by(id: session[:current_user_id])
      @users=User.all
      #@friendlist=@cur_user.friendships
      #@users = Array.new(100, User)
      #@users.push(@cur_user)
      add_breadcrumb "Users", users_path
      add_breadcrumb "Friends request", requestlist_path
    end

    def addfriend
        @cur_user = User.find_by(id: session[:current_user_id])
        @add = Addingfriend.new(user_id: session[:current_user_id], friend_id: params[:post][:friend_id], friend_name: params[:post][:friend_name], friend_email: params[:post][:friend_email] )
          if @add.save
              @accept= Accepttingfriend.new(user_id: params[:post][:friend_id], friend_id:   @cur_user.id, friend_name:   @cur_user.name, friend_email:   @cur_user.email )
                if @accept.save
                  flash[:success] = "Add successfully."
                  redirect_to user_path(params[:post][:friend_id])
                end
          end
    end

    def acceptfriend
        @add = Addingfriend.find_by(user_id: params[:post][:friend_id], friend_id: session[:current_user_id])

        @add.destroy!
        @accept = Accepttingfriend.find_by(user_id: session[:current_user_id], friend_id: params[:post][:friend_id])
        @accept.destroy!
        @cur_user = User.find_by(id: session[:current_user_id])
        @friend1 = Friendship.new(user_id: session[:current_user_id], friend_id: params[:post][:friend_id], friend_name: params[:post][:friend_name], friend_email: params[:post][:friend_email] )
          if @friend1.save
              @friend2= Friendship.new(user_id: params[:post][:friend_id], friend_id:   @cur_user.id, friend_name:   @cur_user.name, friend_email:   @cur_user.email )
                if @friend2.save
                  flash[:success] = "Accept successfully."
                  redirect_to user_path(params[:post][:friend_id])
                end
          end
    end
    private

    def get_user
      @user = User.find(params[:id])
    end

    def user_params
        params.require(:user).permit(:name, :email, :password)
    end
end
