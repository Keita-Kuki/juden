// Note: This example requires that you consent to location sharing when
// prompted by your browser. If you see the error "The Geolocation service
// failed.", it means you probably did not give permission for the browser to
// locate you.

function initMap() {
	var map = new google.maps.Map(document.getElementById('map'), {
		// center: {lat: 35.685175, lng: 139.7528},
		zoom: 15
	});
	
	var image = '/images/map/mapicon1.png';
// 	var infoWindow = new google.maps.InfoWindow({map: map});
	var marker = new google.maps.Marker({map: map, icon: image});

  // Try HTML5 geolocation.
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position) {
    var pos = {
        lat: position.coords.latitude,
        lng: position.coords.longitude
  };

  // infoWindow.setPosition(pos);
  // infoWindow.setContent('現在位置');
  // map.setCenter(pos);
  
  
  
	marker.setPosition(pos);
	marker.setAnimation(google.maps.Animation.DROP);
	map.setCenter(pos);
	
  }, function() {
      handleLocationError(true, infoWindow, map.getCenter());
    });
  } else {
    // Browser doesn't support Geolocation
    handleLocationError(false, infoWindow, map.getCenter());
  }
}

function handleLocationError(browserHasGeolocation, infoWindow, pos) {
  infoWindow.setPosition(pos);
  infoWindow.setContent(browserHasGeolocation ?
  'Error: The Geolocation service failed.' :
  'Error: Your browser doesn\'t support geolocation.');
}
