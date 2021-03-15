import Fluent

enum OAuthMigrations {
    static func add(_ migrations: Migrations) {
        migrations.add(NonceMigration_v1())
        migrations.add(GoogleUserMigration_v1())
        migrations.add(AppleUserMigration_v1())
    }
}
