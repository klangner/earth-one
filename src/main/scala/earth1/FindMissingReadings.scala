package earth1

import org.apache.spark.sql.{SparkSession, DataFrame}
import org.apache.spark.sql.types._


object FindMissingReadings {

  def loadStations(spark: SparkSession) = spark
    .read
    .option("header", "true")
    .csv("data/gdanskiewody/stations.csv")

  def loadSensors(spark: SparkSession): DataFrame = {
    val schema = StructType(List(
      StructField("Timestamp",TimestampType,false),
      StructField("value",FloatType,true), 
      StructField("station",IntegerType,false), 
      StructField("channel",StringType,false)))
    spark
      .read
      .option("header", "true")
      .option("timestampFormat", "y-M-d HH:mm:ss")
      .schema(schema)
      .csv("data/gdanskiewody/sensors")
  }

  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder()
      .master("local[1]")
      .appName("FindMissingReadings")
      .getOrCreate()

    spark.sparkContext.setLogLevel("ERROR")
    val stations = loadStations(spark)
    val sensors = loadSensors(spark)
  
    println("Stations:")
    println(s"#records: ${stations.count()}")
    sensors.head(10).foreach(println)
   
    spark.stop()
  }

}
