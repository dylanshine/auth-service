import Vapor
import XSJWT

func jwt(_ app: Application) throws {
    //XSJWT Configurer
   try Configurer.configure(app)
}
