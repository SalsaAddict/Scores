/// <reference path="../typings/angularjs/angular.d.ts" />
/// <reference path="../typings/angularjs/angular-route.d.ts" />

let app: angular.IModule = angular.module("scores", ["ngRoute"]);

namespace Scores {
    "use strict";
    export const debugEnabled: boolean = true;
    export function isBlank(value: any): boolean {
        if (angular.isUndefined(value)) return true;
        if (value === null) return true;
        if (angular.isArray(value)) return (value as any[]).length === 0;
        if (angular.isObject(value)) return angular.toJson(value) === angular.toJson({});
        if (String(value).trim() === "") return true;
        if (value === NaN) return true;
        return false;
    }
    export function ifBlank<T>(value: T, defaultValue: T): T { return isBlank(value) ? defaultValue : value; }
    export namespace Application {
        export function Config(): Function {
            let config: Function = function (
                $routeProvider: angular.route.IRouteProvider,
                $logProvider: angular.ILogProvider): void {
                $logProvider.debugEnabled(debugEnabled);
                $routeProvider
                    .when("/home", { templateUrl: "Views/home.html", controller: Scores.Home.Controller, controllerAs: "$ctrl" })
                    .otherwise({ redirectTo: "/home" })
                    .caseInsensitiveMatch = true;
            };
            config.$inject = ["$routeProvider", "$logProvider"];
            return config;
        }
    }
    export namespace Database {
        export interface IProcedure { readonly name: string; readonly parameters: IParameters; }
        export interface IParameter<T> { readonly value: T; readonly isObject: boolean; }
        export interface IParameters { [name: string]: IParameter<any>; }
        export class Procedure implements IProcedure {
            constructor(
                public readonly name: string,
                public readonly parameters: IParameters = {}) { }
            public addParameterWithValue<T>(name: string, value: T): Procedure {
                this.parameters[name] = new Parameter(value);
                return this;
            }
            public readonly queue: IProcedure[] = [];
            public get executable(): IProcedure {
                let procedure: IProcedure = { name: this.name, parameters: {} };
                angular.forEach(this.parameters, function (parameter: IParameter<any>, name: string): void {
                    procedure.parameters[name] = {
                        value: parameter.value,
                        isObject: parameter.isObject
                    };
                });
                return procedure;
            }
        }
        export class Parameter<T> implements IParameter<T> {
            constructor(public readonly value: T) { };
            public get isObject(): boolean { return angular.isObject(this.value); }
        }
    }
    export namespace Home {
        export class Controller {
            static $inject: string[] = ["$log"];
            constructor(private $log: angular.ILogService) {
                let procedure: Database.Procedure = new Database.Procedure("apiTest")
                    .addParameterWithValue("Id", 1)
                    .addParameterWithValue("Name", "Pierre")
                    .addParameterWithValue("Data", { c1: "", c2: 5, c3: "Hello" });
                $log.debug("procedure", procedure.executable, procedure);
            }
        }
    }
}

app.config(Scores.Application.Config());
