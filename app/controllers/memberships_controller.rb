class MembershipsController < ApplicationController
  before_action :set_variables
  before_action :set_membership, only: [:update, :destroy]
  before_action :check_view_auth, only: [:index, :create, :update]
  before_action :check_edit_auth, only: [:create, :update]
  before_action :check_destroy_auth, only: [:destroy]
  # GET /memberships
  # GET /memberships.json
  def index
  end


  # GET /memberships/new
  def new
    @membership = Membership.new
  end

  # GET /memberships/1/edit
  def edit
  end

  # POST /memberships
  # POST /memberships.json
  def create
    @new_membership = @group.memberships.new(membership_params)

    respond_to do |format|
      if @new_membership.save
        format.html { redirect_to group_memberships_path(@group), notice: 'Membership was successfully created.' }
        format.json { render :show, status: :created, location: group_memberships_path(@group) }
      else
        format.html { render :index }
        format.json { render json: @new_membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /memberships/1
  # PATCH/PUT /memberships/1.json
  def update
    respond_to do |format|
      if @membership.update(membership_params)
        format.html { redirect_to group_memberships_path(@group), notice: 'Membership was successfully updated.' }
        format.json { render :show, status: :ok, location: group_memberships_path(@group) }
      else
        format.html { render :index }
        format.json { render json: @membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /memberships/1
  # DELETE /memberships/1.json
  def destroy
    if @membership.user_id==current_user.id
      link = groups_path(@group)
    end
    @membership.destroy
    respond_to do |format|
      format.html { redirect_to link||group_memberships_url(@group), notice: 'Membership was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_membership
      @membership = Membership.find(params[:id])
    end

    def set_variables
      @group = Group.find(params[:group_id])
      @memberships = @group.memberships.includes(:user).order(approved: :asc).all
      members = @memberships.collect{|member| member.user_id}
      @users_array = User.where.not(id: members).collect{|user| [user.username,user.id]}
      @new_membership = @group.memberships.new
      @authorised_member= is_user_of_group?(@group)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def membership_params
      params.require(:membership).permit(:group_id, :user_id, :approved)
    end

    def check_view_auth
      unless @authorised_member || @group.members_public
        flash[:notice] = "Join the group to see more!"
        redirect_to @group
      end
    end

    def check_edit_auth
      unless @authorised_member
        flash[:notice] = "Join the group to make a change!"
        redirect_to group_memberships_path(@group)
      end
    end

    def check_destroy_auth
      unless @authorised_member || @membership.user_id==current_user.id
        flash[:notice] = "Join the group to make a change!"
        redirect_to group_memberships_path(@group)
      end
    end
end
