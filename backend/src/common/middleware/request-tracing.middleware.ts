import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class RequestTracingMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const traceId = req.headers['x-trace-id'] || uuidv4();
    (req as any).traceId = traceId;
    res.setHeader('X-Trace-Id', traceId);
    next();
  }
}
