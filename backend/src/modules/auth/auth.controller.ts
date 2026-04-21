import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { SendOtpDto, VerifyOtpDto, RegisterDto, RefreshTokenDto } from './dto/auth.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { GetUser } from '../../common/decorators/get-user.decorator';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('send-otp')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Send OTP to phone (Now handled by Client directly via Firebase)' })
  @ApiResponse({ status: 200, description: 'OTP sent' })
  async sendOtp(@Body() dto: SendOtpDto) {
    // In Firebase Phone Auth, the client sends the OTP directly.
    // We can keep this endpoint for logging or if you want to implement additional checks.
    return { success: true, message: 'OTP flow is now managed via Firebase' };
  }

  @Post('verify-login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verify OTP and login existing user' })
  @ApiResponse({ status: 200, description: 'Returns access & refresh tokens' })
  async verifyLogin(@Body() dto: VerifyOtpDto) {
    const phone = await this.authService.verifyFirebaseToken(dto.idToken);
    if (phone !== dto.phone) {
      throw new UnauthorizedException('Phone number mismatch with token.');
    }
    return this.authService.loginWithPhone(phone);
  }

  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Register a new user' })
  @ApiResponse({ status: 201, description: 'User created and tokens returned' })
  async register(@Body() dto: RegisterDto) {
    const phone = await this.authService.verifyFirebaseToken(dto.idToken);
    if (phone !== dto.phone) {
      throw new UnauthorizedException('Phone number mismatch with token.');
    }
    return this.authService.register(dto);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Refresh access token using refresh token' })
  @ApiResponse({ status: 200, description: 'Returns new token pair' })
  async refresh(@Body() dto: RefreshTokenDto) {
    return this.authService.refreshTokens(dto.refreshToken);
  }

  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Logout and revoke refresh token' })
  @ApiResponse({ status: 200, description: 'Logged out successfully' })
  async logout(@GetUser('id') userId: string) {
    return this.authService.logout(userId);
  }
}
