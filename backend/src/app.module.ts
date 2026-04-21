import { Module, NestModule, MiddlewareConsumer } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ThrottlerModule } from '@nestjs/throttler';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { CategoriesModule } from './modules/categories/categories.module';
import { ServicesModule } from './modules/services/services.module';
import { BookingsModule } from './modules/bookings/bookings.module';
import { ChatModule } from './modules/chat/chat.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { AdminModule } from './modules/admin/admin.module';
import { RequestTracingMiddleware } from './common/middleware/request-tracing.middleware';

@Module({
  imports: [
    // ── Config ──────────────────────────────────────────────────────────────
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    // ── Database (Auto-detect PG or SQLite) ──────────────────────────────────
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const databaseUrl = config.get<string>('DATABASE_URL');
        
        if (databaseUrl) {
          // Production (PostgreSQL)
          return {
            type: 'postgres',
            url: databaseUrl,
            entities: [__dirname + '/**/*.entity{.ts,.js}'],
            synchronize: config.get('NODE_ENV') !== 'production', // Use migrations for real prod, sync for now
            ssl: { rejectUnauthorized: false }, // Required for Supabase/Neon
            logging: false,
          };
        }

        // Local Development (SQLite)
        return {
          type: 'sqlite',
          database: 'database.sqlite',
          entities: [__dirname + '/**/*.entity{.ts,.js}'],
          synchronize: true,
          logging: config.get('NODE_ENV') === 'development',
        };
      },
    }),

    // ── Rate Limiting ─────────────────────────────────────────────────────────
    ThrottlerModule.forRoot([
      {
        name: 'default',
        ttl: 60_000,
        limit: 60,
      },
    ]),

    // ── Feature Modules ───────────────────────────────────────────────────────
    AuthModule,
    UsersModule,
    CategoriesModule,
    ServicesModule,
    BookingsModule,
    ChatModule,
    PaymentsModule,
    AdminModule,
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(RequestTracingMiddleware).forRoutes('*');
  }
}
