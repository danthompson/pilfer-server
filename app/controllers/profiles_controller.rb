class ProfilesController < ApplicationController
  before_filter :fetch_app

  helper_method :profile_value_for_sort

  # GET /profiles
  # GET /profiles.json
  def index
    @profiles = @app.profiles

    respond_to do |format|
      format.html # index.html.erb
      # format.json { render json: @profiles }
    end
  end

  # GET /profiles/1
  # GET /profiles/1.json
  def show
    @profile = @app.profiles.find(params[:id])

    @mode    = params[:mode]
    @minimum = (params[:minimum] || 5).to_i * 1000
    @sort    = params[:sort]
    @summary = params[:summary]

    @sorted_profile = sorted_profile(@profile, @sort, @summary)

    respond_to do |format|
      format.html # show.html.erb
      # format.json { render json: @profile }
    end
  end

  # # GET /profiles/new
  # # GET /profiles/new.json
  # def new
  #   @profile = @app.profiles.build
  #
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     # format.json { render json: @profile }
  #   end
  # end
  #
  # # GET /profiles/1/edit
  # def edit
  #   @profile = @app.profiles.find(params[:id])
  # end
  #
  # # POST /profiles
  # # POST /profiles.json
  # def create
  #   @profile = @app.profiles.build(params[:profile])
  #
  #   respond_to do |format|
  #     if @profile.save
  #       format.html { redirect_to @profile, notice: 'Profile was successfully created.' }
  #       # format.json { render json: @profile, status: :created, location: @profile }
  #     else
  #       format.html { render action: "new" }
  #       # format.json { render json: @profile.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end
  #
  # # PUT /profiles/1
  # # PUT /profiles/1.json
  # def update
  #   @profile = @app.profiles.find(params[:id])
  #
  #   respond_to do |format|
  #     if @profile.update_attributes(params[:profile])
  #       format.html { redirect_to @profile, notice: 'Profile was successfully updated.' }
  #       # format.json { head :no_content }
  #     else
  #       format.html { render action: "edit" }
  #       # format.json { render json: @profile.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /profiles/1
  # DELETE /profiles/1.json
  def destroy
    @profile = @app.profiles.find(params[:id])
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to profiles_url }
      # format.json { head :no_content }
    end
  end

  private
  def fetch_app
    @app = App.find(params[:app_id])
  end


  def profile_value_for_sort(file_profile, sort, summary)
    if summary == 'exclusive'
      if sort == 'idle'
        idle = file_profile['exclusive'] - file_profile['exclusive_cpu']
        idle = 0 if idle < 0
      elsif sort == 'cpu'
        cpu = file_profile['exclusive_cpu']
      else
        wall = file_profile['exclusive']
      end
    else
      if sort == 'idle'
        idle = file_profile['total'] - file_profile['total_cpu']
        idle = 0 if idle < 0
      elsif sort == 'cpu'
        cpu = file_profile['total_cpu']
      else
        wall = file_profile['total']
      end
    end
  end

  def sorted_profile(profile, sort, summary)
    profile.payload['files'].sort_by do |filename, file_profile|
      profile_value_for_sort(file_profile, sort, summary)
    end.reverse
  end
end
