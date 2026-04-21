import { Controller, Get, Put, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../../common/decorators/get-user.decorator';
import { UserEntity } from './entities/user.entity';

@ApiTags('Users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  @ApiOperation({ summary: 'Get current user profile' })
  async getProfile(@GetUser() user: UserEntity) {
    return this.usersService.findOne(user.id);
  }

  @Put('me')
  @ApiOperation({ summary: 'Update current user profile' })
  async updateProfile(
    @GetUser('id') userId: string,
    @Body() updateData: Partial<UserEntity>,
  ) {
    return this.usersService.updateProfile(userId, updateData);
  }
}
