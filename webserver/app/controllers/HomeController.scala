package controllers

import javax.inject._
import play.api._
import play.api.mvc._
import java.time.LocalDateTime

object HomeController {
    case class Station(id: String, name: String, updatedAt: LocalDateTime, level: Float, 
                      forecast: Float, forecastError: Float)

    case class Rainfall(id: String, name: String, updatedAt: LocalDateTime, precipitation: Float, forecast: Float)
}

/**
 * This controller creates an `Action` to handle HTTP requests to the
 * application's home page.
 */
@Singleton
class HomeController @Inject()(val controllerComponents: ControllerComponents) extends BaseController {

  import HomeController._

  /**
   * Create an Action to render an HTML page.
   *
   * The configuration in the `routes` file means that this method
   * will be called when the application receives a `GET` request with
   * a path of `/`.
   */
  def index() = Action { implicit request: Request[AnyContent] =>
    Ok(views.html.index())
  }

  def stations() = Action { implicit request: Request[AnyContent] =>
    val date = LocalDateTime.of(2020, 1, 1, 18, 0, 0)
    val stations = List(
      Station("1", "Wisła 1", date, 10, 12, 1.3f),
      Station("2", "Wisła 2", date, 20, 12, 1.3f),
      Station("3", "Wisła 3", date, 13, 12, 1.3f),
      Station("4", "Wisła 4", date, 18, 12, 1.3f),
      Station("5", "Wisła 5", date, 123, 1.4f, 1.3f)
    )
    Ok(views.html.stations(stations))
  }

  def rainfall() = Action { implicit request: Request[AnyContent] =>
    val date = LocalDateTime.of(2020, 1, 1, 18, 0, 0)
    val stations = List(
      Rainfall("1", "Wisła 1", date, 10, 12),
      Rainfall("2", "Wisła 2", date, 20, 12),
      Rainfall("3", "Wisła 3", date, 13, 12),
      Rainfall("4", "Wisła 4", date, 18, 12),
      Rainfall("5", "Wisła 5", date, 123, 1.4f)
    )
    Ok(views.html.rainfall(stations))
  }

  def about() = Action { implicit request: Request[AnyContent] =>
    Ok(views.html.about())
  }
}
