import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const { method, url } = request;
    const traceId = request.traceId;
    const start = Date.now();

    return next.handle().pipe(
      tap({
        next: () => {
          const ms = Date.now() - start;
          const statusCode = context.switchToHttp().getResponse().statusCode;
          this.logger.log(`[${traceId}] ${method} ${url} ${statusCode} +${ms}ms`);
        },
        error: (err) => {
          const ms = Date.now() - start;
          this.logger.warn(`[${traceId}] ${method} ${url} ERROR +${ms}ms`);
        },
      }),
    );
  }
}
