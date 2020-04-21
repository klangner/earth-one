val ZioVersion    = "1.0.0-RC18"
val Specs2Version = "4.8.3"

resolvers += Resolver.sonatypeRepo("releases")
resolvers += Resolver.sonatypeRepo("snapshots")

lazy val root = (project in file("."))
  .settings(
    organization := "pl.klangner",
    name := "earth1",
    version := "0.0.1",
    scalaVersion := "2.12.11",
    maxErrors := 3,
    libraryDependencies ++= Seq(
      "dev.zio"    %% "zio"         % ZioVersion,
      "org.specs2" %% "specs2-core" % Specs2Version % "test"
    )
  )

// Refine scalac params from tpolecat
scalacOptions --= Seq(
  "-Xfatal-warnings"
)

addCompilerPlugin("org.scalamacros" % "paradise" % "2.1.1" cross CrossVersion.full)

addCommandAlias("fmt", "all scalafmtSbt scalafmt test:scalafmt")
addCommandAlias("chk", "all scalafmtSbtCheck scalafmtCheck test:scalafmtCheck")
