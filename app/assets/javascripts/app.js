//= require jquery
//= require bootstrap-sprockets

var app = angular.module('bb.ffl', ['ngRoute']);

app.run(function($http){
    // https://github.com/rails/rails/issues/9940
    $http.defaults.headers.common.Accept = 'application/json';
})

app.factory('User', ['$http', '$rootScope', function($http, $rootScope){
    var User = {
        login: function(username, pw){
            return $http.post('/application/login', {
                name: username,
                password: pw
            })
            .then(function(response){
                User.current = response.data;
                $rootScope.$broadcast('loggedIn', {user: User.current});
            });
        }
    };
    return User;
}]);

app.controller('Test', ['$scope', function($scope){
    $scope.foo = 'bar';
}]);

app.controller('Nav', ['$scope', 'User', function($scope, User){
    $scope.login = function(username, pw){
        User.login(username, pw);
    }
    $scope.$on('loggedIn', function(evt, args){
        $scope.user = args.user;
    });
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
