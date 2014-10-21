//= require jquery
//= require bootstrap-sprockets

var app = angular.module('bb.ffl', ['ngRoute']);

app.controller('Test', ['$scope', function($scope){
    $scope.foo = 'bar';
}]);

app.config(['$routeProvider', function($routeProvider){
    $routeProvider
    .when('/', {
        controller: 'Test',
        template: '{{foo}}'
    })
    .otherwise({
        template: 'otherwise',
        controller: function($scope, $location){
            console.log('url:', $location.url())
        }
    })
}]);

app.config(function($locationProvider){
    $locationProvider.html5Mode(true);
});
