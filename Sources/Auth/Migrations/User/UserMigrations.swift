import Fluent

enum UserMigrations {
    static func add(_ migrations: Migrations) {
        migrations.add(UserMigration_v1())
    }
}

