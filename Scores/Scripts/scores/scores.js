/// <reference path="../typings/angularjs/angular.d.ts" />
/// <reference path="../typings/angularjs/angular-route.d.ts" />
var app = angular.module("scores", ["ngRoute"]);
var Scores;
(function (Scores) {
    "use strict";
    Scores.debugEnabled = true;
    function isBlank(value) {
        if (angular.isUndefined(value))
            return true;
        if (value === null)
            return true;
        if (angular.isArray(value))
            return value.length === 0;
        if (angular.isObject(value))
            return angular.toJson(value) === angular.toJson({});
        if (String(value).trim() === "")
            return true;
        if (value === NaN)
            return true;
        return false;
    }
    Scores.isBlank = isBlank;
    function ifBlank(value, defaultValue) { return (isBlank(value)) ? defaultValue : value; }
    Scores.ifBlank = ifBlank;
    var Application;
    (function (Application) {
        function Config() {
            var config = function ($routeProvider, $logProvider) {
                $logProvider.debugEnabled(Scores.debugEnabled);
                $routeProvider
                    .when("/home", { templateUrl: "Views/home.html", controller: Scores.Home.Controller, controllerAs: "$ctrl" })
                    .otherwise({ redirectTo: "/home" })
                    .caseInsensitiveMatch = true;
            };
            config.$inject = ["$routeProvider", "$logProvider"];
            return config;
        }
        Application.Config = Config;
    })(Application = Scores.Application || (Scores.Application = {}));
    var Database;
    (function (Database) {
        var Procedure = /** @class */ (function () {
            function Procedure(name, parameters) {
                if (parameters === void 0) { parameters = {}; }
                this.name = name;
                this.parameters = parameters;
                this.queue = [];
            }
            Procedure.prototype.addParameterWithValue = function (name, value) {
                this.parameters[name] = new Parameter(value);
                return this;
            };
            Object.defineProperty(Procedure.prototype, "executable", {
                get: function () {
                    var procedure = { name: this.name, parameters: {} };
                    angular.forEach(this.parameters, function (parameter, name) {
                        procedure.parameters[name] = {
                            value: parameter.value,
                            isObject: parameter.isObject
                        };
                    });
                    return procedure;
                },
                enumerable: true,
                configurable: true
            });
            return Procedure;
        }());
        Database.Procedure = Procedure;
        var Parameter = /** @class */ (function () {
            function Parameter(value) {
                this.value = value;
            }
            ;
            Object.defineProperty(Parameter.prototype, "isObject", {
                get: function () { return angular.isObject(this.value); },
                enumerable: true,
                configurable: true
            });
            return Parameter;
        }());
        Database.Parameter = Parameter;
    })(Database = Scores.Database || (Scores.Database = {}));
    var Home;
    (function (Home) {
        var Controller = /** @class */ (function () {
            function Controller($log) {
                this.$log = $log;
                var procedure = new Database.Procedure("apiTest")
                    .addParameterWithValue("Id", 1)
                    .addParameterWithValue("Name", "Pierre")
                    .addParameterWithValue("Data", { c1: "", c2: 5, c3: "Hello" });
                $log.debug("procedure", procedure.executable, procedure);
            }
            Controller.$inject = ["$log"];
            return Controller;
        }());
        Home.Controller = Controller;
    })(Home = Scores.Home || (Scores.Home = {}));
})(Scores || (Scores = {}));
app.config(Scores.Application.Config());
//# sourceMappingURL=scores.js.map