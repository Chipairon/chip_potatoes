# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    Movie.create movie
  end
end

Then /I see movies ordered by "(.*)" column/ do |sorting_column|
  number_of_sorting_column = 1 # capybara selector results start at 1 instead of 0 O.o
  all("#movies thead tr th").each do |header_column|
    if header_column.text == sorting_column
      break
    end
    number_of_sorting_column += 1
  end
  aux = all("#movies tbody tr td[#{number_of_sorting_column}]").each_cons(2).all? { |a, b| (a.text <=> b.text) < 1 } 
  assert_equal aux, true
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  rating_list.split(',').each do |rating|
    rating = rating.strip
    if uncheck 
     step "I uncheck \"ratings_#{rating}\""
    else
      step "I check \"ratings_#{rating}\""
    end
  end
end

Given /I (un)?check all ratings/ do |uncheck|
  if uncheck
    step "I uncheck the following ratings: #{Movie.all_ratings.join(',')}"
  else
    step "I check the following ratings: #{Movie.all_ratings.join(',')}"
  end
end

Then /I (don't )?see movies with ratings: (.*)/ do |not_exists, rating_list|
  well_formed_ratings = rating_list.split(',')
  well_formed_ratings.map! { |rating| rating = rating.strip }
  msg_if_failure = all("#movies tbody tr").map{ |m| m.text.gsub(/\n/,"###") }.join("\n")
  unless not_exists 
    count_movies_at_db = Movie.find_all_by_rating(well_formed_ratings).count
    assert_equal count_movies_at_db, all("#movies tbody tr").count, msg_if_failure
  end
  all("#movies tbody tr td[2]").each do |rating_field|
    if not_exists 
      assert_equal(well_formed_ratings.include?(rating_field.text), false, msg_if_failure)
    else
      assert_equal(well_formed_ratings.include?(rating_field.text), true, msg_if_failure)
    end
  end
end

Then /I see (.*) movies/ do |what_to_see|  # could be "all" or "no"
  msg_if_failure = all("#movies tbody tr").map{ |m| m.text.gsub(/\n/,"###") }.join("\n")
  if what_to_see == "all"
  #  assert_equal Movie.all.count, all("#movies tbody tr").count, msg_if_failure
  end
  if what_to_see == "no"
    # no selection does result in selecting all, so instead of the commented block
    # we call to this very step with "all":
    # assert_equal(all("movies tbody tr").count == 0, true)
    step "I see all movies"
  end
  assert_equal Movie.all.count, all("#movies tbody tr").count, msg_if_failure
end

Then /the director of "(.*)" should be "(.*)"/ do |movie_title, director|
  text = find("#details li[3]").text
  text = text.gsub(/\n/, " ").strip
  assert_equal text, "Director: #{director}"
  assert_equal Movie.find_by_title(movie_title).director, director
end
