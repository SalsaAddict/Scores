<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Scores.aspx.cs" Inherits="Scores.Scores" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml" ng-app="scores">
<head runat="server">
    <title>Scores</title>
    <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=0" /> 
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <link rel="stylesheet" type="text/css" href="Content/bootstrap.min.css" />
    <link rel="stylesheet" type="text/css" href="Content/font-awesome.min.css" />
    <link rel="stylesheet" type="text/css" href="Content/scores.min.css" />
</head>
<body>
    <ng-view></ng-view>
    <script src="Scripts/angular.min.js"></script>
    <script src="Scripts/angular-route.min.js"></script>
    <script src="Scripts/scores/scores.min.js"></script>
</body>
</html>
