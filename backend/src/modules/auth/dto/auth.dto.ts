import { IsString, IsNotEmpty, IsOptional, IsEmail, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class SendOtpDto {
  @ApiProperty({ example: '+919876543210' })
  @IsString()
  @IsNotEmpty()
  @Matches(/^(\+)?\d{10,15}$/, { message: 'Enter a valid phone number (10 digits or E.164 format)' })
  phone: string;
}

export class VerifyOtpDto {
  @ApiProperty({ example: '+919876543210' })
  @IsString()
  @IsNotEmpty()
  @Matches(/^(\+)?\d{10,15}$/, { message: 'Enter a valid phone number' })
  phone: string;

  @ApiProperty({ example: 'FIREBASE_ID_TOKEN' })
  @IsString()
  @IsNotEmpty()
  idToken: string;
}

export class RegisterDto {
  @ApiProperty({ example: '+919876543210' })
  @IsString()
  @IsNotEmpty()
  @Matches(/^(\+)?\d{10,15}$/, { message: 'Enter a valid phone number' })
  phone: string;

  @ApiProperty({ example: 'FIREBASE_ID_TOKEN' })
  @IsString()
  @IsNotEmpty()
  idToken: string;

  @ApiProperty({ example: 'John Doe' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ required: false, example: 'john@example.com' })
  @IsEmail()
  @IsOptional()
  email?: string;

  @ApiProperty({ example: 'customer', enum: ['customer', 'provider'] })
  @IsString()
  @Matches(/^(customer|provider)$/, { message: 'Role must be customer or provider' })
  role: string;
}

export class RefreshTokenDto {
  @ApiProperty({ example: 'eyJhbG...' })
  @IsString()
  @IsNotEmpty()
  refreshToken: string;
}
