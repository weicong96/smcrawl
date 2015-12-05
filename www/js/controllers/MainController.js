var app = angular.module("trend");

app.controller("MainController" , ["$scope" , function($scope){
    var map = L.map('map').setView([1.302,103.8000], 13);
    L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png?{foo}', {foo: 'bar'}).addTo(map);
}]);