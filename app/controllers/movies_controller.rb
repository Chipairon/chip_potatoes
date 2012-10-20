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
    elsif cookies[:selected_ratings].include? '&' #if the cookie is serialized, the array [1,2] goes to "1&2"
      cookies[:selected_ratings] = cookies[:selected_ratings].split('&')
    elsif cookies[:selected_ratings].class == String #if just one rating, is a string, but the view expects array
      cookies[:selected_ratings] = [cookies[:selected_ratings]]
    end
    unless params[:ratings].nil?
      cookies[:selected_ratings] = params[:ratings].keys
    end
    @selected_ratings = cookies[:selected_ratings]

    cookies[:order] = params[:order] unless params[:order].nil?
    @order_by = cookies[:order]

    #constructing the SQL, keeping it separated from the above code is not necessary, but more readable
    if @order_by.nil?
      @movies = Movie
    else
      @movies = Movie.order(@order_by)
    end
    unless @selected_ratings.nil?
      @movies = @movies.where(rating: @selected_ratings)
    end

    # Keeping the app RESTful:
    # When clicking on sort column, the params for the ratings filter are not carried in the url
    # and viceversa. We want to carry in the url all parameters affecting the page,
    # so if clicking sort -> look for ratings filter and add them to url via redirect
    #    if clicking refresh filter -> look for sorting and add it to url via redirect.
    params_to_redirect = {}
    if params[:order]
      params_to_redirect[:order] = params[:order]
    elsif params[:order].nil? and @order_by.nil? == false
      params_to_redirect[:order] = @order_by
    end
    if params[:ratings]
      params_to_redirect[:ratings] = params[:ratings]
    elsif params[:ratings].nil? and @selected_ratings.nil? == false
      params_to_redirect[:ratings] = {}
      @selected_ratings.each { |k| params_to_redirect[:ratings][k] = 1 }
    end
    if params_to_redirect.any? and 
      (params_to_redirect[:order] != params[:order] or 
       params_to_redirect[:ratings] != params[:ratings])
      redirect_to movies_path(params_to_redirect)
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
