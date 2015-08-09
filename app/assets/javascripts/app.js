//= require jquery
//= require bootstrap-sprockets
//= require ng-table/dist/ng-table

var app = angular.module('bb.ffl', ['ngRoute', 'ngResource', 'ngTable'])
.config(function($httpProvider){
    var $rootScope;
    $httpProvider.interceptors.push(function($injector){
        if (!$rootScope) $rootScope = $injector.get('$rootScope');
        return {
            response: function(response){
                var user = response.headers()['x-user'];
                $rootScope.user = user === undefined ? undefined : JSON.parse(user);
                return response;
            }
        }
    })
})

app.run(function($http, $rootScope){
    // https://github.com/rails/rails/issues/9940
    $http.defaults.headers.common.Accept = 'application/json';
    $rootScope.logout = function(){
        $http.get('/application/logout');
    }
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
            });
        }
    };
    return User;
}]);

app.factory('Team', function($resource, $http, Player){
    function transformRes(data){
        data = JSON.parse(data);
        return data.map(function(pvc){
            pvc.player = new Player(pvc.player);
            return pvc;
        });
    }
    var Team = $resource('/teams/:id', {id: '@id'}, {
        roster: {
            method: 'GET',
            isArray: true,
            url: '/teams/:id/roster',
            transformResponse: transformRes
        }
    });
    Team.prototype.fetchEspn = function(){
        return $http({
            method: 'post',
            url: '/teams/' + this.id + '/fetch_espn',
            transformResponse: transformRes
        })
        .then(function(val){
            return val.data;
        });
    };
    Team.prototype.maxPayroll = function(){
        return this.payroll + this.payroll_available;
    };
    return Team;
});

app.factory('League', function($resource){
    var League = $resource('/leagues/:id', {id: '@id'}, {
        teams: {
            method: 'GET',
            url: '/leagues/:id/teams',
            isArray: true
        }
    });

    return League;
});

app.factory('Player', function($resource){
    var Player = $resource('/players/:id', {id: '@id'});
    var espnCombinerUrl = 'http://a.espncdn.com/combiner/i?'
    Player.prototype.fullName = function(){
        return this.first_name + ' ' + this.last_name;
    };
    Player.prototype.indexName = function(){
        return this.last_name + ', ' + this.first_name;
    };
    Player.prototype.link = function(){
        return 'players/' + this.id;
    };
    Player.prototype.headshot = function(opts){
        return espnCombinerUrl + qs({
            img: '/i/headshots/nfl/players/full/' + this.espn_id + '.png',
            w: opts.w || 100,
            h: opts.h || 50,
            scale: 'crop',
            background: '0xcccccc',
            transparent: true
        });
    };
    Player.prototype.teamlogo = function(opts){
        var team = this.nfl_team;
        return espnCombinerUrl + qs({
            img: '/i/teamlogos/nfl/500/' + team + '.png',
            w: opts.w || 100,
            h: opts.h || 50,
            scale: 'crop',
            background: '0xcccccc',
            transparent: true
        });
    };
    return Player;
})

app.controller('Team', function($scope, $rootScope, $routeParams, Team, Player, ngTableParams){
    $scope.id = $routeParams.id;
    $scope.posOrder = function(pvc){
        // TODO: get this order from server
        return ['QB', 'RB', 'WR', 'TE', 'D/ST', 'K'].indexOf(pvc.player.position);
    };
    $scope.fetchEspn = function(team){
        team.fetchEspn()
        .then(function(roster){
            $scope.roster = roster;
            $scope.team.espn_roster_last_updated = new Date();
        });
    };
    $scope.tableParams = new ngTableParams({
        page: 1,
        count: 20
    }, {
        getData: function($defer, params){
            Team.roster({id: $scope.id}).$promise
            .then(function(roster){
                $scope.roster = roster;
                $defer.resolve(roster);
            }, function(e){
                $defer.reject(e);
            });
        }
    })

    $scope.team = Team.get({id: $scope.id}, function(team){
        $rootScope.leagueId = team.league_id;
    });
});

app.controller('LeagueTeams', function($scope, $rootScope, $routeParams, League, Team){
    $rootScope.leagueId = $routeParams.id;

    League.teams({id: $scope.leagueId}).$promise
    .then(function(teams){
        $scope.teams = teams;
    });

    League.get({id: $scope.leagueId}).$promise
    .then(function(league){
        $scope.league = league;
    });
})

app.controller('Players', function($scope, $rootScope, $location, League, Player, ngTableParams){
    var leagueId = $rootScope.leagueId = $location.search().leagueId;
    $scope.league = League.get({id: leagueId});
    $scope.tableParams = new ngTableParams({
        count: 10,
        page: 1
    }, {
        getData: function($defer, params){
            Player.query({
                leagueId: leagueId,
                offset: params.count() * (params.page() - 1),
                limit: params.count()
            }, function(roster, headers){
                params.total(headers('x-total'));
                $defer.resolve(roster);
            }, $defer.reject);
        }
    });
})
.controller('PlayerShow', function($scope, $routeParams, Player){
    $scope.player = Player.get({id: $routeParams.id});
})

app.controller('Nav', ['$scope', 'User', function($scope, User){
    $scope.login = function(username, pw){
        User.login(username, pw);
    };
}]);

app.config(['$routeProvider', function($routeProvider){
    $routeProvider
    .when('/leagues/:id/teams', {
        controller: 'LeagueTeams',
        templateUrl: '/assets/leagues/teams.html'
    })
    .when('/players', {
        controller: 'Players',
        templateUrl: '/assets/players/index.html'
    })
    .when('/players/:id', {
        controller: 'PlayerShow',
        templateUrl: '/assets/players/show.html'
    })
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
