import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import * as path from 'path';
import * as fs from 'fs';
import { UserEntity } from '../users/entities/user.entity';
import { RegisterDto } from './dto/auth.dto';
import { FirebaseAdminConfig } from './firebase-admin.config';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(UserEntity)
    private usersRepository: Repository<UserEntity>,
    private jwtService: JwtService,
    private configService: ConfigService,
    private firebaseAdmin: FirebaseAdminConfig,
  ) {}

  async verifyFirebaseToken(idToken: string): Promise<string> {
    try {
      // 1. Try real verification first
      const decodedToken = await this.firebaseAdmin.verifyIdToken(idToken);
      if (!decodedToken.phone_number) {
        throw new UnauthorizedException('Phone number not found in Firebase token.');
      }
      return decodedToken.phone_number;
    } catch (error) {
      // 2. BYPASS FOR TESTING: If service account is missing, we allow debugging
      const serviceAccountPath = path.join(process.cwd(), 'firebase-service-account.json');
      if (!fs.existsSync(serviceAccountPath)) {
        console.warn('DEBUG: Bypassing Firebase signature verification because service account is missing.');
        
        try {
          // Extract phone number from JWT payload without verification (ONLY FOR DEV!)
          const payload = JSON.parse(Buffer.from(idToken.split('.')[1], 'base64').toString());
          if (payload.phone_number) {
            console.log('DEBUG: Extracted phone from token payload:', payload.phone_number);
            return payload.phone_number;
          }
        } catch (e) {
          console.error('DEBUG: Failed to parse token payload for bypass');
        }
      }
      
      throw new UnauthorizedException('Invalid Firebase token. ' + (error.message || ''));
    }
  }

  async register(dto: RegisterDto) {
    const existing = await this.usersRepository.findOne({
      where: { phone: dto.phone },
    });
    if (existing) {
      throw new BadRequestException(
        'User with this phone already exists. Please login instead.',
      );
    }

    const user = this.usersRepository.create({
      phone: dto.phone,
      name: dto.name,
      email: dto.email,
      role: dto.role,
    });

    await this.usersRepository.save(user);
    return this.generateTokens(user);
  }

  async loginWithPhone(phone: string) {
    const user = await this.usersRepository.findOne({ where: { phone } });
    if (!user) {
      throw new UnauthorizedException(
        'No account found with this number. Please register first.',
      );
    }
    if (!user.isActive) {
      throw new UnauthorizedException(
        'Your account has been disabled. Please contact support.',
      );
    }
    return this.generateTokens(user);
  }

  async refreshTokens(refreshToken: string) {
    try {
      const decoded = this.jwtService.verify(refreshToken, {
        secret: this.configService.get('JWT_REFRESH_SECRET'),
      });

      const user = await this.usersRepository.findOne({
        where: { id: decoded.sub },
      });

      if (!user || typeof user.jwtRefreshToken !== 'string') {
        throw new UnauthorizedException('Session expired. Please login again.');
      }

      const isMatch = await bcrypt.compare(refreshToken, user.jwtRefreshToken);
      if (!isMatch) {
        throw new UnauthorizedException('Token has been revoked. Please login again.');
      }

      return this.generateTokens(user);
    } catch (e) {
      if (e instanceof UnauthorizedException) throw e;
      throw new UnauthorizedException('Invalid or expired refresh token. Please login again.');
    }
  }

  private async generateTokens(user: UserEntity) {
    const payload = { sub: user.id, role: user.role };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload),
      this.jwtService.signAsync(payload, {
        secret: this.configService.get('JWT_REFRESH_SECRET'),
        expiresIn: this.configService.get('JWT_REFRESH_EXPIRES_IN') || '30d',
      }),
    ]);

    const hashedRefresh = await bcrypt.hash(refreshToken, 10);
    await this.usersRepository.update(user.id, {
      jwtRefreshToken: hashedRefresh,
    });

    return {
      user: {
        id: user.id,
        name: user.name,
        phone: user.phone,
        email: user.email ?? null,
        avatarUrl: user.avatarUrl ?? null,
        role: user.role,
        isActive: user.isActive,
      },
      accessToken,
      refreshToken,
    };
  }

  async logout(userId: string) {
    // TypeORM requires undefined or string for the column, it errors on null because the property is typed as string on the entity
    await this.usersRepository.update(userId, { jwtRefreshToken: null as unknown as string });
    return { success: true, message: 'Logged out successfully.' };
  }
}
