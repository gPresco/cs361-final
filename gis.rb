#!/usr/bin/env ruby

class Track
  def initialize(segments, name=nil)
    @name = name
    segment_objects = []
    segments.each do |s|
      segment_objects.append(TrackSegment.new(s))
    end
    # set segments to segment_objects
    @segments = segment_objects
  end

  def get_track_json
    track_json = '{'
    track_json += '"type": "Feature", '
    track_json += build_properties_json if @name != nil
    track_json += build_geometry_json
    track_json += '}}'

    track_json
  end

  def build_properties_json
    properties_json = '"properties": {'
    properties_json += '"title": "' + @name + '"'
    properties_json += '},'

    properties_json
  end

  def build_geometry_json
    geometry_json = '"geometry": {'
    geometry_json += '"type": "MultiLineString",'
    geometry_json += '"coordinates": ['
    geometry_json += build_coordinates_json
    geometry_json += ']}}'

    geometry_json
  end

  def build_coordinates_json
    coordinates_json = @segments.map.with_index do |segment, index|
      coordinate_group = '[' + build_segment_coordinates(segment)
      coordinate_group += ']' unless index == @segments.length - 1
      coordinate_group
    end.join(',')

    coordinates_json
  end

  def build_segment_coordinates(segment)
    segment_coordinates = segment.coordinates.map do |c|
      coordinate = '[' + "#{c.lon},#{c.lat}"
      coordinate += ",#{c.ele}" if c.ele != nil
      coordinate += ']'
    end.join(',')

    segment_coordinates
  end

    
end

class TrackSegment
  attr_reader :coordinates
  def initialize(coordinates)
    @coordinates = coordinates
  end
end

class Point

  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele=nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end
end

class Waypoint



attr_reader :lat, :lon, :ele, :name, :type

  def initialize(lon, lat, ele=nil, name=nil, type=nil)
    @lat = lat
    @lon = lon
    @ele = ele
    @name = name
    @type = type
  end

  def get_waypoint_json(indent=0)
    j = '{"type": "Feature",'
    # if name is not nil or type is not nil
    j += '"geometry": {"type": "Point","coordinates": '
    j += "[#{@lon},#{@lat}"
    if ele != nil
      j += ",#{@ele}"
    end
    j += ']},'
    if name != nil or type != nil
      j += '"properties": {'
      if name != nil
        j += '"title": "' + @name + '"'
      end
      if type != nil  # if type is not nil
        if name != nil
          j += ','
        end
        j += '"icon": "' + @type + '"'  # type is the icon
      end
      j += '}'
    end
    j += "}"
    return j
  end
end

class World
def initialize(name, things)
  @name = name
  @features = things
end
  def add_feature(f)
    @features.append(t)
  end

  def to_geojson(indent=0)
    # Write stuff
    s = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |f,i|
      if i != 0
        s +=","
      end
        if f.class == Track
            s += f.get_track_json
        elsif f.class == Waypoint
            s += f.get_waypoint_json
      end
    end
    s + "]}"
  end
end

def main()
  w = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  w2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")
  ts1 = [
  Point.new(-122, 45),
  Point.new(-122, 46),
  Point.new(-121, 46),
  ]

  ts2 = [ Point.new(-121, 45), Point.new(-121, 46), ]

  ts3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ]

  t = Track.new([ts1, ts2], "track 1")
  t2 = Track.new([ts3], "track 2")

  world = World.new("My Data", [w, w2, t, t2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

