import { NestFactory } from '@nestjs/core';
import { ValidationPipe, VersioningType } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import helmet from 'helmet';
import { AppModule } from './app.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { ResponseInterceptor } from './common/interceptors/response.interceptor';
import { RequestTracingMiddleware } from './common/middleware/request-tracing.middleware';
import { LoggingInterceptor } from './common/interceptors/logging.interceptor';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log'],
  });

  const config = app.get(ConfigService);

  // ── Security ──────────────────────────────────────────────────────────────
  app.use(helmet());
  app.enableCors({
    origin: config.get('NODE_ENV') === 'production'
      ? ['https://localserve.in']
      : '*',
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'x-trace-id', 'x-idempotency-key'],
    credentials: true,
  });

  // ── API versioning ────────────────────────────────────────────────────────
  app.enableVersioning({ 
    type: VersioningType.URI,
    defaultVersion: '1',
  });
  app.setGlobalPrefix('api');

  // ── Validation ────────────────────────────────────────────────────────────
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,           // Strip unknown fields
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  // ── Global filters & interceptors ─────────────────────────────────────────
  app.useGlobalFilters(new HttpExceptionFilter());
  app.useGlobalInterceptors(
    new LoggingInterceptor(),
    new ResponseInterceptor(),
  );

  // ── Swagger (dev only) ────────────────────────────────────────────────────
  if (config.get('NODE_ENV') !== 'production') {
    const swaggerConfig = new DocumentBuilder()
      .setTitle('LocalServe API')
      .setDescription('Production-grade Local Service Booking API')
      .setVersion('1.0')
      .addBearerAuth()
      .addTag('Auth')
      .addTag('Users')
      .addTag('Categories')
      .addTag('Services')
      .addTag('Bookings')
      .addTag('Chat')
      .addTag('Payments')
      .addTag('Admin')
      .build();
    const document = SwaggerModule.createDocument(app, swaggerConfig);
    SwaggerModule.setup('api/docs', app, document);
  }

  const port = config.get<number>('PORT') ?? 3000;
  await app.listen(port);
  console.log(`🚀 LocalServe API running on http://localhost:${port}/api`);
  console.log(`📖 Swagger docs: http://localhost:${port}/api/docs`);
}

bootstrap();
