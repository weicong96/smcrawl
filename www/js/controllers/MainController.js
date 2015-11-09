var app = angular.module("trend");

app.controller("MainController" , ["$scope" ,"CoordinatesService","GoogleService","InstagramService",function($scope,CoordinatesService,GoogleService,InstagramService){
    
    var southWest = [ 1.149, 103.583 ];
    var northeast = [ 1.490, 104.149 ];

    var startLat = 1.2867888749929002;
    var startLng = 103.8545510172844;
    var maxbounds = L.latLngBounds(southWest, northeast);
    var map = L.map('map',
    {
      zoom                : 16,
      maxBounds           : maxbounds,
      zoomControl         : true,
      attributionControl  : false,
      drawControl         : true,
      fadeAnimation       : true,
      zoomAnimation       : true
    }).setView([startLat, startLng], 18);
    map.on("zoomend", function(){
        console.log(map.getZoom());
    });
    L.tileLayer('http://a-tiles.sgmap.xyz/v2/NightLife_City/{z}/{x}/{y}.png',{
      minZoom         : 12,
      maxZoom         : 18,
      maxNativeZoom   : 18,
      bounds          : maxbounds,
      continuousWorld : false,
      noWrap          : true,
      reuseTiles      : false
    }).addTo(map);
    
    GoogleService.getPlaces({},function(locations){
        /*console.log(locations.length);
        var markers = new L.MarkerClusterGroup({maxClusterRadius : 200});
        locations.forEach(function(location){
            var latLng = new L.LatLng(location["location"]["lat"], location["location"]["lng"]);
            var div = "<div>";
            div += "<b>"+location['name']+"</b>";
            div += location['location']['lat']+" , "+location['location']["lng"];
            div += "Types : "+location["types"];
            div += "</div>";
            var marker = L.marker(latLng);
            marker.bindPopup(div);
            markers.addLayer(marker);
        });
        map.addLayer(markers);*/
    });
    InstagramService.getMedia({}, function(medias){
      var markers = new L.MarkerClusterGroup({maxClusterRadius : 200});
        medias.forEach(function(media){
          console.log(media);
            var latLng = new L.LatLng(media["location"]["latitude"], media["location"]["longitude"]);
            var div = "<div>";
            var standard_image = media["images"]["standard_resolution"];
            div += "<img src='"+standard_image['url']+"' width='"+standard_image['width']+"' height='"+standard_image['height']+"'/>";
            div += "<b>"+media['link']+"</b>";
            div += media['location']['latitude']+" , "+media['location']["longitude"];
            div += "Tags : "+media["tags"];
            div += "</div>";
            var marker = L.marker(latLng);
            marker.bindPopup(div);
            markers.addLayer(marker);
        });
        map.addLayer(markers);
    });
    /*
    CoordinatesService.getCoordinates().then(function(res){
    	var coordinates = res['data'];
    	for(var i = 0; i < coordinates.length;i++){
    		var latLng = new L.LatLng(coordinates[i]["latitude"], coordinates[i]["longitude"]);
    		L.circle(latLng, 750).addTo(map);


    	}
    },function(err){
    	console.log(err);
    });*/
}]);