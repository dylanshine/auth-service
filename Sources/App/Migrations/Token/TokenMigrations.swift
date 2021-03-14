import Fluent

enum TokenMigrations {
    static func add(_ migrations: Migrations) {
        migrations.add(RefreshTokenMigration_v1())
        migrations.add(EmailTokenMigration_v1())
        migrations.add(PasswordTokenMigration_v1())
    }
}

