var app = angular.module("trend", ["ui.router", "ngResource"]);
app.config(["$stateProvider","$urlRouterProvider","$locationProvider",function($stateProvider,$urlRouterProvider,$locationProvider){
  $locationProvider.html5Mode(true).hashPrefix('!');
  $urlRouterProvider.otherwise("/404");
  $stateProvider.state("home", {
    url : "/home",
    templateUrl : "templates/home.html",
    controller : "MainController"
  }).state("404", {
    url : "/404",
    template : "<h3>404</h3>"
  });
}]);