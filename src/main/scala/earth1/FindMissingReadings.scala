package earth1

import org.apache.spark.sql.{SparkSession}
import org.apache.spark.sql.types._


object FindMissingReadings extends App {

  val spark = SparkSession.builder()
    .master("local[1]")
    .appName("FindMissingReadings")
    .getOrCreate();

  spark.sparkContext.setLogLevel("ERROR")

  val stations = spark
    .read
    .option("header", "true")
    .csv("data/gdanskiewody/stations.csv")
  println("Stations:")
  println(s"#records: ${stations.count()}")

  val schema = StructType(List(
    StructField("Timestamp",TimestampType,false),
    StructField("value",FloatType,true), 
    StructField("station",IntegerType,false), 
    StructField("channel",StringType,false)))
  val sensors = spark
    .read
    .option("header", "true")
    .option("timestampFormat", "y-M-d HH:mm:ss")
    .schema(schema)
    .csv("data/gdanskiewody/sensors")

  sensors.head(10).foreach(println)

  spark.stop()
}
