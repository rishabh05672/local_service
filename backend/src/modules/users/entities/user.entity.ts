import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';

@Entity('users')
export class UserEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  phone: string;

  @Column({ nullable: true })
  email: string;

  @Column()
  name: string;

  @Column({ default: 'customer' }) // customer, provider, admin
  role: string;

  @Column({ nullable: true })
  avatarUrl: string;

  @Column({ default: true })
  isActive: boolean;

  @Column({ nullable: true })
  jwtRefreshToken: string; // Hashed refresh token

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
