var app = angular.module("trend");
app.constant("API_ENDPOINT", "http://localhost:3000/api");
app.factory("CoordinatesService", ["$resource", "API_ENDPOINT", "$http","$q",function($resource,API_ENDPOINT,$http,$q){
	 return {
	 	getCoordinates : function(){
	 		var defer = $q.defer();
            $http.get(API_ENDPOINT+'/coordinates').then(function(result){
	            defer.resolve(result);
	        },function(){
	            defer.reject();
	        });
            return defer.promise;
	 	}
	 };
}])
.factory("GoogleService", ["$resource", "API_ENDPOINT"], function($resource, API_ENDPOINT){
	return $resource(API_ENDPOINT+"/search?", {
		
	});
});