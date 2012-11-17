jQuery ->
  $("#user_followed_group_ids").chosen()
  $("#user_custom_group_ids").chosen()
  $("#user_state_id").chosen()
  $("#user_district_id").chosen()
  udd = $("#users-district-display")
  if udd
    udd.html "<img src=\"/assets/spinner.gif\" alt=\"Loading ...\" style=\"box-shadow: none\">"
    # $.getJSON "http://www.polco.us/district_data/" + udd.data('district') + ".json", (d_data) ->
    district = udd.data('district') # probably not needed
    bounds = undefined
    congressionalDistrict = undefined
    coord = undefined
    districtCoords = undefined
    gMapLatLon = undefined
    map = undefined
    myLatLng = undefined
    myOptions = undefined
    northEast = undefined
    southWest = undefined
    _i = undefined
    _len = undefined
    _ref = undefined
    myLatLng = new google.maps.LatLng(gon.centroid.lat, gon.centroid.lon)
    myOptions =
      zoom: 5
      center: myLatLng
      mapTypeId: google.maps.MapTypeId.TERRAIN

    map = new google.maps.Map(document.getElementById("users-district-display"), myOptions)
    districtCoords = []
    _ref = gon.coords
    _i = 0
    _len = _ref.length

    while _i < _len
      coord = _ref[_i]
      gMapLatLon = new google.maps.LatLng(coord.lat, coord.lon)
      districtCoords.push gMapLatLon
      _i++
    congressionalDistrict = new google.maps.Polygon(
      paths: districtCoords
      strokeColor: "#B88A00"
      strokeOpacity: 0.9
      strokeWeight: 2
      fillColor: "#F5B800"
      fillOpacity: 0.35
    )
    congressionalDistrict.setMap map
    southWest = new google.maps.LatLng(gon.extents.southWest.lat, gon.extents.southWest.lon)
    northEast = new google.maps.LatLng(gon.extents.northEast.lat, gon.extents.northEast.lon)
    bounds = new google.maps.LatLngBounds(southWest, northEast)
    map.fitBounds bounds
