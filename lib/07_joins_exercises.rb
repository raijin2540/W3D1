# == Schema Information
#
# Table name: actors
#
#  id          :integer      not null, primary key
#  name        :string
#
# Table name: movies
#
#  id          :integer      not null, primary key
#  title       :string
#  yr          :integer
#  score       :float
#  votes       :integer
#  director_id :integer
#
# Table name: castings
#
#  movie_id    :integer      not null, primary key
#  actor_id    :integer      not null, primary key
#  ord         :integer

require_relative './sqlzoo.rb'

def example_join
  execute(<<-SQL)
    SELECT
      *
    FROM
      movies
    JOIN
      castings ON movies.id = castings.movie_id
    JOIN
      actors ON castings.actor_id = actors.id
    WHERE
      actors.name = 'Sean Connery'
  SQL
end

def ford_films
  # List the films in which 'Harrison Ford' has appeared.
  execute(<<-SQL)
  SELECT
    title
  FROM
    movies
  JOIN
    castings ON movies.id = castings.movie_id
  JOIN
    actors ON castings.actor_id = actors.id
  WHERE
    actors.name = 'Harrison Ford'

  SQL
end

def ford_supporting_films
  # List the films where 'Harrison Ford' has appeared - but not in the star
  # role. [Note: the ord field of casting gives the position of the actor. If
  # ord=1 then this actor is in the starring role]
  execute(<<-SQL)
  SELECT
    title
  FROM
    movies
  JOIN
    castings ON movies.id = castings.movie_id
  JOIN
    actors ON castings.actor_id = actors.id
  WHERE
    actors.name = 'Harrison Ford' AND castings.ord != 1

  SQL
end

def films_and_stars_from_sixty_two
  # List the title and leading star of every 1962 film.
  execute(<<-SQL)
  SELECT
    movies.title, actors.name
  FROM
    castings
  JOIN
    movies ON movies.id = castings.movie_id
  JOIN
    actors ON actors.id = castings.actor_id
  WHERE
    castings.ord = 1 AND movies.yr = 1962
  SQL
end

def travoltas_busiest_years
  # Which were the busiest years for 'John Travolta'? Show the year and the
  # number of movies he made for any year in which he made at least 2 movies.
  execute(<<-SQL)
    SELECT
      movies.yr, COUNT(*) -- not sure why * is used, works with movies.yr
    FROM
      castings
      JOIN
        movies ON movies.id = castings.movie_id
      JOIN
        actors ON actors.id = castings.actor_id
      WHERE
        actors.name = 'John Travolta'
      GROUP BY
        movies.yr
      HAVING
        COUNT(*) >= 2
  SQL
end

def andrews_films_and_leads
  # List the film title and the leading actor for all of the films 'Julie
  # Andrews' played in.
  execute(<<-SQL)
    SELECT
      movies.title, actors.name
    FROM
      castings
      JOIN
        movies ON movies.id = castings.movie_id
      JOIN
        actors ON actors.id = castings.actor_id
    WHERE
      castings.movie_id IN (
        SELECT
          castings.movie_id
        FROM
          castings
          JOIN
            movies ON movies.id = castings.movie_id
          JOIN
            actors ON actors.id = castings.actor_id
        WHERE
          castings.actor_id = (
            ----- subquery for her actorid
            SELECT
              id
            FROM
              actors
            WHERE
              name = 'Julie Andrews'
          )
      ) AND castings.ord = 1
  SQL
end

def prolific_actors
  # Obtain a list in alphabetical order of actors who've had at least 15
  # starring roles.
  execute(<<-SQL)
    SELECT
      actors.name
    FROM
      actors
    WHERE
      actors.id IN (
        SELECT
          castings.actor_id
        FROM
          castings
        GROUP BY 
          -- it's possible to group by multiple columns.
          -- https://stackoverflow.com/questions/2421388/using-group-by-on-multiple-columns
          castings.ord, castings.actor_id
        HAVING
          count(*) >= 15 AND castings.ord = 1
        )
        ORDER BY actors.name
  SQL
end

def films_by_cast_size
  # List the films released in the year 1978 ordered by the number of actors
  # in the cast (descending), then by title (ascending).
  execute(<<-SQL)
    SELECT
      movies.title, COUNT(*)
    FROM
      castings
    JOIN
      movies ON castings.movie_id = movies.id
    GROUP BY
      castings.movie_id, movies.yr, movies.title -- number of castings = number of actors
    HAVING
      movies.yr = 1978
    ORDER BY
      COUNT(*) DESC, movies.title ASC  
  SQL
end

def colleagues_of_garfunkel
  # List all the people who have played alongside 'Art Garfunkel'.
  execute(<<-SQL)
    -- Use a join to get all castings/actors in any of those movies.
    SELECT
      actors.name
    FROM
      castings
    JOIN
      actors ON castings.actor_id = actors.id
    WHERE
      actors.name != 'Art Garfunkel' AND castings.movie_id IN (
      -- Get all movies (movie ids) for films Art Garfunkel played in.
      SELECT 
        castings.movie_id
      FROM
        castings
      WHERE
        castings.actor_id = (
          -- get actor id
          SELECT
            actors.id
          FROM
            actors
          WHERE
            actors.name = 'Art Garfunkel'
        )
      )
  SQL
end
