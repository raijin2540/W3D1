# == Schema Information
#
# Table name: stops
#
#  id          :integer      not null, primary key
#  name        :string
#
# Table name: routes
#
#  num         :string       not null, primary key
#  company     :string       not null, primary key
#  pos         :integer      not null, primary key
#  stop_id     :integer

require_relative './sqlzoo.rb'

def num_stops
  # How many stops are in the database?
  execute(<<-SQL)
    SELECT
      COUNT(*)
    FROM
      stops
  SQL
end

def craiglockhart_id
  # Find the id value for the stop 'Craiglockhart'.
  execute(<<-SQL)
    SELECT
      id
    FROM
      stops
    WHERE
      name = 'Craiglockhart'
  SQL
end

def lrt_stops
  # Give the id and the name for the stops on the '4' 'LRT' service.
  execute(<<-SQL)
    SELECT
      id, name
    FROM
      stops
    JOIN
      routes ON routes.stop_id = stops.id
    WHERE
      routes.num = '4' AND routes.company = 'LRT'
  SQL
end

def connecting_routes
  # Consider the following query:
  #
  # SELECT
  #   company,
  #   num,
  #   COUNT(*)
  # FROM
  #   routes
  # WHERE
  #   stop_id = 149 OR stop_id = 53
  # GROUP BY
  #   company, num
  #
  # The query gives the number of routes that visit either London Road
  # (149) or Craiglockhart (53). Run the query and notice the two services
  # that link these stops have a count of 2. Add a HAVING clause to restrict
  # the output to these two routes.
  execute(<<-SQL)
    SELECT
      company,
      num,
      COUNT(*)
    FROM
      routes
    WHERE
      stop_id = 149 OR stop_id = 53
    GROUP BY
      company, num
    HAVING
      COUNT(*) = 2
  SQL
end

def cl_to_lr
  # Consider the query:
  #
  # SELECT
  #   a.company,
  #   a.num,
  #   a.stop_id,
  #   b.stop_id
  # FROM
  #   routes a
  # JOIN
  #   routes b ON (a.company = b.company AND a.num = b.num)
  # WHERE
  #   a.stop_id = 53
  #
  # Observe that b.stop_id gives all the places you can get to from
  # Craiglockhart, without changing routes. Change the query so that it
  # shows the services from Craiglockhart to London Road.
  execute(<<-SQL)
    SELECT
      a.company,
      a.num,
      a.stop_id,
      b.stop_id
    FROM
      routes a
    JOIN
      routes b ON (a.company = b.company AND a.num = b.num)
    WHERE
      a.stop_id = 53 AND b.stop_id = 149
  SQL
end

def cl_to_lr_by_name
  # Consider the query:
  #
  # SELECT
  #   a.company,
  #   a.num,
  #   stopa.name,
  #   stopb.name
  # FROM
  #   routes a
  # JOIN
  #   routes b ON (a.company = b.company AND a.num = b.num)
  # JOIN
  #   stops stopa ON (a.stop_id = stopa.id)
  # JOIN
  #   stops stopb ON (b.stop_id = stopb.id)
  # WHERE
  #   stopa.name = 'Craiglockhart'
  #
  # The query shown is similar to the previous one, however by joining two
  # copies of the stops table we can refer to stops by name rather than by
  # number. Change the query so that the services between 'Craiglockhart' and
  # 'London Road' are shown.
  execute(<<-SQL)
    SELECT
      a.company,
      a.num,
      stopa.name,
      stopb.name
    FROM
      routes a
    JOIN
      routes b ON (a.company = b.company AND a.num = b.num)
    JOIN
      stops stopa ON (a.stop_id = stopa.id)
    JOIN
      stops stopb ON (b.stop_id = stopb.id)
    WHERE
      stopa.name = 'Craiglockhart' AND stopb.name = 'London Road'
  SQL
end

def haymarket_and_leith
  # Give the company and num of the services that connect stops
  # 115 and 137 ('Haymarket' and 'Leith')
  execute(<<-SQL)
    SELECT DISTINCT
      a.company,
      a.num
      -- wtf is num of services.
    FROM
      routes a
    JOIN
      -- compare to make sure we're looking at the same company and bus line (num).
      routes b ON (a.company = b.company AND a.num = b.num)
    JOIN
      stops stopa ON (a.stop_id = stopa.id)
    JOIN
      stops stopb ON (b.stop_id = stopb.id)
    WHERE
      stopa.name = 'Haymarket' AND stopb.name = 'Leith'
  SQL
end

def craiglockhart_and_tollcross
  # Give the company and num of the services that connect stops
  # 'Craiglockhart' and 'Tollcross'
  execute(<<-SQL)
    SELECT
      end_route.company, end_route.num
    FROM
      routes start_route
    JOIN
      routes end_route ON start_route.num = end_route.num AND start_route.company = end_route.company
    JOIN
      stops start_stop ON start_route.stop_id = start_stop.id
    JOIN
      stops end_stop ON end_route.stop_id = end_stop.id
    WHERE
      start_stop.name = 'Craiglockhart' AND end_stop.name = 'Tollcross'
  SQL
end

def start_at_craiglockhart
  # Give a distinct list of the stops that can be reached from 'Craiglockhart'
  # by taking one bus, including 'Craiglockhart' itself. Include the stop name,
  # as well as the company and bus no. of the relevant service.
  execute(<<-SQL)
    SELECT
      end_stop.name, end_route.company, end_route.num
    FROM
      routes as start_route
    JOIN
      -- Again, make sure we're looking at the same company and bus line.
      -- Routes is kind of a confusing name, this is one "point/stop" on a route.
      -- 'Stops' here refer to the actual, physical bus stop.  
      routes as end_route ON start_route.num = end_route.num AND start_route.company = end_route.company
    -- The following two joins are only used to get the name of the physical stop.
    -- If we only' needed the stop id, we already had that information from route.
    JOIN
      stops start_stop ON start_stop.id = start_route.stop_id
    JOIN
      stops end_stop ON end_stop.id = end_route.stop_id
    -- Now select, the end_stops where the start stop name = 'Craiglockhart'
    WHERE
      start_stop.name = 'Craiglockhart'
  SQL
end

def craiglockhart_to_sighthill
  # Find the routes involving two buses that can go from Craiglockhart to
  # Sighthill. Show the bus no. and company for the first bus, the name of the
  # stop for the transfer, and the bus no. and company for the second bus.
  execute(<<-SQL)
    SELECT DISTINCT
    route_1_start.num, route_1_start.company, transfer_stop.name, route_2_start.num, route_2_start.company  
    -- Find two buses, one starting at Craiglockhart, and another stopping at Sighthill.
    FROM
      routes route_1_start
    JOIN
    -- All joins with stops are only for getting names
      stops start ON route_1_start.stop_id = start.id
    JOIN
      -- Filter records where company and num are the same for different stops (aka represents a busline).
      -- Alias as start_route and transfer_route
      routes route_1_end ON route_1_start.company = route_1_end.company AND route_1_start.num = route_1_end.num
    JOIN
      stops transfer_stop ON transfer_stop.id = route_1_end.stop_id
    JOIN
      -- Filter routes that start at the stop where the first route ended.
      routes route_2_start ON route_2_start.stop_id = route_1_end.stop_id
    JOIN
    -- Again, filter records that represents a buslines (same bus stopping at different stops)
      routes route_2_end ON route_2_start.company = route_2_end.company AND route_2_end.num = route_2_start.num
    JOIN
      -- yet again, for name.
      stops destination ON destination.id = route_2_end.stop_id
    WHERE
      start.name = 'Craiglockhart' AND destination.name = 'Sighthill'
  SQL
end
