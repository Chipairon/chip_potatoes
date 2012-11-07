require 'spec_helper'

describe MoviesController do
  describe 'find movies with same director' do
    before do
      movie = mock(id: 3, director: 'hum')
      Movie.should_receive(:find).and_return(movie)
      fake_results = [
        double('Movie', director: 'hum', title: 'Movie', rating: 'R'), 
        double('Movie', director: 'hum', title: 'Movie', rating: 'R')]
      movie.should_receive(:find_with_same_director).
        and_return(fake_results)
    end

    it 'should render the similar movies template' do
      post :same_director, { id: 3 }
      controller.should render_template("same_director")
    end

    it 'should call a model method to search the movies' do
      get :same_director, {id: 3}
    end
  end

  describe 'sad path for movies with same director' do
    before do
      movie = mock(id: 3, director: 'hum', title: 'Title')
      Movie.should_receive(:find).and_return(movie)
      movie.should_receive(:find_with_same_director).
        and_return(nil)
    end

    it 'should redirect to root if no similar movies are found' do
      get :same_director, {id: 3}
      response.should redirect_to(movies_path)
    end
  end

  describe 'CRUD operations' do
    it 'should create new movie' do
      Movie.should_receive(:create!).and_return(mock(title: 'Movie'))
      get :create, {movie: double('Movie')}
    end
    it 'should destroy an existing movie' do
      movie = mock(id: 3, director: 'hum', title: 'Title')
      Movie.should_receive(:find).and_return(movie)

      movie.should_receive(:destroy).and_return()
      delete :destroy, {id: 3}
    end
  end
end

