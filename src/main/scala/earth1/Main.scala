package earth1

import zio.ZIO
import zio.App
import zio.console._

object Main extends App {

  def run(args: List[String]) =
    myAppLogic.fold(_ => 1, _ => 0)
  
    val myAppLogic =
    for {
      _    <- putStrLn("Hello! What is your name?")
      name <- getStrLn
      _    <- putStrLn(s"Hello, ${name}, welcome to ZIO!")
    } yield ()

  def readConfig(): ZIO[Console, Nothing, Unit] = {
    putStrLn("test")
  }
}
