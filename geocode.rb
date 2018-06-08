require 'httparty'
require 'json'

def sin_gr(x)
  Math.sin(Math::PI * x / 180.0)
end

def cos_gr(x)
  Math.cos(Math::PI * x / 180.0)
end

# http://osiktakan.ru/geo_koor.htm
def dist(point_1, point_2)
  r = 6371
  cosd = sin_gr(point_1[:lat]) * sin_gr(point_2[:lat]) + cos_gr(point_1[:lat]) * cos_gr(point_2[:lat]) * cos_gr(point_2[:lng] - point_1[:lng])
  cosd = 1  if cosd > 1 
  cosd = -1  if cosd < -1 
  (r * Math.acos(cosd)).round(2)
end

class YandexGeocoder
  include HTTParty
  base_uri 'https://geocode-maps.yandex.ru/'
end

def get_points(location)
  response = YandexGeocoder.get('/1.x/', query: {geocode: location, kind: 'locality', format: 'json'}).parsed_response
  features = response['response']['GeoObjectCollection']['featureMember']
  features.map{|feature|
    feature = feature['GeoObject']
    lng, lat = feature['Point']['pos'].split(' ')
    lng, lat = Float(lng), Float(lat)
    {lat: lat, lng: lng, name: feature['name'], description: feature['description']}
  }
end

def mean_dists(points)
  points.map{|point| 
    dists = points.reject{|pt| pt==point }.map{|pt| dist(pt, point) };
    [point, max_dist_to(points, point), dists.sum(0.0) / dists.size]
  }
end

def max_dist_to(points, central_point)
  points.map{|point| dist(central_point, point) }.max
end
def max_dist_to_first(points)
  max_dist_to(points, points.first)
end

places = File.readlines('undefined_coordinates_places.tsv').map{|l| l.chomp.split("\t") }
places.each{|place|
  begin
    country, city = *place
    city = nil  if !city || city == 'N/A' || city.empty?
    location = city ? "#{country}, #{city}" : country

    points = get_points(location)
    if points.empty?
      $stderr.puts "No results for `#{location}`"
      next
    end
    if points.size > 1 && max_dist_to_first(points) > 50 # 50 km
      $stderr.puts "Oops; #{points.size} answers for `#{location}`; maxdist: #{max_dist_to_first(points)}; point_1: #{points.first.values_at(:lat,:lng).join("\t")}"
      mean_dists(points).sort_by{|pt, max, mean| mean }.each{|pt, max, mean|
        $stderr.puts [country, city, location, pt[:lat], pt[:lng], mean, max, pt].join("\t")
      }
      next
    end
    # if points.size != 1
    #   if !city # we cant retry w/o city
    #     $stderr.puts "Oops; #{points.size} answers for `#{location}`"
    #     next
    #   else
    #     location = country
    #     points = get_points(location)
    #     location = '%' + location
    #     if points.size != 1
    #       $stderr.puts "Oops; #{points.size} answers for `#{location}`"
    #       next
    #     end
    #   end
    # end
    point = points.first
    infos = {country: country, city: city, location: location}.merge(point)
    puts infos.values_at(:country, :city, :location, :lat, :lng, :name, :description).join("\t")
    sleep 2
  rescue => e
    $stderr.puts "Error #{e} for `#{location}`"
  end
}


# --silent | jq '.response.GeoObjectCollection.featureMember[].GeoObject | {"pos":.Point.pos, "name":.name, "description":.description}' -c