scalaVersion := "2.13.1"

name := "earth-one-crawler"
organization := "pl.klangner"
version := "1.0"

val akkaHttpVer = "10.1.11"

libraryDependencies ++= Seq(

    "org.typelevel" %% "cats-core" % "2.0.0",
    "com.typesafe.akka" %% "akka-stream" % "2.6.3",
    "com.typesafe.akka" %% "akka-http"   % akkaHttpVer,
    "com.typesafe.akka" %% "akka-http-spray-json" % akkaHttpVer
)
