class MoviesController < ApplicationController
  helper_method :cookies
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.ratings
    if cookies[:selected_ratings].nil?
      cookies[:selected_ratings] = @all_ratings
    elsif cookies[:selected_ratings].include? '&'
      cookies[:selected_ratings] = cookies[:selected_ratings].split('&')
    end
    if params[:ratings].nil? == false
      cookies[:selected_ratings] = params[:ratings].keys
    end
    debugger
    @selected_ratings = cookies[:selected_ratings]
    @order_by = params[:order]
    case params[:order]
    when 'title'
      @movies = Movie.all(:order => 'title')
    when 'release_date'
      @movies = Movie.all(:order => 'release_date')
    else
      @movies = Movie.all
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
