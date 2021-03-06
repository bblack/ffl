//= require jquery
//= require bootstrap-sprockets
//= require angular/angular.min
//= require angular-resource/angular-resource.min
//= require angular-route/angular-route.min
//= require moment/moment
//= require ng-table/dist/ng-table.min
//= require lodash/dist/lodash.min
//= require alertifyjs/dist/js/alertify
//= require angular-ui-select/dist/select.min

var app = angular.module('bb.ffl', ['ngRoute', 'ngResource', 'ngTable', 'ui.select'])
.run(() => {
    alertify.parent(document.body);
})
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
.run(function($http, $rootScope){
    // https://github.com/rails/rails/issues/9940
    $http.defaults.headers.common.Accept = 'application/json';
    $rootScope.logout = function(){
        $http.get('/application/logout');
    }
})
.factory('RfaBid', function($resource){
    return $resource('/rfa_bids/:id', {id: '@id'});
})
.factory('RfaDecision', function($resource){
    return $resource('/rfa_decisions/');
})
.factory('RfaPeriod', function($resource){
    return $resource('/rfa_periods/:id', {id: '@id'});
})
.factory('User', function($http, $rootScope){
    var User = {
        login: function(username, pw){
            return $http.post('/application/login', {
                name: username,
                password: pw
            })
            .then(() => alertify.success('Success!'))
            .catch(() => alertify.error('Failure!'));
        }
    };
    return User;
})
.factory('Team', function($resource, $http, Player){
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
    Team.prototype.maxPayroll = function(){
        return this.payroll + this.payroll_available;
    };
    return Team;
})
.factory('League', function($resource, $http){
    var League = $resource('/leagues/:id', {id: '@id'}, {
        teams: {
            method: 'GET',
            url: '/leagues/:id/teams',
            isArray: true
        }
    });
    League.positions =  ['QB', 'RB', 'WR', 'TE', 'D/ST', 'K'];
    League.syncEspn = (id) => $http.post('/leagues/' + id + '/update_espn_rosters');
    return League;
})
.factory('Player', function($resource){
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
        opts = opts || {};
        return espnCombinerUrl + jQuery.param({
            img: '/i/headshots/nfl/players/full/' + this.espn_id + '.png',
            w: opts.w || 100,
            h: opts.h || 50,
            scale: 'crop',
            background: '0xcccccc',
            transparent: true
        });
    };
    return Player;
})
.controller('Draft', function($scope, $http, $routeParams){
    $scope.refreshPlayers = function(search){
        $http.get('/players.json', {
            params: {
                last_name: search
            }
        })
        .then((res) => $scope.players = res.data);
    }
    $scope.add = function(pick){
        $scope.picks.push(pick);
        $scope.nextpick = {};
        $scope.$broadcast('pickPushed');
    }
    $scope.picks = [];
    $scope.nextpick = {};
    $scope.submit = function(){
        $http.post('/leagues/' + $routeParams.id + '/draft', {
            picks: $scope.picks.map((pick) => {
                return {player_id: pick.player.id, new_value: pick.value};
            })
        })
        .then(() => alertify.success('ok!'))
    }
})
.controller('Team', function($scope, $rootScope, $routeParams, League, Team, Player, NgTableParams){
    $scope.id = $routeParams.id;
    $scope.posOrder = (pvc) => League.positions.indexOf(pvc.player.position);
    $scope.tableParams = new NgTableParams({}, {
        counts: [],
        getData: (params) => Team.roster({id: $scope.id}).$promise
    });
    $scope.team = Team.get({id: $scope.id}, function(team){
        $rootScope.leagueId = team.league_id;
    });
})
.controller('LeagueIndex', function($scope, League){
    $scope.leagues = League.query();
})
.controller('LeagueTeams', function($scope, $rootScope, $routeParams, League, Team){
    $rootScope.leagueId = $routeParams.id;
    $scope.positions = League.positions;
    $scope.spotsTaken = function(team){
        var roster = team.roster;
        return Object.keys(roster).reduce(function(m, key){
            return m + roster[key];
        }, 0);
    }
    function getTeams(){
        $scope.teams = League.teams({id: $scope.leagueId});
    }
    getTeams();
    $scope.league = League.get({id: $scope.leagueId});
    $scope.syncEspn = () => {
        $scope.syncPromise = League.syncEspn($scope.leagueId)
        .then(getTeams);
    };
})
.controller('Players', function($scope, $rootScope, $location, League, Player, NgTableParams){
    var leagueId = $rootScope.leagueId = $location.search().leagueId;
    $scope.league = League.get({id: leagueId});
    $scope.tableParams = new NgTableParams({
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
.controller('Nav', function($scope, User){
    $scope.login = function(username, pw){
        User.login(username, pw);
    };
})
.controller('RfaPeriodShow', function($scope, $routeParams, RfaBid, RfaDecision, RfaPeriod, League){
    function load(){
        $scope.rfa = RfaPeriod.get({id: $routeParams.id}, (rfa) => {
            $scope.rows = _.chunk(rfa.teams, 4);
            ['open_date', 'close_date'].forEach((key) => {
                $scope[key] = moment.utc($scope.rfa[key]).format('LLLL');
            });
            if (rfa.rfa_decision_period) {
                rfa.rfa_decision_period.rfa_decisions.forEach((d) => {
                    $scope.keep[d.player_id] = d.keep;
                });
            }
        });
    }
    $scope.keep = {};
    $scope.contractBelongsTo = function(teamId){
        return (contract, ind, arr) => contract.team_id == teamId;
    }
    $scope.highestBid = function(playerId){
        return _.chain($scope.rfa.rfa_bids)
            .filter({player_id: playerId})
            .sortBy('id')
            .sortBy('value')
            .last()
            .result('value')
            .value()
    }
    $scope.submitBid = function(playerId, bid){
        new RfaBid({
            rfa_period_id: $scope.rfa.id,
            player_id: playerId,
            value: bid
        })
        .$save()
        .then(() => {
            load();
        });
    }
    $scope.onKeepToggle = function(playerId, keep){
        new RfaDecision({
            rfa_decision_period_id: $scope.rfa.rfa_decision_period.id,
            player_id: playerId,
            keep: keep
        })
        .$save()
        .then((res) => alertify.success(res.result));
    }
    $scope.userOwnsTeam = (teamId) => {
        var user = $scope.$root.user;
        return user && _.includes(user.team_ids, teamId);
    };
    load();
})
.config(function($routeProvider, $locationProvider){
    $routeProvider
    .when('/', {
        redirectTo: '/leagues'
    })
    .when('/leagues', {
        controller: 'LeagueIndex',
        templateUrl: '/assets/leagues/index.html'
    })
    .when('/leagues/:id', {
        redirectTo: function(routeParams){
            return '/leagues/' + routeParams.id + '/teams';
        }
    })
    .when('/leagues/:id/draft', {
        controller: 'Draft',
        templateUrl: '/assets/leagues/draft.html'
    })
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
    .when('/rfa_periods/:id', {
        controller: 'RfaPeriodShow',
        templateUrl: '/assets/rfa_periods/show.html'
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
    });

    $locationProvider.html5Mode(true);
});
