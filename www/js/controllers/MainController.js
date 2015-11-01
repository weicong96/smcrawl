var app = angular.module("trend");

app.controller("MainController" , ["$scope" ,"MainService", function($scope,MainService){
    var map = L.map('map').setView([1.302,103.8000], 13);
    L.tileLayer('http://a-tiles.sgmap.xyz/v2/Vibrant_City/{z}/{x}/{y}.png',{maxZoom: 18}).addTo(map);
    MainService.getCoordinates().then(function(res){
    	var coordinates = res['data'];
    	for(var i = 0; i < coordinates.length;i++){
    		var latLng = new L.LatLng(coordinates[i]["latitude"], coordinates[i]["longitude"]);
    		console.log(latLng);
    		L.circle(latLng, 750).addTo(map);
    	}
    },function(err){
    	console.log(err);
    });
}]);