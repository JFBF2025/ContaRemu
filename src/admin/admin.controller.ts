import { Controller, Get, Headers, HttpException, HttpStatus } from '@nestjs/common';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { AppDataSource } from '../../../ormconfig';

@Controller('admin')
export class AdminController {
  @Get('migrate')
  async migrate(@Headers('x-init-token') token: string) {
    if (!process.env.INIT_TOKEN || token !== process.env.INIT_TOKEN) {
      throw new HttpException('Unauthorized', HttpStatus.UNAUTHORIZED);
    }
    const ds = await AppDataSource.initialize();
    const schema = readFileSync(resolve(process.cwd(), 'schema.sql'), 'utf8');
    await ds.query(schema);
    const seed = readFileSync(resolve(process.cwd(), 'seed_pay_items.sql'), 'utf8');
    await ds.query(seed);
    await ds.destroy();
    return { ok: true, message: 'Schema + seed ejecutados' };
  }
}