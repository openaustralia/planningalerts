function initialiseBasicMapWithMarker(map_div) {
  var center = { lat: Number(map_div.dataset.lat), lng: Number(map_div.dataset.lng) };
  var address = map_div.dataset.address;
  var zoom = Number(map_div.dataset.zoom);

  var map = new google.maps.Map(
    map_div,
    { zoom: zoom, center: center, fullscreenControl: false, streetViewControl: false, draggable: false, backgroundColor: "#d1e6d9" }
  );
  new google.maps.Marker({ position: center, map: map, title: address });

  return map;
}
