package earth1

import org.apache.spark.sql.{SparkSession, SQLContext}
import org.apache.spark.SparkContext


object FindMissingReadings extends App {

  val spark = SparkSession.builder()
    .master("local[1]")
    .appName("FindMissingReadings")
    .getOrCreate();

  spark.sparkContext.setLogLevel("ERROR")

  val stations = spark.read.csv("data/gdanskiewody/stations.csv")
  println(s"${stations.count()}")
  spark.stop()
}
