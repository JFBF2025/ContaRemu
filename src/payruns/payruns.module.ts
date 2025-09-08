import { Module } from '@nestjs/common';
import { PayrunsController } from './payruns.controller';
@Module({ controllers: [PayrunsController] })
export class PayrunsModule {}
