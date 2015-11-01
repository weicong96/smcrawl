var app = angular.module("trend", ["ui.router", "ngResource"]);
app.config(["$stateProvider","$urlRouterProvider","$locationProvider",function($stateProvider,$urlRouterProvider,$locationProvider){
  $locationProvider.html5Mode(true).hashPrefix('!');
  $urlRouterProvider.otherwise("/home");
  $stateProvider.state("home", {
    url : "/home",
    templateUrl : "templates/home.html",
    controller : "MainController"
  });
}]);