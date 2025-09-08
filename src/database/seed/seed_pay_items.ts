import { AppDataSource } from '../../../ormconfig';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

async function seed() {
  const ds = await AppDataSource.initialize();
  const sql = readFileSync(resolve(process.cwd(), 'seed_pay_items.sql'), 'utf8');
  await ds.query(sql);
  await ds.destroy();
  console.log('Seed loaded');
}
seed();