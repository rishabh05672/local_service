import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const request = ctx.getRequest<Request>();
    const response = ctx.getResponse<Response>();

    const isHttpException = exception instanceof HttpException;
    const status = isHttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;

    const exceptionResponse = isHttpException
      ? exception.getResponse()
      : null;

    // Sanitize the error — never leak stack traces or internal details
    const message = this.extractMessage(exceptionResponse, status);
    const errors = this.extractErrors(exceptionResponse);

    const traceId = (request as any).traceId ?? 'unknown';

    // Only log 5xx server errors
    if (status >= 500) {
      this.logger.error(
        `[${traceId}] ${request.method} ${request.url} → ${status}`,
        exception instanceof Error ? exception.stack : String(exception),
      );
    }

    response.status(status).json({
      success: false,
      statusCode: status,
      message,
      errors: errors.length ? errors : undefined,
      traceId,
      timestamp: new Date().toISOString(),
      path: request.url,
    });
  }

  private extractMessage(
    exceptionResponse: string | object | null,
    status: number,
  ): string {
    if (!exceptionResponse) {
      return status === 500
        ? 'Internal server error.'
        : 'An error occurred.';
    }
    if (typeof exceptionResponse === 'string') return exceptionResponse;
    if (
      typeof exceptionResponse === 'object' &&
      'message' in exceptionResponse
    ) {
      const msg = (exceptionResponse as any).message;
      return Array.isArray(msg) ? msg[0] : String(msg);
    }
    return 'An error occurred.';
  }

  private extractErrors(exceptionResponse: string | object | null): string[] {
    if (!exceptionResponse || typeof exceptionResponse !== 'object')
      return [];
    const msg = (exceptionResponse as any).message;
    if (Array.isArray(msg)) return msg;
    return [];
  }
}
