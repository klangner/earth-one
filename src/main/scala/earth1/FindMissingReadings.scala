package earth1

import org.apache.spark.sql.{SparkSession}//, SQLContext}
// import org.apache.spark.SparkContext


object FindMissingReadings extends App {

  val spark = SparkSession.builder()
    .master("local[1]")
    .appName("FindMissingReadings")
    .getOrCreate();

  spark.sparkContext.setLogLevel("ERROR")

  val stations = spark.read.options(Map("header" -> "true")).csv("data/gdanskiewody/stations.csv")
  println("Stations:")
  println(s"#records: ${stations.count()}")
  val sensors = spark.read.options(Map("header" -> "true")).csv("data/gdanskiewody/sensors")
  println("Sensors:")
  println(s"#records: ${sensors.count()}")
  val columns = sensors.columns.mkString(", ")
  println(s"columns: ${columns}")

  val test = spark.read.options(Map("header" -> "true")).csv("data/gdanskiewody/test")
  println("Test:")
  println(s"#records: ${test.count()}")
  val cols = test.columns.mkString(", ")
  println(s"columns: ${cols}")

  spark.stop()
}
