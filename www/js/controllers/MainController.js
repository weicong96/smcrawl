var app = angular.module("trend");

app.controller("MainController" , ["$scope" ,"CoordinatesService","GoogleService", function($scope,CoordinatesService,GoogleService){
    var map = L.map('map').setView([1.302,103.8000], 13);
    L.tileLayer('http://a-tiles.sgmap.xyz/v2/Vibrant_City/{z}/{x}/{y}.png',{maxZoom: 18}).addTo(map);
    console.log(GoogleService);
    GoogleService.getPlaces({},function(locations){
        console.log(locations.length);
        locations.forEach(function(location){
            var latLng = new L.LatLng(location["location"]["lat"], location["location"]["lng"]);
            L.marker(latLng).addTo(map);
        });
    });
    CoordinatesService.getCoordinates().then(function(res){
    	var coordinates = res['data'];
    	for(var i = 0; i < coordinates.length;i++){
    		var latLng = new L.LatLng(coordinates[i]["latitude"], coordinates[i]["longitude"]);
    		L.circle(latLng, 750).addTo(map);


    	}
    },function(err){
    	console.log(err);
    });
}]);