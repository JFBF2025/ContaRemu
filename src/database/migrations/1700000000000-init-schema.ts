import { AppDataSource } from '../../../ormconfig';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
async function run() {
  const ds = await AppDataSource.initialize();
  const sql = readFileSync(resolve(process.cwd(), 'schema.sql'), 'utf8');
  await ds.query(sql);
  await ds.destroy();
  console.log('Schema created');
}
if (process.argv.includes('--run')) run();
