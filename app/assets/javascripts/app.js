//= require jquery
//= require bootstrap-sprockets

var app = angular.module('bb.ffl', ['ngRoute', 'ngResource']);

app.run(function($http){
    // https://github.com/rails/rails/issues/9940
    $http.defaults.headers.common.Accept = 'application/json';
})

app.filter('from_now', function(){
    return function(date){
        return moment(date).fromNow();
    };
});

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

app.factory('Team', function($resource){
    return $resource('/teams/:id', {id: '@id'}, {
        roster: {
            method: 'GET',
            isArray: true,
            url: '/teams/:id/roster'
        }
    });
});

app.controller('Team', function($scope, $routeParams, Team){
    $scope.id = $routeParams.id;
    $scope.posOrder = function(pvc){
        // TODO: get this order from server
        return ['QB', 'RB', 'WR', 'TE', 'D/ST', 'K'].indexOf(pvc.player.position);
    };
    $scope.headshot = function(player){
        return 'http://a.espncdn.com/combiner/i?' + $.param({
            img: '/i/teamlogos/nfl/500/' + player.nfl_team + '.png',
            w: 100,
            h: 50,
            scale: 'crop',
            background: '0xcccccc',
            transparent: true
        });
    };

    Team.get({id: $scope.id}).$promise
    .then(function(team){
        $scope.team = team;
    });

    Team.roster({id: $scope.id}).$promise
    .then(function(roster){
        $scope.roster = roster;
    });
});

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
    .when('/teams/:id', {
        controller: 'Team',
        templateUrl: '/assets/teams/show.html'
    })
    .otherwise({
        template: '<div class="alert alert-warning">Unknown route: <code>{{url}}</code></div>',
        controller: function($scope, $location){
            $scope.url = $location.url();
        }
    })
}]);

app.config(function($locationProvider){
    $locationProvider.html5Mode(true);
});
