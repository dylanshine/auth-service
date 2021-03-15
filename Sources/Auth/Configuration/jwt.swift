import Vapor
import XSJWT
import JWT

func jwt(_ app: Application) throws {
    //XSJWT Configurer
   try Configurer.configure(app)
    
    app.jwt.apple.applicationIdentifier = OAuth.Apple.clientID
    
    let privateKeyPath = app.directory.workingDirectory + OAuth.Apple.jwkPrivateKeyFile
    
    let signer = try JWTSigner.es256(key: .private(pem: .init(contentsOfFile: privateKeyPath)))
    app.jwt.signers.use(signer, kid: OAuth.Apple.kid, isDefault: false)
}

extension OAuth.Apple {

    static var kid: JWKIdentifier {
        JWKIdentifier(string: Environment.get("APPLE_JWK_ID")!)
    }
    
    static var jwkPrivateKeyFile: String {
        Environment.get("APPLE_JWK_PRIVATE_KEY_FILE")!
    }
}
