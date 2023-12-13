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
    track_json += '}'

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
    geometry_json += ']}'

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
      coordinate = '[' + "#{c.longitude},#{c.latitude}"
      coordinate += ",#{c.elevation}" if c.elevation != nil
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

  attr_reader :latitude, :longitude, :elevation

  def initialize(longitude, latitude, elevation=nil)
    @longitude = longitude
    @latitude = latitude
    @elevation = elevation
  end
end

class Waypoint

attr_reader :latitude, :longitude, :elevation, :name, :type

  def initialize(longitude, latitude, elevation=nil, name=nil, type=nil)
    @latitude = latitude
    @longitude = longitude
    @elevation = elevation
    @name = name
    @type = type
  end

  def get_waypoint_json(indent=0)
    waypoint_json = '{"type": "Feature",'
    # if name is not nil or type is not nil
    waypoint_json += '"geometry": {"type": "Point","coordinates": '
    waypoint_json += "[#{@longitude},#{@latitude}"
    if elevation != nil
      waypoint_json += ",#{@elevation}"
    end
    waypoint_json += ']},'
    if name != nil or type != nil
      waypoint_json += '"properties": {'
      if name != nil
        waypoint_json += '"title": "' + @name + '"'
      end
      if type != nil  # if type is not nil
        if name != nil
          waypoint_json += ','
        end
        waypoint_json += '"icon": "' + @type + '"'  # type is the icon
      end
      waypoint_json += '}'
    end
    waypoint_json += "}"
    return waypoint_json
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

