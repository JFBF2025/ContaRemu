import { Module } from '@nestjs/common';
import { AppDataSource } from '../../ormconfig';
@Module({ controllers: [AdminController] })
export class AdminModule {}
